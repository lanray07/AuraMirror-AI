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
    var purchaseMessage: String?

    private let productIDs = [
        "auramirror.premium.monthly",
        "auramirror.premium.yearly"
    ]

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await Product.products(for: productIDs)
            await refreshEntitlements()
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func product(for plan: AuraPlan) -> Product? {
        guard let productID = plan.productID else { return nil }
        return products.first { $0.id == productID }
    }

    func displayPrice(for plan: AuraPlan) -> String {
        product(for: plan)?.displayPrice ?? plan.fallbackPrice
    }

    func purchase(_ plan: AuraPlan) async {
        guard let product = product(for: plan) else {
            purchaseError = "This subscription is not available yet. Please try again shortly."
            return
        }

        isLoading = true
        purchaseError = nil
        purchaseMessage = nil
        defer { isLoading = false }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                activePlan = plan
                purchaseMessage = "Subscription active."
                await transaction.finish()
            case .userCancelled:
                purchaseMessage = "Purchase cancelled."
            case .pending:
                purchaseMessage = "Purchase pending approval."
            @unknown default:
                purchaseMessage = "Purchase status could not be determined."
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    func restorePurchases() async {
        isLoading = true
        purchaseError = nil
        purchaseMessage = nil
        defer { isLoading = false }

        do {
            try await AppStore.sync()
            await refreshEntitlements()
            purchaseMessage = activePlan == .free ? "No active subscriptions found." : "Subscription restored."
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    private func refreshEntitlements() async {
        var restoredPlan: AuraPlan = .free
        for await result in Transaction.currentEntitlements {
            guard let transaction = try? checkVerified(result),
                  transaction.revocationDate == nil,
                  let plan = AuraPlan.allCases.first(where: { $0.productID == transaction.productID }) else {
                continue
            }
            restoredPlan = plan
        }
        activePlan = restoredPlan
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let safe):
            return safe
        case .unverified:
            throw PurchaseVerificationError.failedVerification
        }
    }
}

enum PurchaseVerificationError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        switch self {
        case .failedVerification:
            return "The App Store could not verify this purchase."
        }
    }
}
