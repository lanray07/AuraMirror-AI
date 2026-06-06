import Foundation
import Observation
import StoreKit

@MainActor
@Observable
final class SubscriptionService {
    var products: [Product] = []
    var activePlan: AuraPlan = .free
    var isLoading = false
    var purchaseError: String?

    private let productIDs = [
        "auramirror.premium.monthly",
        "auramirror.premium.yearly",
        "auramirror.elite.monthly"
    ]

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await Product.products(for: productIDs)
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func purchasePlaceholder(_ plan: AuraPlan) {
        activePlan = plan
    }
}
