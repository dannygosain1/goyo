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
    
    var fsr: Int32 = 0
    var x: Int32 = 0
    var y: Int32 = 0
    var z: Int32 = 0
    var millis: Int32 = 0
    
    
    init(bluetoothData: Data) {
        do {
            if(bluetoothData.count <= 4) { // millis
                let b64data = bluetoothData.base64EncodedString()
                if let decodedData = NSData(base64Encoded: b64data, options: .ignoreUnknownCharacters) {
                    let decodedString = NSString(data: decodedData as Data, encoding: String.Encoding.utf8.rawValue)
                    millis = decodedString!.intValue
                    
                }
            } else {
                let b64data = bluetoothData.base64EncodedString()
                let data = b64data.data(using: .utf8, allowLossyConversion: false)
                if let decodedData = NSData(base64Encoded: b64data, options: .ignoreUnknownCharacters) {
                    let decodedString = NSString(data: decodedData as Data, encoding: String.Encoding.utf8.rawValue)
                    let deserializedData = try? GoYoData(serializedData: decodedData as Data)
                    if deserializedData != nil {
                        fsr = deserializedData!.fsr
                        x = deserializedData!.xAccel
                        y = deserializedData!.yAccel
                        z = deserializedData!.zAccel
                    } else {
                        print("Failed to decode")
                        let b64data = bluetoothData.base64EncodedString()
                        if let decodedData = NSData(base64Encoded: b64data, options: .ignoreUnknownCharacters) {
                            let decodedString = NSString(data: decodedData as Data, encoding: String.Encoding.utf8.rawValue)
                            if try decodedString?.intValue != nil {
                                millis = decodedString!.intValue
                            }
                        }
                    }
                    print(fsr)
                }
            }
        } catch is SwiftProtobuf.BinaryDecodingError {
            debugPrint("Could not decode binary to raw data")
        } catch {
            debugPrint("error getting raw data")
        }
//        var binaryStr: String = ""
//        for hex in hexData {
//            binaryStr.append(String(hex, radix: 2))
//        }
//        let binaryData: Data? = binaryStr.data(using: .utf8, allowLossyConversion: false)

    }
    
}
