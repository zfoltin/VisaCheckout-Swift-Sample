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

    override func viewDidLoad() {
        super.viewDidLoad()
        initVisaCheckout()
        judoKit.sandboxed(true)
    }

    private func initVisaCheckout() {
        /// See the documentation/headers for `PurchaseInfo` for
        /// various ways to customize the purchase experience.
        let purchaseInfo = PurchaseInfo(total: 10.99, currency: .gbp)
        purchaseInfo.reviewAction = .pay
        checkoutButton.onCheckout(purchaseInfo: purchaseInfo, completion: visaCheckoutResultHandler)
    }

    private func visaCheckoutResultHandler(result: CheckoutResult) {
        switch result.statusCode {
        case .success:
            print("CallId: \(String(describing: result.callId))")
            print("Encrypted key: \(String(describing: result.encryptedKey))")
            print("Payment data: \(String(describing: result.encryptedPaymentData))")

            if let callId = result.callId, let encryptedKey = result.encryptedKey, let encryptedPaymentData = result.encryptedPaymentData {
                let amount = Amount(decimalNumber: 10.99, currency: .GBP)
                let vcoResult = VCOResult(callId: callId, encryptedKey: encryptedKey, encryptedPaymentData: encryptedPaymentData)
                if let reference = Reference(consumerRef: UUID().uuidString),
                    let payment = try? judoKit.payment(judoId, amount: amount, reference: reference).vcoResult(vcoResult) {
                    _ = try? payment.completion(judoCompletionBlock)
                }
            }
        case .userCancelled:
            print("Payment cancelled by the user")
        default:
            break
        }
    }

    private func judoCompletionBlock(response: Response?, error: JudoError?) {
        if let response = response, response.items.count > 0, response.items[0].result == .Success {
            print("Payment successful!")
        } else {
            print("Oops. Something went wrong.")
        }
    }
}
