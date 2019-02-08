//
//  ViewController.swift
//  DeviceDiagnosticApp
//
//  Created by Globallogic on 01/02/19.
//  Copyright © 2019 Globallogic. All rights reserved.
//

import UIKit

enum AssetType {
    case BlueTooth
    case Sensor
    case Speaker
    case Mic
}

enum AssetWorkingStatus {
    case WorkingSuccessfully
    case FailedDueToFault
    case CouldNotIdentify
}

class ViewController: UIViewController,UITableViewDelegate {


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    
    @IBAction func bluetoothAction() {
        permissionBluetooth()
        performBluetoothOperation()
    }

    @IBAction func sensorAction() {
        
        
    }
    
    @IBAction func speakerAction() {
        performSpeakerOperation()
    }
    
    @IBAction func micAction() {
        performMicOperation()
    }
    
    
    //MARK: --- Bluetooth ----
    func permissionBluetooth(){
        let main = UIStoryboard(name: "Main", bundle: nil)
        guard let VC = main.instantiateViewController(withIdentifier: "BluetoothViewController") as? BluetoothViewController else{return}
        self.navigationController?.pushViewController(VC, animated: true)
    }
    
    func performBluetoothOperation() {
        
        
    }
    
    //MARK: --- Sensor ----
    func permissionSensor(){
        
    }
    
    func performBluetoothSensorOperation() {
        
        
    }
    
    
    //MARK: --- Speaker ----
    func permissionSpeaker(){
        

    }
    
    func performSpeakerOperation() {
        let main = UIStoryboard(name: "Main", bundle: nil)
        guard let VC = main.instantiateViewController(withIdentifier: "SpeakerViewController") as? SpeakerViewController else{return}
        self.navigationController?.pushViewController(VC, animated: true)
        
    }
    
    //MARK: --- Mic ----
    func permissionMic(){
        
    }
    
    func performMicOperation() {
        let main = UIStoryboard(name: "Main", bundle: nil)
        guard let VC = main.instantiateViewController(withIdentifier: "MicViewController") as? MicViewController else{return}
        self.navigationController?.pushViewController(VC, animated: true)

        
    }
}

