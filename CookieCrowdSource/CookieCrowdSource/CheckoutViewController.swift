//
//  CheckoutViewController.swift
//  CookieCrowdSource
//
//  Created by Noah Bragg on 8/19/17.
//  Copyright © 2017 Noah Bragg. All rights reserved.
//

import UIKit
import Stripe

class CheckoutViewController: UIViewController, STPPaymentContextDelegate {
    
    // 1) To get started with this demo, first head to https://dashboard.stripe.com/account/apikeys
    // and copy your "Test Publishable Key" (it looks like pk_test_abcdef) into the line below.
    
    // 2) Next, optionally, to have this demo save your user's payment details, head to
    // https://github.com/stripe/example-ios-backend , click "Deploy to Heroku", and follow
    // the instructions (don't worry, it's free). Replace nil on the line below with your
    // Heroku URL (it looks like https://blazing-sunrise-1234.herokuapp.com ).
    
    // 3) Optionally, to enable Apple Pay, follow the instructions at https://stripe.com/docs/mobile/apple-pay
    // to create an Apple Merchant ID. Replace nil on the line below with it (it looks like merchant.com.yourappname).
    let appleMerchantID: String? = nil
    
    // These values will be shown to the user when they purchase with Apple Pay.
    let companyName = "Emoji Apparel"
    let paymentCurrency = "usd"
    
    let paymentContext: STPPaymentContext
    
