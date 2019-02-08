//
//  MicViewController.swift
//  DeviceDiagnosticApp
//
//  Created by Globallogic on 01/02/19.
//  Copyright © 2019 Globallogic. All rights reserved.
//

import UIKit
import AVFoundation

class MicViewController: UIViewController {

    @IBOutlet weak var lblStatus : UILabel!
    @IBOutlet weak var recordButton : UIButton!
    
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var fileName = "Recording"
    var fileExtension = ".m4a"
    var globalFilePath : URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRecordingHardware()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
//        audioRecorder.stop()
//        audioRecorder = nil
    }
    
    @IBAction func recordButtonClicked(){
        recordTapped()
    }
    
    @IBAction func playBackButtonClicked(){
        let main = UIStoryboard(name: "Main", bundle: nil)
        guard let SpeakerVC = main.instantiateViewController(withIdentifier: "SpeakerViewController") as? SpeakerViewController else{return}
        SpeakerVC.fileName = fileName
        SpeakerVC.fileExtension = fileExtension
        SpeakerVC.isAutoPlay = true 
        self.navigationController?.pushViewController(SpeakerVC, animated: true)

    }
    
    func configureRecordingHardware() {
    
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if allowed {
                        
                    } else {
                        self.lblStatus.text = "Permission Denied!!"
                    }
                }
            }
        } catch {
            // failed to record!
        }
    }
    
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent(fileName+fileExtension)
        globalFilePath = audioFilename
        print("\(globalFilePath!)")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            lblStatus.text = "Tap Button to Stop"
        } catch {
            finishRecording(success: false)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func finishRecording(success: Bool) {
        audioRecorder.stop()
        audioRecorder = nil
        
        if success {
            lblStatus.text = "Tap Button to Re-record"
            //globalFilePath
            guard let newPath = globalFilePath?.absoluteString.replacingOccurrences(of: "m4a", with: "mp3") else {return}
            
                let newPathURL = URL(fileURLWithPath: newPath)
            
            
            convertAudio(globalFilePath!, outputURL: newPathURL)
        } else {
            lblStatus.text = "Tap Button to Record"
            // recording failed :(
        }
    }
    
    @objc func recordTapped() {
        if audioRecorder == nil {
            startRecording()
        } else {
            finishRecording(success: true)
        }
    }
}


extension MicViewController: AVAudioRecorderDelegate{
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}


extension MicViewController {
    func convertAudio(_ url: URL, outputURL: URL) {
        var error : OSStatus = noErr
        var destinationFile: ExtAudioFileRef? = nil
        var sourceFile : ExtAudioFileRef? = nil
        
        var srcFormat : AudioStreamBasicDescription = AudioStreamBasicDescription()
        var dstFormat : AudioStreamBasicDescription = AudioStreamBasicDescription()
        
        ExtAudioFileOpenURL(url as CFURL, &sourceFile)
        
        var thePropertySize: UInt32 = UInt32(MemoryLayout.stride(ofValue: srcFormat))
        
        ExtAudioFileGetProperty(sourceFile!,
                                kExtAudioFileProperty_FileDataFormat,
                                &thePropertySize, &srcFormat)
        
        dstFormat.mSampleRate = 44100  //Set sample rate
        dstFormat.mFormatID = kAudioFormatLinearPCM
        dstFormat.mChannelsPerFrame = 1
        dstFormat.mBitsPerChannel = 16
        dstFormat.mBytesPerPacket = 2 * dstFormat.mChannelsPerFrame
        dstFormat.mBytesPerFrame = 2 * dstFormat.mChannelsPerFrame
        dstFormat.mFramesPerPacket = 1
        dstFormat.mFormatFlags = kLinearPCMFormatFlagIsPacked |
        kAudioFormatFlagIsSignedInteger
        
        // Create destination file
        error = ExtAudioFileCreateWithURL(
            outputURL as CFURL,
            kAudioFileWAVEType,
            &dstFormat,
            nil,
            AudioFileFlags.eraseFile.rawValue,
            &destinationFile)
        print("Error 1 in convertAudio: \(error.description)")
        
        error = ExtAudioFileSetProperty(sourceFile!,
                                        kExtAudioFileProperty_ClientDataFormat,
                                        thePropertySize,
                                        &dstFormat)
        print("Error 2 in convertAudio: \(error.description)")
        
        error = ExtAudioFileSetProperty(destinationFile!,
                                        kExtAudioFileProperty_ClientDataFormat,
                                        thePropertySize,
                                        &dstFormat)
        print("Error 3 in convertAudio: \(error.description)")
        
        let bufferByteSize : UInt32 = 32768
        var srcBuffer = [UInt8](repeating: 0, count: 32768)
        var sourceFrameOffset : ULONG = 0
        
        while(true){
            var fillBufList = AudioBufferList(
                mNumberBuffers: 1,
                mBuffers: AudioBuffer(
                    mNumberChannels: 2,
                    mDataByteSize: UInt32(srcBuffer.count),
                    mData: &srcBuffer
                )
            )
            var numFrames : UInt32 = 0
            
            if(dstFormat.mBytesPerFrame > 0){
                numFrames = bufferByteSize / dstFormat.mBytesPerFrame
            }
            
            error = ExtAudioFileRead(sourceFile!, &numFrames, &fillBufList)
            print("Error 4 in convertAudio: \(error.description)")
            
            if(numFrames == 0){
                error = noErr;
                break;
            }
            
            sourceFrameOffset += numFrames
            error = ExtAudioFileWrite(destinationFile!, numFrames, &fillBufList)
            print("Error 5 in convertAudio: \(error.description)")
        }
        
        error = ExtAudioFileDispose(destinationFile!)
        print("Error 6 in convertAudio: \(error.description)")
        error = ExtAudioFileDispose(sourceFile!)
        print("Error 7 in convertAudio: \(error.description)")
    }
}
