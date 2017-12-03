//
//  ViewController.swift
//  CookieCrowdSource
//
//  Created by Noah Bragg on 8/19/17.
//  Copyright © 2017 Noah Bragg. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import KYDrawerController
import Mixpanel

class ViewController: UIViewController {
    
    let settings = SettingsViewController()
    let locationChecker = LocationChecker()
    var timer = Timer()
    var loadingView:NVActivityIndicatorView?
    var isNoahAvailable = false
    var isIsaiahAvailable = false
    var isNoahRightLocation = false
    var isIsaiahRightLocation = false

    @IBOutlet weak var getCookiesButton: UIButton!
    @IBOutlet weak var ingredientsButton: UIButton!
    @IBOutlet weak var dozenFreeImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createCustomerIfFirstTime()
        
        ingredientsButton.layer.cornerRadius = 10
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        changeToLoadingButton()
        
        timer = Timer.scheduledTimer(timeInterval: 3, target: self,
                             selector: #selector(ViewController.checkLocation), userInfo: nil, repeats: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        dozenFreeImage.isHidden = CookieUserDefaults().gotFreeCookies()!
    }

    @IBAction func tapCheckout(_ sender: Any) {
        if !isNoahAvailable && !isNoahRightLocation && !isIsaiahAvailable && !isIsaiahRightLocation {
            Mixpanel.mainInstance().track(event: "cookeis_unavailable_ wrong location and no cooks", properties: ["No prop" : "property"])
            cookiesAlert(message: "There are no cooks that are making cookies currently. Try again in the evening from 5pm to 9pm. There is more chance that we will be making cookies then! You also must be in a location that is in a 3.5 mile radius from the Greene Or the Reserve of Xenia to be able to order cookies. Thank you for your patience while we are getting this new business idea up and running!")
        } else if (!isNoahAvailable && isNoahRightLocation || !isIsaiahAvailable && isIsaiahRightLocation) && !(isIsaiahRightLocation && isNoahRightLocation) {
            Mixpanel.mainInstance().track(event: "cookeis_unavailable_ no cooks available", properties: ["No prop" : "property"])
            cookiesAlert(message: "There are no cooks that are making cookies currently. Try again in the evening from 5pm to 9pm. There is more chance that we will be making cookies then! Thank you for your patience while we are getting this new business idea up and running!")
        } else if !isNoahRightLocation && !isIsaiahRightLocation {
            Mixpanel.mainInstance().track(event: "cookeis_unavailable_ wrong location", properties: ["No prop" : "property"])
            cookiesAlert(message: "You must be in a location that is in a 3.5 mile radius from the Greene Or the Reserve of Xenia for you to be able to order cookies. We will hopefully be coming to a location closer to you soon! Thank you for your patience while we are getting this new business idea up and running!")
        } else {
            Mixpanel.mainInstance().track(event: "Selected Get Hot Cookies", properties: ["No prop" : "property"])
            var price = 1200
            if CookieUserDefaults().gotFreeCookies() == nil || !CookieUserDefaults().gotFreeCookies()! {
                price = 600
            }
            let controller = CheckoutViewController(product: "🍪", price: price, settings: settings.settings)
            self.navigationController!.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func didTapHamburgerButton(_ sender: Any) {
        if let drawerController = navigationController?.parent as? KYDrawerController {
            Mixpanel.mainInstance().track(event: "hamburger menu button", properties: ["No prop" : "property"])
            drawerController.setDrawerState(.opened, animated: true)
        }
    }
    
    @IBAction func tapIngredients(_ sender: Any) {
        Mixpanel.mainInstance().track(event: "ingredients_button", properties: ["No prop" : "property"])
        let message = "Unsalted butter, sugar, brown sugar, eggs, flour, ground oats, semisweet chocolate chips, vanilla, salt, baking powder, baking soda."
        let alertController = UIAlertController(title: "Ingredients", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Sounds Yummy!", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        timer.invalidate()
    }
    
    func createCustomerIfFirstTime() {
        let customerId = CookieUserDefaults().getCustomerId()
        if customerId == nil {
            MyAPIClient.sharedClient.createCustomer(completion: {(customerId:String) in
                CookieUserDefaults().setCustomerId(customorId: customerId)
            })
        }
    }
    
    @objc func checkLocation() {
        //check the server to see if a cook is available - change the button accordingly
        MyAPIClient.sharedClient.isCookAvailable() { isCookAvailable in
            MyAPIClient.sharedClient.isIsaiahAvailable() { isIsaiahAvailable in
                if self.loadingView!.isAnimating {       //just the first time hitting the timer
                    self.loadingView!.stopAnimating()
                    self.loadingView!.removeFromSuperview()
                    self.timer.invalidate()
                    self.timer = Timer.scheduledTimer(timeInterval: 15, target: self,        //reset to make it only check every 15 sec
                        selector: #selector(ViewController.checkLocation), userInfo: nil, repeats: true)
                }
                self.isNoahAvailable = isCookAvailable
                self.isIsaiahAvailable = isIsaiahAvailable
                self.isNoahRightLocation = self.locationChecker.doesRegionIncludeCurrentLocation()
                self.isIsaiahRightLocation = self.locationChecker.doesIsaiahRegionIncludeCurrentLocation()
                
                //set the different buttons based on location
                if !self.locationChecker.isLocationAuthorized() {
                    self.changeToNotAuthorizedButton()
                } else if !self.isNoahAvailable && !self.isIsaiahAvailable {
                    self.changeToWhyNoCookiesButton()
                } else if (self.isNoahRightLocation && self.isNoahAvailable) || (self.isIsaiahRightLocation && self.isIsaiahAvailable) {
                    self.changeToGetCookiesButton()
                } else {
                    self.changeToWhyNoCookiesButton()
                }
            }
        }
    }
    
    //an awesome animation thing! so cool!
    func changeToLoadingButton() {
        getCookiesButton.setTitle("", for: UIControlState())
        getCookiesButton.isEnabled = false
        getCookiesButton.layer.cornerRadius = 10
        getCookiesButton.backgroundColor = UIColor(red:0.7, green:0.16, blue:0.13, alpha:1.00)
        //start the animating
        if loadingView != nil {
            loadingView!.removeFromSuperview()
        }
        loadingView = NVActivityIndicatorView(frame: getCookiesButton.frame, type: NVActivityIndicatorType.pacman, color: NVActivityIndicatorView.DEFAULT_COLOR, padding: NVActivityIndicatorView.DEFAULT_PADDING)
        self.view.addSubview(loadingView!)
        loadingView!.startAnimating()
    }
    
    func changeToNotAuthorizedButton() {
        getCookiesButton.setTitle("Allow Location in Settings", for: UIControlState())
        getCookiesButton.isEnabled = false
        getCookiesButton.layer.cornerRadius = 10
        getCookiesButton.backgroundColor = UIColor(red:0.7, green:0.16, blue:0.13, alpha:1.00)
    }
    
    func changeToNotAvailableButton() {
        getCookiesButton.setTitle("Cookies Not Available", for: UIControlState())
        getCookiesButton.isEnabled = false
        getCookiesButton.layer.cornerRadius = 10
        getCookiesButton.backgroundColor = UIColor(red:0.7, green:0.16, blue:0.13, alpha:1.00)
    }
    
    func changeToGetCookiesButton() {
        getCookiesButton.setTitle("Get Hot Cookies!", for: UIControlState())
        getCookiesButton.isEnabled = true
        getCookiesButton.layer.cornerRadius = 10
        getCookiesButton.backgroundColor = UIColor(red:0.0, green:0.18, blue:0.41, alpha:1.00)
    }
    
    func changeToNoLocationButton() {
        getCookiesButton.setTitle("Must Be in Dayton Ohio", for: UIControlState())
        getCookiesButton.isEnabled = false
        getCookiesButton.layer.cornerRadius = 10
        getCookiesButton.backgroundColor = UIColor(red:0.7, green:0.16, blue:0.13, alpha:1.00)
//        getCookiesButton.layer.backgroundColor = UIColor(red:0.22, green:0.65, blue:0.91, alpha:1.00) as! CGColor

    }
    
    func changeToWhyNoCookiesButton() {
        getCookiesButton.setTitle("Why can't I get Cookies?", for: UIControlState())
        getCookiesButton.isEnabled = true
        getCookiesButton.layer.cornerRadius = 10
        getCookiesButton.backgroundColor = UIColor(red:0.7, green:0.16, blue:0.13, alpha:1.00)
    }
    
    func cookiesAlert(message:String) {
        let alertController = UIAlertController(title: "Why Cookies Aren't Available", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }


}