    let theme: STPTheme
    let paymentRow: CheckoutRowView
    let shippingRow: CheckoutRowView
    let totalRow: CheckoutRowView
    let buyButton: BuyButton
    let rowHeight: CGFloat = 44
    let productImage = UILabel()
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let numberFormatter: NumberFormatter
    let shippingString: String
    var product = ""
    var paymentInProgress: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                if self.paymentInProgress {
                    self.activityIndicator.startAnimating()
                    self.activityIndicator.alpha = 1
                    self.buyButton.alpha = 0
                }
                else {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.alpha = 0
                    self.buyButton.alpha = 1
                }
            }, completion: nil)
        }
    }
    
    init(product: String, price: Int, settings: Settings) {
        
        let stripePublishableKey = StripeKey.PUBLIC_KEY
        let backendBaseURL = MyAPIClient.baseURLString
        
        assert(stripePublishableKey.hasPrefix("pk_"), "You must set your Stripe publishable key at the top of CheckoutViewController.swift to run this app.")
        assert(backendBaseURL != nil, "You must set your backend base url at the top of CheckoutViewController.swift to run this app.")
        
        self.product = product
        self.productImage.text = product
        self.theme = settings.theme
        
        // This code is included here for the sake of readability, but in your application you should set up your configuration and theme earlier, preferably in your App Delegate.
        let config = STPPaymentConfiguration.shared()
        config.publishableKey = StripeKey.PUBLIC_KEY
        config.appleMerchantIdentifier = self.appleMerchantID
        config.companyName = self.companyName
        config.requiredBillingAddressFields = settings.requiredBillingAddressFields
        config.requiredShippingAddressFields = settings.requiredShippingAddressFields
        config.shippingType = settings.shippingType
        config.additionalPaymentMethods = settings.additionalPaymentMethods
        
        
        
        let customerContext = STPCustomerContext(keyProvider: MyAPIClient.sharedClient)
        let paymentContext = STPPaymentContext(customerContext: customerContext,
                                               configuration: config,
                                               theme: settings.theme)
        let userInformation = STPUserInformation()
        paymentContext.prefilledInformation = userInformation
        paymentContext.paymentAmount = price
        if !CookieUserDefaults().gotFreeCookies()! {
            paymentContext.paymentAmount = 500
        }
        paymentContext.paymentCurrency = self.paymentCurrency
        self.paymentContext = paymentContext
        
        self.paymentRow = CheckoutRowView(title: "Payment", detail: "Select Payment", theme: settings.theme)
        var shippingString = "Contact"
        if config.requiredShippingAddressFields.contains(.postalAddress) {
            shippingString = config.shippingType == .shipping ? "Delivery" : "Delivery"
        }
        self.shippingString = shippingString
        self.shippingRow = CheckoutRowView(title: self.shippingString, detail: "Enter \(self.shippingString) Info", theme: settings.theme)
        self.totalRow = CheckoutRowView(title: "Total", detail: "", tappable: false, theme: settings.theme)
        self.buyButton = BuyButton(enabled: true, theme: settings.theme)
        var localeComponents: [String: String] = [
            NSLocale.Key.currencyCode.rawValue: self.paymentCurrency,
            ]
        localeComponents[NSLocale.Key.languageCode.rawValue] = NSLocale.preferredLanguages.first
        let localeID = NSLocale.localeIdentifier(fromComponents: localeComponents)
        let numberFormatter = NumberFormatter()
        numberFormatter.locale = Locale(identifier: localeID)
        numberFormatter.numberStyle = .currency
        numberFormatter.usesGroupingSeparator = true
        self.numberFormatter = numberFormatter
        super.init(nibName: nil, bundle: nil)
        self.paymentContext.delegate = self
        paymentContext.hostViewController = self
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = self.theme.primaryBackgroundColor
        var red: CGFloat = 0
        self.theme.primaryBackgroundColor.getRed(&red, green: nil, blue: nil, alpha: nil)
        self.activityIndicator.activityIndicatorViewStyle = red < 0.5 ? .white : .gray
        self.navigationItem.title = "Emoji Apparel"
        
        self.productImage.font = UIFont.systemFont(ofSize: 80)
        self.view.addSubview(self.totalRow)
        self.view.addSubview(self.paymentRow)
        self.view.addSubview(self.shippingRow)
        self.view.addSubview(self.productImage)
        self.view.addSubview(self.buyButton)
        self.view.addSubview(self.activityIndicator)
        self.activityIndicator.alpha = 0
        self.buyButton.addTarget(self, action: #selector(didTapBuy), for: .touchUpInside)
        self.totalRow.detail = self.numberFormatter.string(from: NSNumber(value: Float(self.paymentContext.paymentAmount)/100))!
        self.paymentRow.onTap = { [weak self] _ in
//            if CookieUserDefaults().gotFreeCookies()! {
                self?.paymentContext.presentPaymentMethodsViewController()
//            }
        }
        self.shippingRow.onTap = { [weak self] _ in
            self?.paymentContext.presentShippingViewController()
        }
        let button = UIButton(frame: CGRect(x: -10, y: 10, width: 100, height: 50))
        button.backgroundColor = UIColor.clear
        button.setTitleColor(UIColor(red:0.0, green:0.18, blue:0.41, alpha:1.00), for: UIControlState.normal)
        button.setTitle("<Back", for: .normal)
        button.titleLabel!.font = UIFont(name: "Arial-BoldMT", size: 24)
        button.addTarget(self, action: #selector(dismiss as (Void) -> Void), for: .touchUpInside)
        
        self.view.addSubview(button)
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let width = self.view.bounds.width
        self.productImage.sizeToFit()
        self.productImage.center = CGPoint(x: width/2.0,
                                           y: self.productImage.bounds.height/2.0 + rowHeight)
        self.paymentRow.frame = CGRect(x: 0, y: self.productImage.frame.maxY + rowHeight,
                                       width: width, height: rowHeight)
        self.shippingRow.frame = CGRect(x: 0, y: self.paymentRow.frame.maxY,
                                        width: width, height: rowHeight)
        self.totalRow.frame = CGRect(x: 0, y: self.shippingRow.frame.maxY,
                                     width: width, height: rowHeight)
        self.buyButton.frame = CGRect(x: 0, y: 0, width: 88, height: 44)
        self.buyButton.center = CGPoint(x: width/2.0, y: self.totalRow.frame.maxY + rowHeight*1.5)
        self.activityIndicator.center = self.buyButton.center
    }
    
    func didTapBuy() {
        self.paymentInProgress = true
        self.paymentContext.requestPayment()
//        if CookieUserDefaults().gotFreeCookies()! {      //the user has to pay money for the cookies
//            self.paymentContext.requestPayment()
//        } else {                                        //the user gets the cookies free
//            if paymentContext.shippingAddress == nil {
//                self.paymentContext.presentShippingViewController()
//                self.paymentInProgress = false
//            } else {
//                MyAPIClient.sharedClient.completeCharge(STPPaymentResult.init(),
//                                                        amount: self.paymentContext.paymentAmount,
//                                                        shippingAddress: self.paymentContext.shippingAddress,
//                                                        shippingMethod: self.paymentContext.selectedShippingMethod,
//                                                        completion: {
//                                                            self.paymentInProgress = false
//                                                            var message = ""
//                                                            var title = ""
//                                                            if $0 == nil {
//                                                                title = "Success"
//                                                                message = "Thank you for your order! You will receive a dozen 🍪s in 30 to 40 minutes!"
//                                                                CookieUserDefaults().setGotFreeCookies(gotFreeCookies: true)
//                                                            } else {
//                                                                title = "Error"
//                                                                message = $0?.localizedDescription ?? ""
//                                                            }
//                                                            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//                                                            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
//                                                            alertController.addAction(action)
//                                                            self.present(alertController, animated: true, completion: nil)
//                                                        })
//            }
//        }
    }
    
    // MARK: STPPaymentContextDelegate
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPErrorBlock) {
        MyAPIClient.sharedClient.completeCharge(paymentResult,
                                                amount: self.paymentContext.paymentAmount,
                                                shippingAddress: self.paymentContext.shippingAddress,
                                                shippingMethod: self.paymentContext.selectedShippingMethod,
                                                completion: completion)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        self.paymentInProgress = false
        let title: String
        let message: String
        switch status {
        case .error:
            title = "Error"
            message = error?.localizedDescription ?? ""
        case .success:
            title = "Success"
            message = "Thank you for your order! You will receive a dozen 🍪s in 30 to 40 minutes!"
            CookieUserDefaults().setGotFreeCookies(gotFreeCookies: true)
        case .userCancellation:
            return
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        self.paymentRow.loading = paymentContext.loading
//        if !CookieUserDefaults().gotFreeCookies()! {
//            self.paymentRow.detail = "FREE"
//            
//        } else
        if let paymentMethod = paymentContext.selectedPaymentMethod {
            self.paymentRow.detail = paymentMethod.label
        } else {
            self.paymentRow.detail = "Select Payment"
        }
        if let shippingMethod = paymentContext.selectedShippingMethod {
            self.shippingRow.detail = shippingMethod.label
        } else {
            self.shippingRow.detail = "Enter \(self.shippingString) Info"
        }
        self.totalRow.detail = self.numberFormatter.string(from: NSNumber(value: Float(self.paymentContext.paymentAmount)/100))!
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        let alertController = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            // Need to assign to _ because optional binding loses @discardableResult value
            // https://bugs.swift.org/browse/SR-1681
            _ = self.navigationController?.popViewController(animated: true)
        })
        let retry = UIAlertAction(title: "Retry", style: .default, handler: { action in
            self.paymentContext.retryLoading()
        })
        alertController.addAction(cancel)
        alertController.addAction(retry)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didUpdateShippingAddress address: STPAddress, completion: @escaping STPShippingMethodsCompletionBlock) {
        
        let shipping = PKShippingMethod()
        shipping.amount = 0.0
        shipping.label = "Delivered to your Door"
        shipping.detail = "Arrives in 30 - 40 minutes"
        shipping.identifier = "Delivered to your door"
        
        completion(.valid, nil, [shipping], nil)
    }
    
}
