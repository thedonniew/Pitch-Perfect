//
//  RecordSoundsViewController.swift
//  Pitch Perfect
//
//  Created by Donnie Wang on 8/17/15.
//  Copyright (c) 2015 Donnie Wang. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    @IBOutlet weak var recordinginProgressLabel: UILabel!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    
    var audioRecorder: AVAudioRecorder!
    var recordedAudio: RecordedAudio!
    var isRecording: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.r
        
        isRecording = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        pauseButton.hidden = true
        stopButton.hidden = true
        recordButton.enabled = true
    }

    @IBAction func recordAudio(sender: UIButton) {
        println("in recordAudio")
        recordinginProgressLabel.hidden = false
        pauseButton.hidden = false
        stopButton.hidden = false
        recordButton.enabled = false
        
        // Record the user's voice
        // Get path of document directory within app
        let dirPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        
        // Set the name of the recording
        let recordingName = "my_audio.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURLWithPathComponents(pathArray)
        println(filePath)
        
        // Setup audio session
        var session = AVAudioSession.sharedInstance()
        session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
        
        // Initialize and prepare the recorder
        audioRecorder = AVAudioRecorder(URL: filePath, settings: nil, error: nil)
        audioRecorder.delegate = self
        audioRecorder.meteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
        isRecording = true
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        if (flag) {
            // TODO: Step 1 - Save the recorded audio
            recordedAudio = RecordedAudio()
            recordedAudio.filePathURL = recorder.url
            recordedAudio.title = recorder.url.lastPathComponent
            
            // TODO: Step 2 - Move to the next scene aka perform segue
            self.performSegueWithIdentifier("stopRecording", sender: recordedAudio)
        } else {
            println("Recording was not successful")
            recordButton.enabled = false
            pauseButton.hidden = true
            stopButton.hidden = true
        }
        isRecording = false
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier == "stopRecording") {
            let playSoundsVC:PlaySoundsViewController = segue.destinationViewController as! PlaySoundsViewController
            let data = sender as! RecordedAudio
            playSoundsVC.receivedAudio = data
        }
    }
    
    func resumeAudio() {
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }

    @IBAction func pauseAudio(sender: UIButton) {
        if (isRecording == false) {
            resumeAudio()
            isRecording = true
            recordinginProgressLabel.text = "recording"
        } else {
            audioRecorder.pause()
            isRecording = false
            recordinginProgressLabel.text = "paused"
        }
    }
    
    @IBAction func stopAudio(sender: UIButton) {
        recordinginProgressLabel.text = "recording"
        recordinginProgressLabel.hidden = true
        recordButton.enabled = true
        stopButton.hidden = true
        
        // Stop recording the user's voice
        audioRecorder.stop()
        var audioSession = AVAudioSession.sharedInstance()
        audioSession.setActive(false, error: nil)
    }
}

