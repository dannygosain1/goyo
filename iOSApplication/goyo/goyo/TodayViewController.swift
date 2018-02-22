//
//  ViewController.swift
//  goyo
//
//  Created by Danny Gosain on 2018-01-29.
//  Copyright © 2018 Danny Gosain. All rights reserved.
//

// Theme colors:
// navbar: #4286F4 or rgb(66, 134, 244)
// white: #FFFFFF or rgb(255, 255, 255)
// alternate color for pie: #e1e3e8 or rgb()


import UIKit
import Charts

class TodayViewController: UIViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var remainingText: UILabel!
    @IBOutlet weak var completedText: UILabel!
    
    @IBOutlet weak var todayPieView: PieChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // just temporary data
        let tempRemainingData : Int = 10 // expecting an int from the DB
        let tempRemainingStr = String(tempRemainingData)
        remainingText.text = "Remaining: " + tempRemainingStr + " minutes"
        
        let tempCompletedData : Int = 50
        let tempCompletedStr = String(tempCompletedData)
        completedText.text = "Completed: " + tempCompletedStr + " minutes"
        

        // CHARTS STUFF
        
        // setting up mock data
        let dataHeader = ["Completed", "Remaining"] // Headers for Legend if needed
        let activeMinutes = [50.0, 10.0] // enter values to appear on the graph, 
        setChart(dataPoints: dataHeader, values: activeMinutes)

        
        sideMenu()
        // Do any additional setup after loading the view.
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry1 = ChartDataEntry(x: Double(i), y: values[i], data: dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry1)
        }
        
        print(dataEntries[0].data)
        let pieChartDataSet = PieChartDataSet(values: dataEntries, label: "Active Minutes")
        let pieChartData = PieChartData(dataSet: pieChartDataSet)
        
        // colors for the graph
        var colors: [UIColor] = []
        
        let completedColor = UIColor(red: 66/255, green: 134/255, blue: 244/255, alpha: 1)
        let remainingColor = UIColor(red: 225/255, green: 227/255, blue: 232/255, alpha: 1)
        
        colors.append(completedColor)
        colors.append(remainingColor)
        
        pieChartDataSet.colors = colors
        
        // chart characteristics
        todayPieView.data = pieChartData
        todayPieView.chartDescription?.text = ""
        todayPieView.centerAttributedText = NSMutableAttributedString(string: "83%", attributes: [NSAttributedStringKey.foregroundColor:completedColor, NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light", size:38)!])
        todayPieView.legend.enabled = false
        
    }
    
    func sideMenu() {
        if revealViewController() != nil {
            menuButton.target = revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            revealViewController().rearViewRevealWidth = 275 // width of the side menu
            
            view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
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
