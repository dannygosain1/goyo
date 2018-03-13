//
//  GatherData.swift
//  FSCalendarSwiftExample
//
//  Created by Danny Gosain on 2018-03-12.
//  Copyright © 2018 wenchao. All rights reserved.
//

import Foundation
import Bluejay
import SwiftProtobuf

struct RawMeasurement: Receivable {
    
    var fsr: UInt32 = 0
    var x: UInt32 = 0
    var y: UInt32 = 0
    var z: UInt32 = 0
    
    
    init(bluetoothData: Data) {
        let deserializedData = GoYoData(bluetoothData)
        fsr = deserializedData.fsr
        x = deserializedData.xAccel
        y = deserializedData.yAccel
        z = deserializedData.zAccel
    }
    
}
