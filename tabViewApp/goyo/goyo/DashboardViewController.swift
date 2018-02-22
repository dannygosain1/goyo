//
//  DashboardViewController.swift
//  goyo
//
//  Created by Danny Gosain on 2018-02-22.
//  Copyright © 2018 Danny Gosain. All rights reserved.
//

import UIKit
import Charts

class DashboardViewController: UIViewController {
    
    @IBOutlet weak var todayPieView: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Dashboard"  // setting title of the page
        
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
