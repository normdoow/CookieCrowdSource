//
//  ViewController.swift
//  CookieCrowdSource
//
//  Created by Noah Bragg on 8/19/17.
//  Copyright © 2017 Noah Bragg. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    let settings = SettingsViewController()
    let locationChecker = LocationChecker()
    var timer = Timer()

    @IBOutlet weak var getCookiesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        checkLocation()
        
        timer = Timer.scheduledTimer(timeInterval: 10, target: self,
                             selector: #selector(ViewController.checkLocation), userInfo: nil, repeats: true)
    }

    @IBAction func tapCheckout(_ sender: Any) {
        let controller = CheckoutViewController(product: "Cookies", price: 1000, settings: settings.settings)
        self.present(controller, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    
    func checkLocation() {
        if !locationChecker.isLocationAuthorized() {
            changeToNotAuthorizedButton()
        } else if locationChecker.doesRegionIncludeCurrentLocation() {
            changeToGetCookiesButton()
        } else {
            changeToNoLocationButton()
        }
    }
    
    func changeToNotAuthorizedButton() {
        getCookiesButton.setTitle("Allow Location in Settings", for: UIControlState())
        getCookiesButton.isEnabled = false
        getCookiesButton.layer.cornerRadius = 10
    }
    
    func changeToNotAvailable() {
        getCookiesButton.setTitle("Cookies Not Available", for: UIControlState())
        getCookiesButton.isEnabled = false
        getCookiesButton.layer.cornerRadius = 10
    }
    
    func changeToGetCookiesButton() {
        getCookiesButton.setTitle("Get Hot Cookies!", for: UIControlState())
        getCookiesButton.isEnabled = true
        getCookiesButton.layer.cornerRadius = 10
    }
    
    func changeToNoLocationButton() {
        getCookiesButton.setTitle("Must Be in Dayton Ohio", for: UIControlState())
        getCookiesButton.isEnabled = false
        getCookiesButton.layer.cornerRadius = 10
//        getCookiesButton.layer.backgroundColor = UIColor(red:0.22, green:0.65, blue:0.91, alpha:1.00) as! CGColor

    }


}

