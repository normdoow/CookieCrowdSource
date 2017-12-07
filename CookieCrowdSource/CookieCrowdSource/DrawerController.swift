//
//  DrawerController.swift
//  CookieCrowdSource
//
//  Created by Noah Bragg on 11/19/17.
//  Copyright © 2017 Noah Bragg. All rights reserved.
//

import Foundation
import UIKit
import KYDrawerController
import Mixpanel

class DrawerController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var newEmailField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var sendEmailButton: UIButton!
    @IBOutlet weak var availabilityLabel: UILabel!
    @IBOutlet weak var signOutButton: UIButton!
    @IBOutlet weak var explanationLabel: UILabel!
    @IBOutlet weak var bakerLoginLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var availableSwitch: UISwitch!
    
    private let NEW_EMAIL_FIELD = 1234567
    private var defaults = CookieUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.delegate = self
        emailField.delegate = self
        newEmailField.delegate = self
        newEmailField.tag = NEW_EMAIL_FIELD
        
        loginButton.layer.cornerRadius = 10
        sendEmailButton.layer.cornerRadius = 10
        
        if defaults.getBakerEmail() != nil && defaults.getBakerEmail() != "" {
            hideLogin()
        } else {
            showLogin()
        }
        if defaults.getAvailableToCustomers() != nil && defaults.getAvailableToCustomers()! {
            availableSwitch.isOn = true
            availabilityLabel.text = "Available to Customers"
        } else {
            availableSwitch.isOn = false
            availabilityLabel.text = "Not Available to Customers"
        }
    }
    @IBAction func tapLogin(_ sender: Any) {
        MyAPIClient.sharedClient.loginBaker(pw: passwordField.text!, email: emailField.text!, completionHandler: { (isCorrect: Bool) in
            if isCorrect {
                self.defaults.setBakerEmail(bakerEmail: self.emailField.text!)
                self.hideLogin()
                Mixpanel.mainInstance().track(event: "login_as_baker", properties: ["No prop" : "property"])
            } else {
                self.showAlert(title: "Invalid Login", message: "The Email or Password is incorrect.")
            }
        })
    }
    
    @IBAction func tapSendEmail(_ sender: Any) {
        newEmailField.resignFirstResponder()
        if(newEmailField.text! != "") {
            Mixpanel.mainInstance().track(event: "send_baker_interested_button", properties: ["No prop" : "property"])
            MyAPIClient.sharedClient.sendNewBakerEmail(email: newEmailField.text!, completionHandler: {(isSuccess: Bool) in
                if isSuccess {
                    self.showAlert(title: "Success", message: "We now have your email and will get in contact with you about making Crowd Cookies!")
                    self.newEmailField.text = ""
                } else {
                    self.showAlert(title: "Failure", message: "We failed to receive your email. Is it possible that your internet is down?")
                }
            })
        } else {
            showAlert(title: "No Email", message: "Please put your email in the field so we can get in contact with you!")
        }
    }
    
    @IBAction func tapSignOut(_ sender: Any) {
        let alertController = UIAlertController(title: "Are You Sure?", message: "Signing out will automatically turn off your availability for baking.", preferredStyle: .alert)
        let action2 = UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction) in
                MyAPIClient.sharedClient.changeBakerAvailability(isAvailableText: "No", bakerEmail: self.defaults.getBakerEmail()!, completionHandler: { (isSuccess: Bool) in
                    if isSuccess {
                        Mixpanel.mainInstance().track(event: "baker \(self.defaults.getBakerEmail()!) became unavailable", properties: ["No prop" : "property"])
                        self.showLogin()
                        self.defaults.setBakerEmail(bakerEmail: "")
                        self.defaults.setAvailableToCustomers(isAvailable: false)
                        self.availableSwitch.isOn = false
                        self.availabilityLabel.text = "Not Available to Customers"
                    } else {
                        self.showAlert(title: "Failure", message: "We failed to turn your availibility off")
                    }
                })
            })
        let action = UIAlertAction(title: "NO", style: .default, handler: nil)
        alertController.addAction(action)
        alertController.addAction(action2)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func switchChanged(_ sender: Any) {
        var message = "You are turning ON your availabilty to bake cookies. Are you sure you are ready to fulfill orders?"
        if !availableSwitch.isOn {
            message = "Are you sure that you want to turn OFF your availabilty to bake cookies?"
        }
        let alertController = UIAlertController(title: "Are You Sure?", message: message, preferredStyle: .alert)
        let action2 = UIAlertAction(title: "YES", style: .default, handler: { (action: UIAlertAction) in
            if self.availableSwitch.isOn {
                //send out request to server
                MyAPIClient.sharedClient.changeBakerAvailability(isAvailableText: "Yes", bakerEmail: self.defaults.getBakerEmail()!, completionHandler: { (isSuccess: Bool) in
                    if isSuccess {
                        Mixpanel.mainInstance().track(event: "baker \(self.defaults.getBakerEmail()!) became available", properties: ["No prop" : "property"])
                        self.availabilityLabel.text = "Available to Customers"
                        self.defaults.setAvailableToCustomers(isAvailable: true)
                    } else {
                        self.availableSwitch.isOn = !self.availableSwitch.isOn
                    }
                })
            } else {
                //send out request to server
                MyAPIClient.sharedClient.changeBakerAvailability(isAvailableText: "No", bakerEmail: self.defaults.getBakerEmail()!, completionHandler: { (isSuccess: Bool) in
                    if isSuccess {
                        Mixpanel.mainInstance().track(event: "baker \(self.defaults.getBakerEmail()!) became unavailable", properties: ["No prop" : "property"])
                        self.availabilityLabel.text = "Not Available to Customers"
                        self.defaults.setAvailableToCustomers(isAvailable: false)
                    } else {
                        self.availableSwitch.isOn = !self.availableSwitch.isOn
                    }
                })
            }
        })
        let action = UIAlertAction(title: "NO", style: .default, handler: { (action: UIAlertAction) in
            self.availableSwitch.isOn = !self.availableSwitch.isOn
        })
        alertController.addAction(action)
        alertController.addAction(action2)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func hideLogin() {
        containerView.isHidden = true
        availableSwitch.isHidden = false
        signOutButton.isHidden = false
        bakerLoginLabel.text = "Baker Dashboard"
    }
    
    func showLogin() {
        containerView.isHidden = false
        availableSwitch.isHidden = true
        signOutButton.isHidden = true
        bakerLoginLabel.text = "Baker Login"
    }
    
    ///////     delegate methods   ///////
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == NEW_EMAIL_FIELD {
            animateViewMoving(up: true, moveValue: 100)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == NEW_EMAIL_FIELD {
            animateViewMoving(up: false, moveValue: 100)
        }
    }
    
    ////        Helper methods      /////
    
    // Lifting the view up
    func animateViewMoving (up:Bool, moveValue :CGFloat){
        let movementDuration:TimeInterval = 0.3
        let movement:CGFloat = ( up ? -moveValue : moveValue)
        UIView.beginAnimations( "animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration )
        let rect = CGRect(origin: self.view.frame.origin, size: self.view.frame.size)
        self.view.frame = rect.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    
    func showAlert(title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
}
