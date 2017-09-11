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
}
