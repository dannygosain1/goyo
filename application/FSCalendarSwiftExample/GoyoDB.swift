//
//  sharedData.swift
//  FSCalendarSwiftExample
//
//  Created by Danny Gosain on 2018-03-14.
//  Copyright © 2018 wenchao. All rights reserved.
//

import Foundation
import SQLite

struct GoYoDB {
    static let instance = GoYoDB()
    let db: Connection?
    
    var results: Table?
    let frameStartTime = Expression<Int64>("start_time")
    let frameEndTime = Expression<Int64>("end_time")
    
    
    var raw_data: Table?
    let xAcc = Expression<Double>("x_acc")
    let yAcc = Expression<Double>("y_acc")
    let zAcc = Expression<Double>("z_acc")
    var timestamp = Expression<Int64>("timestamp")
    let fsr = Expression<Int64>("fsr")
    
    
    var features: Table?
    let xMean = Expression<Double>("x_mean")
    let yMean = Expression<Double>("y_mean")
    let zMean = Expression<Double>("z_mean")
    let xVariance = Expression<Double>("x_var")
    let yVariance = Expression<Double>("y_var")
    let zVariance = Expression<Double>("z_var")
    let isWalking = Expression<Bool>("is_walking")
    let windowStart = Expression<Int64>("window_start")
    let windowEnd = Expression<Int64>("window_end")
    let medianFsr = Expression<Double>("median_fsr")
    private init() {
        do {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            
            db = try Connection("\(path)/goyo.sqlite3")
            
            results = Table("results")
            try db!.run(results!.drop(ifExists: true))
            
            try db!.run(results!.create(ifNotExists: true) { t in
                t.column(frameStartTime)
                t.column(frameEndTime)
            })
            
            
            raw_data = Table("raw_data")
            
            try db!.run(raw_data!.drop(ifExists: true)) // TODO: Delete in prod
            
            try db!.run(raw_data!.create(ifNotExists: true) { t in
                t.column(xAcc)
                t.column(yAcc)
                t.column(zAcc)
                t.column(fsr)
                t.column(timestamp)
            })
            
            features = Table("features")
            try db!.run(features!.create(ifNotExists: true) { t in
                t.column(xMean)
                t.column(yMean)
                t.column(zMean)
                t.column(xVariance)
                t.column(yVariance)
                t.column(zVariance)
                t.column(medianFsr)
                t.column(isWalking)
                t.column(windowStart)
                t.column(windowEnd)
            })
        } catch {
            fatalError("unable to create db")
        }
    }
}
