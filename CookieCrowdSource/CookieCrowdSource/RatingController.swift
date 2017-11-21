//
//  RatingController.swift
//  CookieCrowdSource
//
//  Created by Noah Bragg on 11/20/17.
//  Copyright © 2017 Noah Bragg. All rights reserved.
//

import UIKit
import Cosmos

class RatingController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var starRatingView: CosmosView!
    @IBOutlet weak var timelabel: UILabel!
    @IBOutlet weak var commentsText: UITextView!
    
    private var timer = Timer()
    private var time = 40
    
    override func viewDidLoad() {
        super.viewDidLoad()
        starRatingView.settings.updateOnTouch = true
        starRatingView.settings.fillMode = .full
        starRatingView.settings.starSize = 55
        
        commentsText.delegate = self
        
        timer = Timer.scheduledTimer(timeInterval: 60, target: self,
                                     selector: #selector(RatingController.updateTime), userInfo: nil, repeats: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tapSubmitButton(_ sender: Any) {
        if commentsText.text == "" {
            showAlert(title: "No Comment", message: "Please add a comment to your rating. We really appreciate your feedback!")
        } else {
            MyAPIClient.sharedClient.sendRatingEmail(rating: String(format:"%.0f", starRatingView.rating), comments: commentsText.text,
                                                     completionHandler: {(success: Bool) in
//                    if success {
                        self.dismiss(animated: true, completion: nil)
//                    } else {
//                        showAlert(title: "Failed to send", message: "Failed to send")
//                    }
                })
        }
    }
    
    @IBAction func tapSkipButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func updateTime() {
        if(time >= 0) {
            timelabel.text = "\(time) min."
            time -= 1
        }
    }
    
    ///////     delegate methods   ///////
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        animateViewMoving(up: true, moveValue: 130)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        animateViewMoving(up: false, moveValue: 130)
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
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
