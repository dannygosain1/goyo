//
//  LineChart.swift
//  FSCalendarSwiftExample
//
//  Created by Danny Gosain on 2018-03-07.
//  Copyright © 2018 wenchao. All rights reserved.
//

import UIKit
import Charts

class LineChart: UIView {
    let lineChartView = LineChartView()
    var lineDataEntry: [ChartDataEntry] = []
    
    var day = [String]()
    var activeMinutes = [String]()
    
    var delegate: GetChartData! {
        didSet {
            populateData()
            lineChartSetup()
        }
    }
    
    func populateData() {
        day = delegate.day
        activeMinutes = delegate.activeMinutes
    }
    
    func lineChartSetup() {
        self.backgroundColor = UIColor.white
        self.addSubview(lineChartView)
        lineChartView.translatesAutoresizingMaskIntoConstraints = false
        lineChartView.topAnchor.constraint(equalTo: self.topAnchor, constant: 20).isActive = true
        lineChartView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        lineChartView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        lineChartView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        setLineChart(dataPoints: day, values: activeMinutes)
    }
    
    func setLineChart(dataPoints: [String], values: [String]) {
        lineChartView.noDataTextColor = UIColor.white
        lineChartView.noDataText = "No data for the chart"
        lineChartView.backgroundColor = UIColor.white
        
        for i in 0..<dataPoints.count {
            let dataPoint = ChartDataEntry(x: Double(i), y: Double(values[i])!)
            lineDataEntry.append(dataPoint)
        }
        
        let chartDataSet = LineChartDataSet(values: lineDataEntry, label: "active minutes")
        let chartData = LineChartData()
        chartData.addDataSet(chartDataSet)
        chartData.setDrawValues(true)
        chartDataSet.colors = [UIColor.green]
        chartDataSet.setCircleColor(UIColor.green)
        chartDataSet.circleHoleColor = UIColor.green
        chartDataSet.circleRadius = 4.0

        
        lineChartView.data = chartData
    }
}
