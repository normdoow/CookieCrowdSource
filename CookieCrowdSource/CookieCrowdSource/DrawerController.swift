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

class DrawerController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var newEmailField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var sendEmailButton: UIButton!
    
    private var NEW_EMAIL_FIELD = 1234567
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.delegate = self
        emailField.delegate = self
        newEmailField.delegate = self
        newEmailField.tag = NEW_EMAIL_FIELD
        
        loginButton.layer.cornerRadius = 10
        sendEmailButton.layer.cornerRadius = 10
    }
    @IBAction func tapLogin(_ sender: Any) {
        //TODO actually implent this functionality
        showAlert(title: "Invalid Login", message: "The Email or Password is incorrect.")
    }
    
    @IBAction func tapSendEmail(_ sender: Any) {
        newEmailField.resignFirstResponder()
        if(newEmailField.text! != "") {
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
