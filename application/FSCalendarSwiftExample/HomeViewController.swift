//
//  HomeViewController.swift
//  FSCalendarSwiftExample
//
//  Created by Danny Gosain on 2018-03-06.
//  Copyright © 2018 wenchao. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var dailyGoal: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var starCosmos: CosmosView!
    @IBOutlet weak var message: UILabel!
    
    var goal = 60.0 // to be provided
    var activityCompleted = 38.0 // to be provided
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dailyGoal.text = "Daily Goal: " + String(goal) + " minutes"
        
        let rating = activityCompleted/goal * 5.0 // type double
        let activityLeft = goal - activityCompleted
        
        dailyGoal.text = "Daily Goal: " + String(Int(goal)) + " active minutes"
        
        
        if (rating <= 1.5) {
            image.image = UIImage(named: "old-man-sad.png")
            message.text = "Let's get going, you still have " + String(Int(activityLeft)) + " active minutes left."
        } else if (rating > 1.5 && rating < 4) {
            image.image = UIImage(named: "old-man-happy.png")
            message.text = "Keep up the good work, you only have " + String(Int(activityLeft)) + " active minutes left."
        } else if (rating >= 4 && rating < 5){
            image.image = UIImage(named: "old-man-very-happy.png")
            message.text = "You're ALMOST there, only " + String(Int(activityLeft)) + " active minutes left."
        } else if (rating == 5) {
            image.image = UIImage(named: "old-man-very-happy.png")
            message.text = "Congratulations on the 5 stars, you have reached your daily activity goal."
        } else {
            image.image = UIImage(named: "old-man-happy.png")
            message.text = " "
        }
        
        starCosmos.rating = rating
        starCosmos.settings.updateOnTouch = false
        
        message.numberOfLines = 0
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

