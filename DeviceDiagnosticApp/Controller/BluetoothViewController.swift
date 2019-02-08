//
//  BluetoothViewController.swift
//  DeviceDiagnosticApp
//
//  Created by Globallogic on 01/02/19.
//  Copyright © 2019 Globallogic. All rights reserved.
//

import UIKit
import CoreBluetooth


class BluetoothViewController: UIViewController {
    
    
    var manager: CBCentralManager!
    var device: CBPeripheral?
    var characteristics: [CBCharacteristic]?
    var serviceUUID = "1234"
    var char1 = "FFE1"
    let deviceName = "HMSoft"
    var connected = CBPeripheralState.connected
    var disconnected = CBPeripheralState.disconnected

    
    //Define class variable in your VC/AppDelegate
    var bluetoothPeripheralManager: CBPeripheralManager?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bluetoothSetup()
    }
    
    func bluetoothSetup() {
        
        let options = [CBCentralManagerOptionShowPowerAlertKey:1] //<-this is the magic bit!
        bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: options)
    }
    @IBAction func connectToDevice() {
        manager = CBCentralManager(delegate: self, queue: nil)
    }
    
//    func requestBluetoothPermission() {
//        
//        let showPermissionAlert = 1
//        let options = [CBCentralManagerOptionShowPowerAlertKey: showPermissionAlert]
//        bluetoothPeripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: options)
//    }
}

extension BluetoothViewController: CBPeripheralManagerDelegate,CBPeripheralDelegate,CBCentralManagerDelegate{
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
    }
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch (central.state) {
        case .unsupported:
            print("BLE is unsupported")
        case .unauthorized:
            print("BLE is unauthorized")
        case .unknown:
            print("BLE is unknown")
        case .resetting:
            print("BLE is reseting")
        case .poweredOff:
            print("BLE is powered off")
        case .poweredOn:
            print("BLE is powered on")
            manager.scanForPeripherals(withServices: nil, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        //print("\(peripheral.name)")
        
        if let data = advertisementData["kCBAdvDataManufacturerData"] as? Any {
            if let newdata = data as? String {
                print(newdata)
            }
        }
        if let peripheralName = advertisementData[CBAdvertisementDataLocalNameKey] as? String {
            
            if peripheralName == self.deviceName {
                
                // save a reference to the sensor tag
                self.device = peripheral
                self.device!.delegate = self
                
                // Request a connection to the peripheral
                
                self.manager.connect(self.device!, options: nil)
                
                print("Check")
            }
        }
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        var statusMessage = ""
        
        switch peripheral.state {
        case .poweredOn:
            statusMessage = "Bluetooth Status: Turned On"
            
        case .poweredOff:
            statusMessage = "Bluetooth Status: Turned Off"
            
        case .resetting:
            statusMessage = "Bluetooth Status: Resetting"
            
        case .unauthorized:
            statusMessage = "Bluetooth Status: Not Authorized"
            
        case .unsupported:
            statusMessage = "Bluetooth Status: Not Supported"
            
        case .unknown:
            statusMessage = "Bluetooth Status: Unknown"
        }
        
        print(statusMessage)
        
        if peripheral.state == .poweredOff {
            
        }else if peripheral.state == .poweredOn {
            
        }
    }
}

