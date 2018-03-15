//
//  DashboardViewController.swift
//  FSCalendarSwiftExample
//
//  Created by Danny Gosain on 2018-03-07.
//  Copyright © 2018 wenchao. All rights reserved.
//

import UIKit
import Charts
import SQLite

class DashboardViewController: UIViewController, ChartViewDelegate {
    
    
    @IBOutlet weak var barChartView: BarChartView!
    
    //    var months: [String]!
    var days: [String]!
    
    @IBOutlet weak var todayPieView: PieChartView!
    
    var goal = 5.0
    var activityCompleted = 44.0
    
    //midnight
    var midnight: Int64 = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // getting date components
        //For Start Date
        var calendar = NSCalendar.current
        calendar.timeZone = NSTimeZone.local //OR NSTimeZone.localTimeZone()
        let dateAtMidnight = calendar.startOfDay(for: NSDate() as Date)
        self.midnight = Int64(NSInteger(dateAtMidnight.timeIntervalSince1970) * 1000)
        
        
        var remainingMinutes = goal - activityCompleted
        
        // setting up mock data for pie chart
        let dataHeader = ["Completed", "Remaining"] // Headers for Legend if needed
        let activeMinutes = [activityCompleted, remainingMinutes]
        //        let activeMinutes = [String(completedMinutes) + " minutes completed", String(remainingMinutes) + "minutes remaining"] // enter values to appear on the graph,
        setPieChart(dataPoints: dataHeader, values: activeMinutes)
        
        // getting the last 10 days
        let cal = Calendar.current
        var date = cal.startOfDay(for: Date())
        var tempDays = [String]()
        for i in 1 ... 7 {
            let day = cal.component(.day, from: date)
            let month = cal.component(.month, from: date)
//            tempDays.append(String(month) + "/" + String(day))
//            date = cal.date(byAdding: .day, value: -1, to: date)!
        }
        
        // setting up mock data for bar chart
        
        days = tempDays.reversed()
        let active = [20.0, 44.0, 66.0, 33.0, 52.0, 36.0, 41.0, 48.0, 60.0, 55.0] // to be provided
        
        setBarChart(dataPoints: days, values: active)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        do {
         try updateUI()
        } catch {
            print("error updating pie chart")
        }
    }
    
    func updateUI() throws {
        print("updating UI now")
        var activeRowQuery = try GoYoDB.instance.results!
            .filter(GoYoDB.instance.frameStartTime >= self.midnight)
        
        let count = try GoYoDB.instance.db!.scalar(activeRowQuery.count)
        print(count)
        self.activityCompleted = Double(count)
        let dataHeader = ["Completed", "Remaining"]
        let remainingMinutes = goal - self.activityCompleted <= 0 ? 0 : goal - self.activityCompleted
        let activeMinutes = [self.activityCompleted, remainingMinutes]
        self.setPieChart(dataPoints: dataHeader, values: activeMinutes)
    }
    
    
    func setPieChart(dataPoints: [String], values: [Double]) {
        
        var remainingMinutes = goal - activityCompleted
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
        
        let completedColor = UIColor(red: 3/255, green: 37/255, blue: 78/255, alpha: 1)
        let remainingColor = UIColor(red: 189/255, green: 190/255, blue: 192/255, alpha: 1)
        
        colors.append(completedColor)
        colors.append(remainingColor)
        
        pieChartDataSet.colors = colors
        
        let percentCompletedBeforeTruncate = String(round(activityCompleted/goal * 100))
        let endIndex = percentCompletedBeforeTruncate.index(percentCompletedBeforeTruncate.endIndex, offsetBy: -2)
        let percentCompleted = percentCompletedBeforeTruncate.substring(to: endIndex) + "% Completed"
        
        
        // chart characteristics
        todayPieView.data = pieChartData
        todayPieView.chartDescription?.text = ""
        todayPieView.centerAttributedText = NSMutableAttributedString(string: percentCompleted, attributes: [NSAttributedStringKey.foregroundColor:completedColor, NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light", size:14)!])
        todayPieView.legend.enabled = false
        todayPieView.data?.setValueTextColor(UIColor.clear)
        
    }
    
    func setBarChart(dataPoints: [String], values: [Double]) {
        barChartView.noDataText = "No activity data available"
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i], data: dataPoints[i] as AnyObject)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(values: dataEntries, label: "Active Minutes")
        let chartData = BarChartData(dataSet: chartDataSet)
        chartDataSet.colors = [UIColor(red:84/255, green:86/255, blue:119/255, alpha:1)]
        chartDataSet.valueColors = [UIColor.clear]
        barChartView.data = chartData
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.granularity = 1
        barChartView.xAxis.setLabelCount(10, force: false)
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.labelFont = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.regular)
        barChartView.leftAxis.labelPosition = .outsideChart
        barChartView.leftAxis.labelFont = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.regular)
        barChartView.rightAxis.enabled = false
        barChartView.chartDescription?.text = ""
        barChartView.legend.colors = [UIColor(red:84/255, green:86/255, blue:119/255, alpha:1)]
        barChartView.drawValueAboveBarEnabled = false
        
        let limitLine = ChartLimitLine(limit: 0, label: "")
        limitLine.lineColor = UIColor.black.withAlphaComponent(0.3)
        limitLine.lineWidth = 2
        barChartView.rightAxis.addLimitLine(limitLine)
        
        // setting target line
        let ll = ChartLimitLine(limit: 60.0, label: "Goal") // to be provided
        barChartView.leftAxis.addLimitLine(ll)
        
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

