//
//  ViewController.swift
//  goyo
//
//  Created by Danny Gosain on 2018-01-16.
//  Copyright © 2018 Danny Gosain. All rights reserved.
//

import UIKit
import Charts

class ViewController: UIViewController {
    @IBOutlet weak var txtTextBox: UITextField!
    @IBOutlet weak var chtChart: LineChartView!
    
    var numbers : [Double] = [] // storage for all the numbers
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func btnbutton(_ sender: Any) {
        let input  = Double(txtTextBox.text!) // gets input from the textbox as double or int
        numbers.append(input!) // adds value to the array
        updateGraph()
    }
    
    
    func updateGraph() {
        var lineChartEntry = [ChartDataEntry]() //array to be displayed on the graph
        for i in 0..<numbers.count {
            let value = ChartDataEntry(x: Double(i), y: numbers[i]) // setting the x and y values
            lineChartEntry.append(value) // adding values to the dataset
        }
        let line1 = LineChartDataSet(values: lineChartEntry, label: "Number") // converts lineChartEntry to a LineChartDataSet
        line1.colors = [NSUIColor.blue] // sets the color of the line
        let data = LineChartData() // the object added to the chart
        data.addDataSet(line1) // adds line1 to the dataset
        chtChart.data = data // adds the data on the view and updates
        chtChart.chartDescription?.text = "Sample Line Chart - Danny"
    }
}

