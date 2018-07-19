# VisaCheckout-Swift-Sample
Hands-on sample app for integrating Visa Checkout using the [Judopay Swift SDK](https://cocoapods.org/pods/JudoKit)

## Requirements
- Xcode 9.4.1
- Swift 4.1
- JudoKit 7.1.0
- Visa Checkout SDK 6.3.0

## Getting started

#### 1. Add the Visa Checkout SDK to your project
##### Cocoapods
Add the Visa Checkout SDK pod to your `Podfile` alongside the `JudoKit` pod

```ruby
  pod 'JudoKit', '~> 7.1.0'
  pod 'VisaCheckoutSDK', '~> 6.3.0'
```

Run `pod install`

##### Manually
Download the [Visa Checkout SDK](https://developer.visa.com/capabilities/visa_checkout/docs#adding_visa_checkout_to_a_mobile_application) and follow the instructions in the bundled documentation.

#### 2. Add the Visa Checkout button to your ViewController in the storyboard
- Add a `View` to your `ViewController`
- Set the custom class of the view to `VisaCheckoutButton`
- Connect the view with an `@IBOutlet` in your `ViewController`

#### 3. Create a `PurchaseInfo` and set up the `VisaCheckoutButton`
Import `VisaCheckoutSDK` and `JudoKit`

```swift
let profile = Profile(environment: .sandbox, apiKey: "<#Your VCO api key#>", profileName: nil)
// An arbitrary example of some configuration details you can customize.
profile.datalevel = .full

let purchaseInfo = PurchaseInfo(total: CurrencyAmount(double: 10.99), currency: .gbp)
purchaseInfo.reviewAction = .pay
purchaseInfo.promoCode = "PROMO1"
purchaseInfo.discount = CurrencyAmount(decimalNumber: 1.99)
purchaseInfo.orderId = orderId

checkoutButton.onCheckout(profile: profile, purchaseInfo: purchaseInfo, presenting: self, completion: visaCheckoutResultHandler)
```

#### 4. Handle the VCO response and pass on the result to Judo

```swift
private func visaCheckoutResultHandler(result: CheckoutResult) {
    switch result.statusCode {
    case .statusSuccess:
        if let callId = result.callId, let encryptedKey = result.encryptedKey, let encryptedPaymentData = result.encryptedPaymentData {
            let amount = Amount(decimalNumber: 10.99, currency: .GBP)
            let reference = Reference(consumerRef: UUID().uuidString, paymentRef: orderId)
            let vcoResult = VCOResult(callId: callId, encryptedKey: encryptedKey, encryptedPaymentData: encryptedPaymentData)
            _ = try? judoKit
                .payment(judoId, amount: amount, reference: reference)
                .vcoResult(vcoResult)
                .completion(judoCompletionBlock)
        }
    case .statusUserCancelled:
        print("Payment cancelled by the user")
    default:
        break
    }
}
```

#### 5. Handle the Judo callback to check the payment results

```swift
private func judoCompletionBlock(response: Response?, error: JudoError?) {
    if let response = response, response.items.count > 0, response.items[0].result == .Success {
        print("Payment successful!")
    } else {
        print("Oops. Something went wrong.")
    }
}
```
