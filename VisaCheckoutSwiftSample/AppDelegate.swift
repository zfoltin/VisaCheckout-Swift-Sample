//
//  AppDelegate.swift
//  VisaCheckoutSwiftSample
//
//  Created by Zeno Foltin on 19/11/2017.
//  Copyright © 2017 Judopay. All rights reserved.
//

import UIKit
import VisaCheckoutSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let profile = Profile(environment: .sandbox, apiKey: "<#Your API Key goes here#>")
        /// An arbitrary example of some configuration details you can customize.
        /// See the documentation/headers for `Profile`.
        profile.datalevel = .full
        profile.acceptedCardBrands = [.visa, .mastercard, .discover]

        VisaCheckoutSDK.configure(profile: profile)

        return true
    }
}
