//
//  SpeakerViewController.swift
//  DeviceDiagnosticApp
//
//  Created by Tejas Patelia on 01/02/19.
//  Copyright © 2019 Tejas Patelia. All rights reserved.
//

import UIKit
import AVFoundation

class SpeakerViewController: UIViewController {

    //MARK: --- Functional methods ----

    @IBOutlet weak var playButton : UIButton!
    @IBOutlet weak var successButton: UIButton!
    @IBOutlet weak var failedButton: UIButton!

    //MARK: --- Functional methods ----

    var player: AVAudioPlayer?
    var fileName: String = "test"
    var fileExtension : String = ".mp3"
    var isAutoPlay = false
    weak var speakerDelegate : DiagnosticStatusDelegate?
    var statusFlag = false
    
    //MARK: --- View methods ----

    override func viewDidLoad() {
        super.viewDidLoad()
        playSound()
        self.title = "Speaker Diagnostic"
    }
    
    //MARK: --- Functional methods ----

    func playSound() {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: fileExtension) else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            /* The following line is required for the player to work on iOS 11. Change the file type accordingly*/
            if #available(iOS 11, *){
                player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            }else{
                /* iOS 10 and earlier require the following line:*/
                player = try AVAudioPlayer(contentsOf: url)
            }
            player?.delegate = self
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
    //MARK: --- Action methods ----

    @IBAction func playButtonAction() {
        
        guard let player = player else { return }
        if player.isPlaying == false {
            playButton.setImage(UIImage(named: "Pause"), for: UIControl.State.normal)
            player.play()
        }else{
            playButton.setImage(UIImage(named: "Play"), for: UIControl.State.normal)
            player.stop()
        }
    }

    
    @IBAction func successAction(sender: UIButton) {
        
        if player?.isPlaying == false && statusFlag == false {
            
            let alert = UIAlertController.init(title: "Alert", message: "Please play file before marking it successful ", preferredStyle: .alert)
            alert.addAction(UIAlertAction.init(title: "Ok", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        speakerDelegate?.returnDiagnosticStatus(.WorkingSuccessfully, assetType: .Speaker)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func failureAction(sender: UIButton) {
        speakerDelegate?.returnDiagnosticStatus(.FailedDueToFault, assetType: .Speaker)
        self.navigationController?.popViewController(animated: true)
        
    }
}
//MARK: --- Audio Player Delegate methods ----

extension SpeakerViewController : AVAudioPlayerDelegate{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        
        statusFlag = flag
        if flag == true {
            successAction(sender: UIButton())
        }else{
            failureAction(sender: UIButton())
        }
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        failureAction(sender: UIButton())
    }
}
