//
//  ViewController.swift
//  viewAccelerometerDataiPhone-Danny
//
//  Created by Danny Gosain on 2017-10-22.
//  Copyright © 2017 Danny Gosain. All rights reserved.
//

import UIKit
import CoreMotion

class ViewController: UIViewController {
    
    var motionManager = CMMotionManager()
    var timestamprawData = [String]()
    var fileName = "rawData.csv"
    var path: URL?
    var csvText = "x,y,z,timeStamp\n"
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var pauseButton: UIButton!
    
    
    func playButtonTapped() {
        motionManager.accelerometerUpdateInterval = 0.2 // update data interval
        motionManager.startAccelerometerUpdates(to: OperationQueue.current!) { (data, error) in
            if let myData = data
            {
                print(myData)
                let newLine = "\(myData.acceleration.x),\(myData.acceleration.y),\(myData.acceleration.z),\(myData.timestamp)\n"
                self.csvText.append(newLine)
            }
        }
        
    }
    
    func pauseButtonTapped() {
        motionManager.stopAccelerometerUpdates()
        do {
            //try FileManager.default.createFile(atPath: self.path!.absoluteString, contents: csvText)
            try csvText.write(to: self.path!, atomically: true, encoding: String.Encoding.utf8)
            
        } catch {
            print("Failed to create file")
            print("\(error)")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let documentsDirectory =  NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        self.path =  NSURL(fileURLWithPath: documentsDirectory).appendingPathComponent(self.fileName)
        playButton.addTarget(self, action: #selector(ViewController.playButtonTapped), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(ViewController.pauseButtonTapped), for: .touchUpInside)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

