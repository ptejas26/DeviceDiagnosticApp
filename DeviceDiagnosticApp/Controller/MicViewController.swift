//
//  MicViewController.swift
//  DeviceDiagnosticApp
//
//  Created by Tejas Patelia on 01/02/19.
//  Copyright © 2019 Tejas Patelia. All rights reserved.
//

import UIKit
import AVFoundation

protocol DiagnosticStatusDelegate : AnyObject{
    func returnDiagnosticStatus(_ status : AssetWorkingStatus, assetType : AssetType)
}

class MicViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    
    
    //MARK: --- IBOUTLETS ---
    
    @IBOutlet weak var lblStatus : UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    
    @IBOutlet weak var successButton: UIButton!
    @IBOutlet weak var failedButton: UIButton!
    
    //MARK: --- VARIABLES ---
    
    var audioPlayer : AVAudioPlayer?
    var audioRecorder : AVAudioRecorder?
    weak var audioDelegate : DiagnosticStatusDelegate?
    var statusFlag = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRecording()
        self.title = "Mic Diagnostic"

    }
    
    //MARK: --- Functional Methods ---
    
    func configureRecording() {
        
        // getting URL path for audio
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docDir = dirPath[0] as! String
        let soundFileURL = getDocumentsDirectory().appendingPathComponent("sound.caf")
        //print(soundFileURL)
        
        //Setting for recorder
        let recordSettings = [AVEncoderAudioQualityKey: AVAudioQuality.min.rawValue,
                              AVEncoderBitRateKey: 16,
                              AVNumberOfChannelsKey : 2,
                              AVSampleRateKey: 44100.0] as [String : Any]
        var error : NSError?
        let audioSession = AVAudioSession.sharedInstance()
        
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.spokenAudio, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        } catch {
            print(error)
        }
        if let err = error{
            print("audioSession error: \(err.localizedDescription)")
        }
        do {
            audioRecorder = try AVAudioRecorder(url: soundFileURL as URL, settings: recordSettings as [String : Any])
        } catch {
            print(error)
        }
        
        
        if let err = error{
            print("audioSession error: \(err.localizedDescription)")
        }else{
            audioRecorder?.prepareToRecord()
        }
    }
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    //MARK: --- Action Methods ---
    
    //record audio
    @IBAction func recordAudio(sender: UIButton) {
        
        if audioRecorder?.isRecording == false{
            lblStatus.text = "8 Seconds' recording has started..."
            audioRecorder?.record()
            audioRecorder?.delegate  = self
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+8) {
                self.stopAudio(sender: UIButton())
            }
            
        }
    }
    //stop recording audio
    @IBAction func stopAudio(sender: UIButton) {
        
        recordButton.isEnabled = true
        
        if audioRecorder?.isRecording == true{
            audioRecorder?.stop()
            lblStatus.text = "Recording stopped..."
            
        }else{
            audioPlayer?.stop()
        }
    }
    //play your recorded audio
    @IBAction func playAudio(sender: UIButton) {
        
        if audioRecorder?.isRecording == false{
            
            lblStatus.text = "Playing recording..."
            
            var error : NSError?
            
            do {
                
                audioPlayer = try AVAudioPlayer(contentsOf: (audioRecorder?.url)!)
            } catch {
                print(error)
            }
            
            audioPlayer?.delegate = self
            
            if let err = error{
                print("audioPlayer error: \(err.localizedDescription)")
            }else{
                audioPlayer?.play()
            }
        }
    }
    
    @IBAction func successAction(sender: UIButton) {
        
        if audioRecorder?.isRecording == false && statusFlag == false {
            
            let alert = UIAlertController.init(title: "Alert", message: "Please record voice before marking it successful ", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        audioDelegate?.returnDiagnosticStatus(.WorkingSuccessfully, assetType: .Mic)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func failureAction(sender: UIButton) {
        audioDelegate?.returnDiagnosticStatus(.FailedDueToFault, assetType: .Mic)
        self.navigationController?.popViewController(animated: true)

    }
    
    //MARK: --- Delegate Methods ---
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        statusFlag = flag
        lblStatus.text = "Record"
        successAction(sender: UIButton())
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Audio Play Decode Error")
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        playAudio(sender: UIButton())
    }
    
    private func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder!, error: Error?) {
        failureAction(sender: UIButton())
        print("Audio Record Encode Error")
    }
}
