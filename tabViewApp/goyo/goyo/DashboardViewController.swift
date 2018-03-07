//
//  DashboardViewController.swift
//  goyo
//
//  Created by Danny Gosain on 2018-02-22.
//  Copyright © 2018 Danny Gosain. All rights reserved.
//

import UIKit
import Charts

class ViewController: UIViewController, CalendarViewDataSource, CalendarViewDelegate {
    
    @IBOutlet weak var calendarView: CalendarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Dashboard"  // setting title of the page
        self.view.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
