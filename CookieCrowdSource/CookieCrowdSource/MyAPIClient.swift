//
//  MyAPIClient.swift
//  CookieCrowdSource
//
//  Created by Noah Bragg on 8/19/17.
//  Copyright © 2017 Noah Bragg. All rights reserved.
//

import Foundation
import Stripe
import Alamofire

class MyAPIClient: NSObject, STPEphemeralKeyProvider {
    
    static let sharedClient = MyAPIClient()
//    public static var baseURLString: String? = "http://192.168.0.7:5000"
   public static var baseURLString: String? = "http://noahbragg.pythonanywhere.com"
    var baseURL: URL {
        if let urlString = MyAPIClient.baseURLString, let url = URL(string: urlString) {
            return url
        } else {
            fatalError()
        }
    }
    
    func completeCharge(_ result: STPPaymentResult,
                        amount: Int,
                        shippingAddress: STPAddress?,
                        shippingMethod: PKShippingMethod?,
                        bakerEmail: String,
                        completion: @escaping STPErrorBlock) {
        let url = self.baseURL.appendingPathComponent("charge_v2")
        let customerId = getCustomerIdHelper()
        
        var params: [String: Any] = [
            "source": result.source.stripeID,
            "amount": amount,
            "customer_id": customerId,
            "baker_email": bakerEmail,
            "email": shippingAddress!.email!
        ]
//        params["shipping"] = STPAddress.shippingInfoForCharge(with: shippingAddress, shippingMethod: shippingMethod)
        Alamofire.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseString { response in
                switch response.result {
                case .success:
                    completion(nil)
                case .failure(let error):
                    completion(error)
                }
        }
    }
    
    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        let url = self.baseURL.appendingPathComponent("ephemeral_keys")
        let customerId = getCustomerIdHelper()
        
        Alamofire.request(url, method: .post, parameters: [
            "api_version": apiVersion,
            "customer_id": customerId
            ])
            .validate(statusCode: 200..<300)
            .responseJSON { responseJSON in
                switch responseJSON.result {
                case .success(let json):
                    completion(json as? [String: AnyObject], nil)
                case .failure(let error):
                    completion(nil, error)
                }
        }
    }
    
    func createCustomer(completion: @escaping (String) -> ()) {
        let url = self.baseURL.appendingPathComponent("create_customer")
        Alamofire.request(url, method: .get, parameters: nil)
            .validate(statusCode: 200..<300)
            .responseString { response in
                switch response.result {
                case .success:
                    completion(response.value!)
                case .failure: break
                }
        }
    }
    
    func getCookAvailable(lat:Double, lon:Double, completionHandler:@escaping (String) -> ()) {
        let url = self.baseURL.appendingPathComponent("cook_available")
        let params: [String: Any] = ["lat": lat, "lon": lon]
        Alamofire.request(url, method: .get, parameters: params)
            .validate(statusCode: 200..<300)
            .responseString { response in
                switch response.result {
                case .success:
                    completionHandler(response.value!)
                case .failure:
                    completionHandler("")
                }
        }
    }
    
    func isIsaiahAvailable(completionHandler:@escaping (Bool) -> ()) {
        let url = self.baseURL.appendingPathComponent("is_isaiah_available")
        Alamofire.request(url, method: .get)
            .validate(statusCode: 200..<300)
            .responseString { response in
                switch response.result {
                case .success:
                    completionHandler(response.value! == "True")
                case .failure:
                    completionHandler(false)
                }
        }
    }
    
    func sendNewBakerEmail(email: String, completionHandler:@escaping (Bool) -> ()) {
        let url = self.baseURL.appendingPathComponent("send_new_baker_email")
        let params: [String: Any] = ["email": email] 
        Alamofire.request(url, method: .get, parameters: params)
            .validate(statusCode: 200..<300)
            .responseString { response in
                switch response.result {
                case .success:
                    completionHandler(response.value! == "success sending email")
                case .failure:
                    completionHandler(false)
                }
        }
    }
    
    func loginBaker(pw: String, email: String, completionHandler:@escaping (Bool) -> ()) {
        let url = self.baseURL.appendingPathComponent("login_baker")
        let params: [String: Any] = ["pw": pw, "email": email]
        Alamofire.request(url, method: .get, parameters: params)
            .validate(statusCode: 200..<300)
            .responseString { response in
                switch response.result {
                case .success:
                    completionHandler(response.value! == "success")
                case .failure:
                    completionHandler(false)
                }
        }
    }
    
    func changeBakerAvailability(isAvailableText: String, bakerEmail: String, completionHandler:@escaping (Bool) -> ()) {
        let url = self.baseURL.appendingPathComponent("change_baker_availability")
        let params: [String: Any] = ["baker_email": bakerEmail, "is_available": isAvailableText]
        Alamofire.request(url, method: .get, parameters: params)
            .validate(statusCode: 200..<300)
            .responseString { response in
                switch response.result {
                case .success:
                    completionHandler(response.value! == "success")
                case .failure:
                    completionHandler(false)
                }
        }
    }
    
    func sendRatingEmail(rating: String, comments: String, isWarm: String, isRecommend: String, completionHandler:@escaping (Bool) -> ()) {
        let url = self.baseURL.appendingPathComponent("send_rating_email")
        let params: [String: Any] = ["rating": rating,
                                     "comments": comments,
                                     "isWarm": isWarm,
                                     "isRecommend": isRecommend]
        Alamofire.request(url, method: .get, parameters: params)
            .validate(statusCode: 200..<300)
            .responseString { response in
                switch response.result {
                case .success:
                    completionHandler(response.value! == "success sending email")
                case .failure:
                    completionHandler(false)
                }
        }
    }
    
    func getCustomerIdHelper() -> String {
        var customerId = CookieUserDefaults().getCustomerId()
        if customerId == nil {
            customerId = ""
        }
        return customerId!
    }
    
}
