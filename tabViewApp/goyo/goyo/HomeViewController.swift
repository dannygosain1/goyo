//
//  HomeViewController.swift
//  goyo
//
//  Created by Danny Gosain on 2018-02-22.
//  Copyright © 2018 Danny Gosain. All rights reserved.
//
// tab bar color: UIColor(red: 66/255, green: 134/255, blue: 244/255, alpha: 1)
// background colour: #f7f7f7 or UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)

import UIKit
import Cosmos

class HomeViewController: UIViewController {

    
    @IBOutlet weak var dailyGoal: UILabel!
    @IBOutlet weak var starCosmos: CosmosView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var message: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)  // setting the background colour
        self.title = "Home" // setting title of the page
        
        let goal = 60.0
        var rating = 1.0 // var type double
        let activityLeft = (5-rating)/5 * 60
        
        dailyGoal.font = UIFont.boldSystemFont(ofSize: dailyGoal.font.pointSize) // making it bold
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
