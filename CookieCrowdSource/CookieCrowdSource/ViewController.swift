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

    @IBOutlet weak var getCookiesButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        changeToLoadingButton()
        
        timer = Timer.scheduledTimer(timeInterval: 5, target: self,
                             selector: #selector(ViewController.checkLocation), userInfo: nil, repeats: true)
    }

    @IBAction func tapCheckout(_ sender: Any) {
        let controller = CheckoutViewController(product: "🍪", price: 1000, settings: settings.settings)
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
        //check the server to see if a cook is available - change the button accordingly
        MyAPIClient.sharedClient.isCookAvailable() { isCookAvailable in
            if self.loadingView!.isAnimating {       //just the first time hitting the timer
                self.loadingView!.stopAnimating()
                self.loadingView!.removeFromSuperview()
                self.timer.invalidate()
                self.timer = Timer.scheduledTimer(timeInterval: 30, target: self,        //reset to make it only check every 30 sec
                    selector: #selector(ViewController.checkLocation), userInfo: nil, repeats: true)
            }
            
            //set the different buttons based on location
            if !self.locationChecker.isLocationAuthorized() {
                self.changeToNotAuthorizedButton()
            } else if !isCookAvailable {
                self.changeToNotAvailableButton()
            } else if self.locationChecker.doesRegionIncludeCurrentLocation() {
                self.changeToGetCookiesButton()
            } else {
                self.changeToNoLocationButton()
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


}

