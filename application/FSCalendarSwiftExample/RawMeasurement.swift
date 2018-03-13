//
//  GatherData.swift
//  FSCalendarSwiftExample
//
//  Created by Danny Gosain on 2018-03-12.
//  Copyright © 2018 wenchao. All rights reserved.
//

import Foundation
import Bluejay

struct GatherData: Receivable {
    
    private var flags: UInt8 = 0
    private var measurement8bits: UInt8 = 0
    private var measurement16bits: UInt16 = 0
    private var energyExpended: UInt16 = 0
    private var rrInterval: UInt16 = 0
    
    private var isMeasurementIn8bits = true
    
    var measurement: Int {
        return isMeasurementIn8bits ? Int(measurement8bits) : Int(measurement16bits)
    }
    
    init(bluetoothData: Data) throws {
        flags = try bluetoothData.extract(start: 0, length: 1)
        
        isMeasurementIn8bits = (flags & 0b00000001) == 0b00000000
        
        if isMeasurementIn8bits {
            measurement8bits = try bluetoothData.extract(start: 1, length: 1)
        }
        else {
            measurement16bits = try bluetoothData.extract(start: 1, length: 2)
        }
    }
    
}
