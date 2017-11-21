//
//  RatingController.swift
//  CookieCrowdSource
//
//  Created by Noah Bragg on 11/20/17.
//  Copyright © 2017 Noah Bragg. All rights reserved.
//

import UIKit
import Cosmos

class RatingController: UIViewController {

    @IBOutlet weak var starRatingView: CosmosView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        starRatingView.settings.updateOnTouch = true
        starRatingView.settings.fillMode = .full
        starRatingView.settings.starSize = 55
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
