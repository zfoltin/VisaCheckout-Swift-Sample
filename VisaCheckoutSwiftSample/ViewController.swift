//
//  ViewController.swift
//  VisaCheckoutSwiftSample
//
//  Created by Zeno Foltin on 19/11/2017.
//  Copyright © 2017 Judopay. All rights reserved.
//

import UIKit
import VisaCheckoutSDK
import JudoKit

class ViewController: UIViewController {
    @IBOutlet weak var checkoutButton: VisaCheckoutButton!
    private let judoKit = JudoKit(token: "<#Your Judopay token#>", secret: "<#Your Judopay secret#>")
    private let judoId = "<#Your Judopay Id#>"
    private let orderId = UUID().uuidString

    override func viewDidLoad() {
        super.viewDidLoad()
        initVisaCheckout()
        judoKit.sandboxed(true)
    }

    private func initVisaCheckout() {
        // See the Visa Checkout documentation for `PurchaseInfo` for various ways to customize the purchase experience.
        let purchaseInfo = PurchaseInfo(total: 10.99, currency: .gbp)
        purchaseInfo.reviewAction = .pay
        purchaseInfo.promoCode = "PROMO1"
        purchaseInfo.discount = CurrencyAmount(decimalNumber: 1.99)
        purchaseInfo.orderId = orderId
        checkoutButton.onCheckout(purchaseInfo: purchaseInfo, completion: visaCheckoutResultHandler)
    }

    private func visaCheckoutResultHandler(result: CheckoutResult) {
        switch result.statusCode {
        case .success:
            if let callId = result.callId, let encryptedKey = result.encryptedKey, let encryptedPaymentData = result.encryptedPaymentData {
                let amount = Amount(decimalNumber: 10.99, currency: .GBP)
                let reference = Reference(consumerRef: UUID().uuidString, paymentRef: orderId)
                let vcoResult = VCOResult(callId: callId, encryptedKey: encryptedKey, encryptedPaymentData: encryptedPaymentData)
                _ = try? judoKit
                    .payment(judoId, amount: amount, reference: reference)
                    .vcoResult(vcoResult)
                    .completion(judoCompletionBlock)
            }
        case .userCancelled:
            print("Payment cancelled by the user. 💔")
        default:
            break
        }
    }

    private func judoCompletionBlock(response: Response?, error: JudoError?) {
        var title: String
        var message: String
        if let response = response, response.items.count > 0, response.items[0].result == .success {
            title = "Great Success!"
            message = "Payment successful! 🎉"
        } else {
            title = "Oops"
            message = "Something went wrong. 💥"
        }
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in alert.dismiss(animated: true) }))
        present(alert, animated: true)
    }
}
