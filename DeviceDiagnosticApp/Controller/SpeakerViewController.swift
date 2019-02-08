//
//  SpeakerViewController.swift
//  DeviceDiagnosticApp
//
//  Created by Globallogic on 01/02/19.
//  Copyright © 2019 Globallogic. All rights reserved.
//

import UIKit
import AVFoundation

class SpeakerViewController: UIViewController {

    var player: AVAudioPlayer?
    var fileName: String = "test"
    var fileExtension : String = ".mp3"
    var isAutoPlay = false
    @IBOutlet weak var playButton : UIButton!
    


    override func viewDidLoad() {
        super.viewDidLoad()
        playSound()
        if isAutoPlay == true {
            playButtonAction()
        }
    }
    
    @IBAction func doneButtonAction() {
        print("Done pressed")
    }
    
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
            
            
        } catch let error {
            print(error.localizedDescription)
        }
    }

}
