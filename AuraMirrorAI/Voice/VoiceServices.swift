import AVFoundation
import Foundation
import Observation
import Speech
import SwiftUI

@MainActor
@Observable
final class SpeechRecognitionService {
    var transcript = ""
    var authorizationStatus: SFSpeechRecognizerAuthorizationStatus = .notDetermined

    func requestAuthorization() async {
        authorizationStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
    }

    func startMockTranscription() {
        transcript = "What should I wear to a wedding?"
    }
}

@MainActor
@Observable
final class VoiceRecordingService {
    var isRecording = false

    func toggleRecording() {
        isRecording.toggle()
    }
}

@MainActor
@Observable
final class WaveformAnimationManager {
    var levels: [CGFloat] = Array(repeating: 0.28, count: 28)

    func animate(recording: Bool) {
        levels = levels.indices.map { index in
            recording ? CGFloat.random(in: 0.18...1.0) : (index.isMultiple(of: 3) ? 0.42 : 0.22)
        }
    }
}
