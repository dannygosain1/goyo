//
//  ViewController.swift
//  testLibrary
//
//  Created by Danny Gosain on 2018-01-29.
//  Copyright © 2018 Danny Gosain. All rights reserved.
//

import UIKit
import SwiftCharts

class ViewController: UIViewController {
    fileprivate var barchart: Chart?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        let chartConfig = BarsChartConfig(
            valsAxisConfig: ChartAxisConfig(from: 0, to: 8, by: 2)
        )

        let frame = CGRect(x: 10, y: 100, width: 300, height: 500)

        let chart = BarsChart(
            frame: frame,
            chartConfig: chartConfig,
            xTitle: "X axis",
            yTitle: "Y axis",
            bars: [
                ("A", 2),
                ("B", 4.5),
                ("C", 3),
                ("D", 5.4),
                ("E", 6.8),
                ("F", 0.5)
            ],
            color: UIColor.red,
            barWidth: 20
        )

        self.view.addSubview(chart.view)
        self.barchart = chart
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}



