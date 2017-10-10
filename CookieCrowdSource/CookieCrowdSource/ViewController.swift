//
//  ViewController.swift
//  CookieCrowdSource
//
//  Created by Noah Bragg on 8/19/17.
//  Copyright © 2017 Noah Bragg. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class ViewController: UIViewController {
    
    let settings = SettingsViewController()
    let locationChecker = LocationChecker()
    var timer = Timer()
    var loadingView:NVActivityIndicatorView?
    var isCookAvailable = false
    var isRightLocation = false

    @IBOutlet weak var getCookiesButton: UIButton!
    @IBOutlet weak var ingredientsButton: UIButton!
    
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

    @IBAction func tapCheckout(_ sender: Any) {
        if !isCookAvailable && !isRightLocation {
            cookiesAlert(message: "There are no cooks that are making cookies currently. Try again in the evening from 5pm to 9pm. There is more chance that we will be making cookies then! You also must be in a location that is in a 5 mile radius around the Greene to be able to order cookies. Thank you for your patience while we are getting this new business idea up and running!")
        } else if !isCookAvailable {
            cookiesAlert(message: "There are no cooks that are making cookies currently. Try again in the evening from 5pm to 9pm. There is more chance that we will be making cookies then! Thank you for your patience while we are getting this new business idea up and running!")
        } else if !isRightLocation {
            cookiesAlert(message: "You must be in a location that is in a 5 mile radius from the Greene for you to be able to order cookies. We will hopefully be coming to a location closer to you soon! Thank you for your patience while we are getting this new business idea up and running!")
        } else {
            var price = 1000
            if CookieUserDefaults().gotFreeCookies() == nil || !CookieUserDefaults().gotFreeCookies()! {
                price = 0
            }
            let controller = CheckoutViewController(product: "🍪", price: price, settings: settings.settings)
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func tapIngredients(_ sender: Any) {
        let message = "The cookies have this in them"
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
    
    func checkLocation() {
        //check the server to see if a cook is available - change the button accordingly
        MyAPIClient.sharedClient.isCookAvailable() { isCookAvailable in
            if self.loadingView!.isAnimating {       //just the first time hitting the timer
                self.loadingView!.stopAnimating()
                self.loadingView!.removeFromSuperview()
                self.timer.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 15, target: self,        //reset to make it only check every 30 sec
                    selector: #selector(ViewController.checkLocation), userInfo: nil, repeats: true)
            }
            self.isCookAvailable = isCookAvailable
            self.isRightLocation = self.locationChecker.doesRegionIncludeCurrentLocation()
            
            //set the different buttons based on location
            if !self.locationChecker.isLocationAuthorized() {
                self.changeToNotAuthorizedButton()
            } else if !isCookAvailable {
                self.changeToWhyNoCookiesButton()
            } else if self.isRightLocation {
                self.changeToGetCookiesButton()
            } else {
                self.changeToWhyNoCookiesButton()
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

