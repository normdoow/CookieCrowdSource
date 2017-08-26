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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func tapCheckout(_ sender: Any) {
        let controller = CheckoutViewController(product: "Cookies", price: 1000, settings: settings.settings)
        self.present(controller, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

