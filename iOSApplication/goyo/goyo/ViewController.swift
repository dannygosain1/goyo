//
//  ViewController.swift
//  goyo
//
//  Created by Danny Gosain on 2018-01-29.
//  Copyright © 2018 Danny Gosain. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var remainingText: UILabel!
    @IBOutlet weak var completedText: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tempRemainingData : Int = 10 // expecting an int from the DB
        var tempRemainingStr = String(tempRemainingData)
        remainingText.text = "Remaining: " + tempRemainingStr + " minutes"
        
        let tempCompletedData : Int = 50
        var tempCompletedStr = String(tempCompletedData)
        completedText.text = "Completed: " + tempCompletedStr + " minutes"
        
        sideMenu()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sideMenu() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275 // width of the side menu
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
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
