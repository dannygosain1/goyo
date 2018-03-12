//
//  DashboardViewController.swift
//  FSCalendarSwiftExample
//
//  Created by Danny Gosain on 2018-03-07.
//  Copyright © 2018 wenchao. All rights reserved.
//

import UIKit
import Charts

class DashboardViewController: UIViewController, ChartViewDelegate {
    

    @IBOutlet weak var barChartView: BarChartView!
    
//    var months: [String]!
    var days: [String]!
    
    @IBOutlet weak var todayPieView: PieChartView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setting up mock data for pie chart
        let dataHeader = ["Completed", "Remaining"] // Headers for Legend if needed
        let activeMinutes = [50.0, 10.0] // enter values to appear on the graph,
        setChart(dataPoints: dataHeader, values: activeMinutes)
        
        // getting the last 10 days
        let cal = Calendar.current
        var date = cal.startOfDay(for: Date())
        var tempDays = [String]()
        for i in 1 ... 10 {
            let day = cal.component(.day, from: date)
            let month = cal.component(.month, from: date)
            tempDays.append(String(month) + "/" + String(day))
            date = cal.date(byAdding: .day, value: -1, to: date)!
        }
        
        // setting up mock data for bar chart

        days = tempDays.reversed()
        let active = [20.0, 44.0, 66.0, 33.0, 52.0, 36.0, 41.0, 48.0, 60.0, 55.0] // to be provided
        
        setBarChart(dataPoints: days, values: active)
        
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
        barChartView.data = chartData
        barChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
        barChartView.xAxis.labelPosition = .bottom
        barChartView.xAxis.granularity = 1
        barChartView.xAxis.setLabelCount(10, force: false)
        barChartView.xAxis.drawGridLinesEnabled = false
        barChartView.xAxis.labelFont = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.regular)
        barChartView.leftAxis.labelPosition = .outsideChart
        barChartView.leftAxis.labelFont = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.regular)
        barChartView.rightAxis.enabled = false
        barChartView.chartDescription?.text = ""
        
        chartDataSet.colors = [UIColor(red:12/255, green:219/255, blue:94/255, alpha:1)]
        
        let limitLine = ChartLimitLine(limit: 0, label: "")
        limitLine.lineColor = UIColor.black.withAlphaComponent(0.3)
        limitLine.lineWidth = 1
        barChartView.rightAxis.addLimitLine(limitLine)
        
        // setting target line
        let ll = ChartLimitLine(limit: 60.0, label: "Goal") // to be provided
        barChartView.leftAxis.addLimitLine(ll)
       
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
        
        let completedColor = UIColor(red: 12/255, green: 219/255, blue: 94/255, alpha: 1)
        let remainingColor = UIColor(red: 225/255, green: 227/255, blue: 232/255, alpha: 1)
        
        colors.append(completedColor)
        colors.append(remainingColor)
        
        pieChartDataSet.colors = colors
        
        // chart characteristics
        todayPieView.data = pieChartData
        todayPieView.chartDescription?.text = ""
        todayPieView.centerAttributedText = NSMutableAttributedString(string: "83%", attributes: [NSAttributedStringKey.foregroundColor:completedColor, NSAttributedStringKey.font: UIFont(name: "HelveticaNeue-Light", size:28)!])
        todayPieView.legend.enabled = false
        
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
