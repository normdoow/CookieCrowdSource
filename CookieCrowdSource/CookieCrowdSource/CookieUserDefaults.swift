//
//  UserDefaults.swift
//  CookieCrowdSource
//
//  Created by Noah Bragg on 9/10/17.
//  Copyright © 2017 Noah Bragg. All rights reserved.
//

import Foundation

class CookieUserDefaults {
    
    private static let CUSTOMER_ID = "customer-id"
    private static let FREE_COOKIES = "free-cookies"
    private static let BAKER_EMAIL = "baker-email"
    private static let MY_BAKER_EMAIL = "my-baker-email"       //used to hold the current baker that the user can buy from
    private static let AVAILABLE_TO_CUSTOMERS = "available-to-customers"
    private var defaults:UserDefaults
    
    init() {
        defaults = UserDefaults.standard
    }
    
    func setCustomerId(customorId:String) {
        defaults.set(customorId, forKey: CookieUserDefaults.CUSTOMER_ID)
    }
    
    func getCustomerId() -> String? {
        return defaults.string(forKey: CookieUserDefaults.CUSTOMER_ID)
    }
    
    func setGotFreeCookies(gotFreeCookies:Bool) {
        defaults.set(gotFreeCookies, forKey: CookieUserDefaults.FREE_COOKIES)
    }
    
    func gotFreeCookies() -> Bool? {
        return defaults.bool(forKey: CookieUserDefaults.FREE_COOKIES)
    }
    
    //used to hold the current baker that the user can buy from
    func setMyBakerEmail(bakerEmail: String) {
        defaults.set(bakerEmail, forKey: CookieUserDefaults.MY_BAKER_EMAIL)
    }
    func getMyBakerEmail() -> String? {
        return defaults.string(forKey: CookieUserDefaults.MY_BAKER_EMAIL)
    }
    
    //used to see if baker is logged in or not
    func setBakerEmail(bakerEmail: String) {
        defaults.set(bakerEmail, forKey: CookieUserDefaults.BAKER_EMAIL)
    }
    func getBakerEmail() -> String? {
        return defaults.string(forKey: CookieUserDefaults.BAKER_EMAIL)
    }
    
    func setAvailableToCustomers(isAvailable: Bool) {
        defaults.set(isAvailable, forKey: CookieUserDefaults.AVAILABLE_TO_CUSTOMERS)
    }
    func getAvailableToCustomers() -> Bool? {
        return defaults.bool(forKey: CookieUserDefaults.AVAILABLE_TO_CUSTOMERS)
    }
}
