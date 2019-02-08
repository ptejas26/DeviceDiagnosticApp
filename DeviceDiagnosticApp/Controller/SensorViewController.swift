//
//  SensorViewController.swift
//  DeviceDiagnosticApp
//
//  Created by Tejas Patelia on 01/02/19.
//  Copyright © 2019 Tejas Patelia. All rights reserved.
//

import UIKit
import CoreMotion

class SensorViewController: UIViewController {
    
    
    //MARK: --- IBOulet ----

    weak var senseDelegate : DiagnosticStatusDelegate?
    
    //MARK: --- Variable ----

    
    let motionManager = CMMotionManager()
    var accelData = false
    var gyroData = false
    
    //MARK: --- View methods ----

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sensor Diagnostic"
    }
    
    
    //MARK: --- Functional methods ----

    
    func motionData() {
        if motionManager.isAccelerometerAvailable{
            
            motionManager.accelerometerUpdateInterval = 2.0
            motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (accelerometerData, error) in
                guard let accelerometerData = accelerometerData else {
                    /// Report an error.
                    self.accelData = false
                    return
                }
                accelerometerData.accessibilityActivate()
                self.accelData = true
            }
        }
        
        if motionManager.isGyroAvailable{
            
            motionManager.gyroUpdateInterval = 2.0
            motionManager.startGyroUpdates(to: OperationQueue.main, withHandler: { (gData, error) in
                
                guard let accelerometerData = gData else {
                    /// Report an error.
                    self.gyroData = false
                    return
                }
                accelerometerData.accessibilityActivate()
                self.gyroData = true
            })
        }
        defer {
            if self.gyroData && self.accelData {
                successAction(sender: UIButton())
            }else{
                failureAction(sender: UIButton())
            }
        }
    }
    
    //MARK: --- Action methods ----

    @IBAction func sensorAction() {
        motionData()
    }
    
    @IBAction func successAction(sender: UIButton) {

        senseDelegate?.returnDiagnosticStatus(.WorkingSuccessfully, assetType: .Sensor)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func failureAction(sender: UIButton) {
        senseDelegate?.returnDiagnosticStatus(.FailedDueToFault, assetType: .Sensor)
        self.navigationController?.popViewController(animated: true)
        
    }

}


