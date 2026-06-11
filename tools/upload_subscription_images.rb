#!/usr/bin/env ruby
# frozen_string_literal: true

require "base64"
require "digest"
require "json"
require "net/http"
require "openssl"
require "pathname"
require "uri"

API_BASE = "https://api.appstoreconnect.apple.com/v1"

def env!(name)
  value = ENV[name]
  return value unless value.nil? || value.strip.empty?

  abort("Missing required environment variable: #{name}")
end

def normalize_private_key(value)
  value = value.strip
  decoded = begin
    Base64.decode64(value)
  rescue StandardError
    nil
  end

  value = decoded if decoded&.include?("BEGIN PRIVATE KEY")
  value.gsub("\\n", "\n")
end

def base64url(value)
  Base64.urlsafe_encode64(value).delete("=")
end

def es256_signature(private_key_pem, signing_input)
  key = OpenSSL::PKey.read(private_key_pem)
  digest = OpenSSL::Digest::SHA256.new
  der_signature = key.dsa_sign_asn1(digest.digest(signing_input))
  asn1 = OpenSSL::ASN1.decode(der_signature)
  r, s = asn1.value.map(&:value)
  raw = [r, s].map { |integer| integer.to_s(16).rjust(64, "0") }.pack("H*H*")
  base64url(raw)
end

def jwt_token
  header = {
    alg: "ES256",
    kid: env!("ASC_KEY_ID"),
    typ: "JWT"
  }
  payload = {
    iss: env!("ASC_ISSUER_ID"),
    exp: Time.now.to_i + 20 * 60,
    aud: "appstoreconnect-v1"
  }
  signing_input = [base64url(header.to_json), base64url(payload.to_json)].join(".")
  "#{signing_input}.#{es256_signature(normalize_private_key(env!("ASC_PRIVATE_KEY")), signing_input)}"
end

def api_request(method, path, token, body: nil, query: nil)
  uri = URI("#{API_BASE}#{path}")
  uri.query = URI.encode_www_form(query) if query
  request_class = Net::HTTP.const_get(method.capitalize)
  request = request_class.new(uri)
  request["Authorization"] = "Bearer #{token}"
  request["Content-Type"] = "application/json"
  request["Accept"] = "application/json"
  request.body = JSON.generate(body) if body

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(request)
  end

  return nil if response.code.to_i == 204

  parsed = response.body.to_s.empty? ? nil : JSON.parse(response.body)
  return parsed if response.code.to_i.between?(200, 299)

  warn(JSON.pretty_generate(parsed)) if parsed
  abort("#{method.upcase} #{uri} failed with HTTP #{response.code}")
end

def upload_operation(operation, file_data)
  url = operation.fetch("url")
  method = operation.fetch("method", "PUT").capitalize
  offset = operation.fetch("offset", 0)
  length = operation.fetch("length", file_data.bytesize)
  part = file_data.byteslice(offset, length)

  uri = URI(url)
  request_class = Net::HTTP.const_get(method)
  request = request_class.new(uri)
  operation.fetch("requestHeaders", []).each do |header|
    name = header["name"]
    value = header["value"]
    request[name] = value if name && value
  end
  request.body = part

  response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
    http.request(request)
  end

  return if response.code.to_i.between?(200, 299)

  abort("#{method.upcase} #{uri.host} upload failed with HTTP #{response.code}: #{response.body}")
end

def delete_existing_images(subscription_id, token)
  response = api_request(
    "get",
    "/subscriptions/#{subscription_id}/images",
    token,
    query: {
      "fields[subscriptionImages]" => "fileName,state",
      "limit" => "10"
    }
  )

  response.fetch("data", []).each do |image|
    image_id = image.fetch("id")
    file_name = image.dig("attributes", "fileName") || "(unnamed)"
    state = image.dig("attributes", "state") || "(unknown)"
    puts "Deleting existing subscription image #{image_id} #{file_name} #{state}"
    api_request("delete", "/subscriptionImages/#{image_id}", token)
  end
end

def upload_subscription_image(subscription_id, image_path, token)
  path = Pathname.new(image_path)
  abort("Image does not exist: #{image_path}") unless path.file?

  file_data = path.binread
  create_body = {
    data: {
      type: "subscriptionImages",
      attributes: {
        fileSize: file_data.bytesize,
        fileName: path.basename.to_s
      },
      relationships: {
        subscription: {
          data: {
            type: "subscriptions",
            id: subscription_id
          }
        }
      }
    }
  }

  created = api_request("post", "/subscriptionImages", token, body: create_body)
  image = created.fetch("data")
  image_id = image.fetch("id")
  operations = image.dig("attributes", "uploadOperations") || []
  abort("Apple did not return upload operations for #{subscription_id}") if operations.empty?

  puts "Uploading #{path.basename} to subscription #{subscription_id} as image #{image_id}"
  operations.each { |operation| upload_operation(operation, file_data) }

  update_body = {
    data: {
      type: "subscriptionImages",
      id: image_id,
      attributes: {
        sourceFileChecksum: Digest::MD5.file(path).hexdigest,
        uploaded: true
      }
    }
  }

  updated = api_request("patch", "/subscriptionImages/#{image_id}", token, body: update_body)
  state = updated.dig("data", "attributes", "state") || "(unknown)"
  puts "Committed #{path.basename}: #{state}"
end

token = jwt_token

[
  [env!("ASC_MONTHLY_SUBSCRIPTION_ID"), env!("ASC_MONTHLY_IMAGE_PATH")],
  [env!("ASC_YEARLY_SUBSCRIPTION_ID"), env!("ASC_YEARLY_IMAGE_PATH")]
].each do |subscription_id, image_path|
  delete_existing_images(subscription_id, token)
  upload_subscription_image(subscription_id, image_path, token)
end
