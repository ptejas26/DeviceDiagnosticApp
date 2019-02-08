//
//  ViewController.swift
//  DeviceDiagnosticApp
//
//  Created by Tejas Patelia on 01/02/19.
//  Copyright © 2019 Tejas Patelia. All rights reserved.
//

import UIKit

enum AssetType:String{
    case BlueTooth = "Bluetooth",
    Sensor = "Sensor",
    Speaker = "Speaker",
    Mic = "Mic"
}

enum AssetTypeClicked : Int{
    case BlueTooth = 0,
    Sensor,
    Speaker,
    Mic
}

enum AssetWorkingStatus : Int{
    case WorkingSuccessfully = 0,
    FailedDueToFault,
    Initial
}

class AssetDetailsModel{
    var asset : AssetType?
    var status : AssetWorkingStatus?
    
    init(asset:AssetType,status:AssetWorkingStatus) {
        self.asset = asset
        self.status = status
    }
}

class ViewController : UIViewController{
    
    //MARK: --- Variables ----

    var assetArray : [AssetDetailsModel] = [AssetDetailsModel]()
    
    //MARK: --- Outlets ----

    @IBOutlet weak var colletionView : UICollectionView!
    @IBOutlet weak var totalLabel : UILabel!

    //MARK: --- View methods ----

    override func viewDidLoad() {
        super.viewDidLoad()
        
        assetArray = [AssetDetailsModel(asset: .BlueTooth, status: .Initial),AssetDetailsModel(asset: .Sensor, status: .Initial),AssetDetailsModel(asset: .Speaker, status: .Initial),AssetDetailsModel(asset: .Mic, status: .Initial)]
        colletionView.delegate = self
        colletionView.dataSource = self
        self.title = "Device Diagnostic App"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calculateTotal()
    }
    
    //MARK: --- Functional Method ----

    func calculateTotal() {
        var tot = 0
        for itm in self.assetArray where itm.status == .WorkingSuccessfully{
            tot = tot + 1
        }
        self.totalLabel.text = "Total number of successful assets: "+"\(tot)"
    }
    //MARK: --- Bluetooth ----
    func performBluetoothOperation(){
        let main = UIStoryboard(name: "Main", bundle: nil)
        guard let BlueVC = main.instantiateViewController(withIdentifier: "BluetoothViewController") as? BluetoothViewController else{return}
        BlueVC.blueDelegate = self
        self.navigationController?.pushViewController(BlueVC, animated: true)
    }
    
    //MARK: --- Sensor ----
    
    func performSensorOperation(){
        let main = UIStoryboard(name: "Main", bundle: nil)
        guard let senseVC = main.instantiateViewController(withIdentifier: "SensorViewController") as? SensorViewController else{return}
        senseVC.senseDelegate = self
        self.navigationController?.pushViewController(senseVC, animated: true)
    }
    //MARK: --- Speaker ----

    func performSpeakerOperation() {
        let main = UIStoryboard(name: "Main", bundle: nil)
        guard let speakerVC = main.instantiateViewController(withIdentifier: "SpeakerViewController") as? SpeakerViewController else{return}
        speakerVC.speakerDelegate = self
        self.navigationController?.pushViewController(speakerVC, animated: true)
    }
    
    //MARK: --- Mic ----
    func performMicOperation() {
        let main = UIStoryboard(name: "Main", bundle: nil)
        guard let MicVC = main.instantiateViewController(withIdentifier: "MicViewController") as? MicViewController else{return}
        MicVC.audioDelegate = self
        self.navigationController?.pushViewController(MicVC, animated: true)
    }
}

//MARK: --- Collection data source and delegate ----

extension ViewController : UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assetArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = colletionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as? CollectionCell else{return UICollectionViewCell()}
        
        cell.titleLabel.text = assetArray[indexPath.row].asset?.rawValue
        
        switch assetArray[indexPath.row].status!
        {
        case .WorkingSuccessfully:
            cell.layer.borderColor = UIColor.green.cgColor
            cell.layer.borderWidth = 2.0
            cell.layer.cornerRadius = 5.0

            break

        case .FailedDueToFault:
            cell.layer.borderColor = UIColor.red.cgColor
            cell.layer.borderWidth = 2.0
            cell.layer.cornerRadius = 5.0

            break

        case .Initial:

            cell.layer.borderColor = UIColor.orange.cgColor
            cell.layer.borderWidth = 0.0
            cell.layer.cornerRadius = 0.0

            break
        }
        cell.imageview.image = UIImage(named: "\(assetArray[indexPath.row].asset!.rawValue)")

        cell.titleStatus.text = "Status"
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case AssetTypeClicked.BlueTooth.rawValue:
            performBluetoothOperation()
            break
        case AssetTypeClicked.Speaker.rawValue:
            performSpeakerOperation()
            break
        case AssetTypeClicked.Sensor.rawValue:
            performSensorOperation()
            break
        case AssetTypeClicked.Mic.rawValue:
            performMicOperation()
            break
        default:
            break
        }
    }
}


//MARK: --- DiagnosticStatusDelegate ----
extension ViewController: DiagnosticStatusDelegate {
    func returnDiagnosticStatus(_ status: AssetWorkingStatus, assetType: AssetType) {
        switch assetType {
        case .BlueTooth:
            reloadIndexPathWith(indexpath: IndexPath(item: AssetTypeClicked.BlueTooth.rawValue, section: 0), status: status)
            break
        case .Sensor:
            reloadIndexPathWith(indexpath: IndexPath(item: AssetTypeClicked.Sensor.rawValue, section: 0), status: status)
            
            break
        case .Mic:
            reloadIndexPathWith(indexpath: IndexPath(item: AssetTypeClicked.Mic.rawValue, section: 0), status: status)
            
            break
        case .Speaker:
            reloadIndexPathWith(indexpath: IndexPath(item: AssetTypeClicked.Speaker.rawValue, section: 0), status: status)
            
            break
        default:
            print("No Assets")
        }
    }
    
    func reloadIndexPathWith(indexpath: IndexPath, status: AssetWorkingStatus) {
        if status == .WorkingSuccessfully {
            assetArray[indexpath.row].status = .WorkingSuccessfully
            
        } else if status == .FailedDueToFault {
            assetArray[indexpath.row].status = .FailedDueToFault
        }
        reloadIndexPath(indexpath:indexpath)
    }
    
    func reloadIndexPath(indexpath: IndexPath){
        
        self.colletionView.reloadItems(at: [indexpath])
    }
    
    
}
