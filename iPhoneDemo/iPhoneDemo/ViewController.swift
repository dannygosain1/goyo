//
//  ViewController.swift
//  viewAccelerometerDataiPhone-Danny
//
//  Created by Danny Gosain on 2017-10-22.
//  Copyright © 2017 Danny Gosain. All rights reserved.
//

import UIKit
import CoreMotion // Library used to get accelerometer data

// UITextFieldDelegate is used to control the functionality of the keyboard
class ViewController: UIViewController, UITextFieldDelegate {
    
// Variable declaration
    var motionManager = CMMotionManager()
    var timestamprawData = [String]()
    // var fileName = "rawData.csv"
    var path: URL?
    var csvText = "x,y,z,timeStamp\n"

// UI Variable declaration

    @IBOutlet weak var fileNameInput: UITextField!
    
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var pauseButton: UIButton!
    
    @IBOutlet weak var recordingLabel: UILabel!
    
// Actions when app is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fileNameInput.delegate = self // setting view controller as the fileNameInput text fields' delegate
    }
    
// Actions when the view appears
    override func viewDidAppear(_ animated: Bool) {
        // Adding actions when the buttons are pressed
        playButton.addTarget(self, action: #selector(ViewController.playButtonTapped), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(ViewController.pauseButtonTapped), for: .touchUpInside)
        self.recordingLabel.isHidden = true // setting the recording label position as hidden by default
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
// Closes keyboard without action once "return" key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
// Actions after hitting play button
    func playButtonTapped() {
        self.csvText = "x,y,z,timeStamp\n" // resetting the csv text upon each tap to avoid duplicate data
        motionManager.accelerometerUpdateInterval = 1/24 // data interval
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            if let myData = data
            {
                print(myData) // prints the data on the console
                // copying data into the csv
                let newLine = "\(myData.acceleration.x),\(myData.acceleration.y),\(myData.acceleration.z),\(myData.timestamp)\n"
                self.csvText.append(newLine)
                self.recordingLabel.isHidden = false // showing the label while recording the data
            }
        }
    }

// Actions after hitting pause button
    func pauseButtonTapped() {
        motionManager.stopAccelerometerUpdates()
        self.recordingLabel.isHidden = true // hiding the recording label
        let documentsDirectory =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        // creating a current date and time string for unique file creation
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + "_" + String(hour!)  + "-" + String(minute!) + "-" +  String(second!)
        
        // creating file name with input in text field and current date/time
        let fileName = fileNameInput.text! + "_" + today_string + ".csv"
        print("Data saved as: " + fileName)
//        let fileName="rawData.csv"
        self.path =  NSURL(fileURLWithPath: documentsDirectory).appendingPathComponent(fileName)
        do {
            //try FileManager.default.createFile(atPath: self.path!.absoluteString, contents: csvText)
            try csvText.write(to: self.path!, atomically: true, encoding: String.Encoding.utf8) // creates the csv file
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
//        print (csvText)
    }
}
