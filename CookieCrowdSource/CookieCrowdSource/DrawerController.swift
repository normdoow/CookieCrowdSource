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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordField.delegate = self
        emailField.delegate = self
        newEmailField.delegate = self
        
        loginButton.layer.cornerRadius = 10
        sendEmailButton.layer.cornerRadius = 10
    }
    @IBAction func tapLogin(_ sender: Any) {
        
    }
    
    @IBAction func tapSendEmail(_ sender: Any) {
        
    }
    
    //delegate method for keyboard finished
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
