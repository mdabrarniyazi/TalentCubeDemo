//
//  RecordVideoViewController.swift
//  TalentCubeDemo
//
//  Created by Abrar Niyazi on 02/12/17.
//  Copyright © 2017 Abrar Niyazi. All rights reserved.
//

import UIKit
import AVFoundation

protocol RecordingDoneProtocol:class {
    func doneRecordingVideo(questionIndex:Int, url:URL)
}

class RecordAndPlayViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    
    @IBOutlet var questionLabel: UILabel!
    
    
    
    // Camera Preview
    @IBOutlet var camPreview: UIView!
    
    // Video Player
    @IBOutlet var videoPlayer: UIView!
    
    // Interaction Layer IBOutlets
    @IBOutlet var interactionLayerView: UIView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var actionButton: UIButton!
    @IBOutlet var progressView: UIView!
    @IBOutlet var counterLabel: UILabel!
    @IBOutlet var tryAgainButton: UIButton!
    @IBOutlet var continueButton: UIButton!
    
    weak var delegate: RecordingDoneProtocol?
    
    // For Recording
    let captureSession = AVCaptureSession()
    
    var activeInput: AVCaptureDeviceInput!
    
    let movieOutput = AVCaptureMovieFileOutput()
    
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    // Recording Variavles
    var outputURL:URL!
    var finalOutputURL: URL!
    var questionIndex = Int()
    var videoURLs:VideoURLs?
    
    var questions = Questions()
    
    //Timer
    var recordTimer = Timer()
    var time = 0
    var noOfRecordings = 0
    
    // Player Variables
    var finishedPlaying = true
    
    //For Playing
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        questionLabel.text = questions.questions[questionIndex]
        if let url = videoURLs?.recordedURLs![optional: questionIndex] {
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            
            self.title = "Question \(questionIndex + 1)"
            initUIForReplay()
            finalOutputURL = url
            setUpAVPlayer()
        } else {
            initUIForRecording()
            self.navigationController?.setNavigationBarHidden(true, animated: false)

        }
        

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        destroyEverthing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // UI Functions start here
    
    // init UI
    func initUIComponents(){
        videoPlayer.isHidden = true
        interactionLayerView.isHidden = false
        progressView.isHidden = false
        interactionLayerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        messageLabel.backgroundColor = UIColor.clear
        messageLabel.text = message1Text
        counterLabel.text = "00:45"
        initActionButtonUI()
        actionButton.setTitle("START NOW", for: .normal)
        
        actionButton.tag = 0
        //actionButton.backgroundColor = UIColor.clear
        
        tryAgainButton.layer.cornerRadius = tryAgainButton.frame.size.height / 2
        continueButton.layer.cornerRadius = continueButton.frame.size.height / 2
        tryAgainButton.isHidden = true
        continueButton.isHidden = true
    }
    
    // init UI for recording
    func initUIForRecording() {
        initUIComponents()
        if setupSession() {
            setupPreview()
            startSession()
        }
    }
    
    // init UI for REPLAY
    func initUIForReplay(){
        
        camPreview.isHidden = true
        interactionLayerView.isHidden = false
        videoPlayer.isHidden = false
        interactionLayerView.backgroundColor = UIColor.clear
        messageLabel.isHidden = true
        progressView.isHidden = true
        tryAgainButton.isHidden = true
        continueButton.isHidden = true
        initActionButtonUI()
        actionButton.tag = 3
        actionButton.setTitle("PLAY", for: .normal)
        
    }
    
    // init Action Button UI
    func initActionButtonUI(){
        actionButton.layer.cornerRadius = actionButton.frame.size.height / 2
        actionButton.layer.borderColor = UIColor.white.cgColor
        actionButton.layer.borderWidth = 2
    }
    
    // Update UI After START Button Tapped
    func updateUIAfterSTARTButton() {
        interactionLayerView.backgroundColor = UIColor.clear
        counterLabel.text = "00:00"
        time  = 0
        actionButton.setTitle("DONE", for: .normal)
        actionButton.tag = 1
        messageLabel.isHidden = true
    }
    
    // Update UI After DONE Button Tapped
    func updateUIAfterDONEButton() {
        interactionLayerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        actionButton.setTitle("REPLAY", for: .normal)
        actionButton.tag = 2
        messageLabel.isHidden = false
        messageLabel.attributedText = nil
        messageLabel.attributedText = message2Text
        progressView.isHidden = true
        
        tryAgainButton.isHidden = false
        continueButton.isHidden = false
        
        recordTimer.invalidate()
    }
    
    //Update UI After REPLAY Button Tapped
    func updateUIAfterREPLAYButton() {
        camPreview.isHidden = true
        videoPlayer.isHidden = false
        actionButton.isHidden = true
        messageLabel.isHidden = true
        progressView.isHidden = true
        actionButton.isHidden = true
        interactionLayerView.backgroundColor = UIColor.clear
    }
    
    //Update UI After Player done playing
    func updateUIAfterDonePlaying() {
        camPreview.isHidden = false
        videoPlayer.isHidden = true
        messageLabel.isHidden = false
        actionButton.isHidden = false
        interactionLayerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    // UI Functions end here
    //////////////////////////////////////////////////////////////////////////////////////////
    
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Util Functions start here
    
    // Handle main queue
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
    // Destroy everything before closing view
    func destroyEverthing(){
        stopSession()
        stopRecording()
        if avPlayer.isPlaying || !finishedPlaying {
            avPlayer.pause()
        }
        recordTimer.invalidate()
    }
    
    // Create Temprory URL for Videos
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    // Update Timer for different Buttons/Actions
    @objc func updateTimer(){
        if actionButton.tag == 0 {
            if time < 45 {
                time = time + 1
                if time <= 35 {
                    counterLabel.text = "00:" + String(45 - time)
                } else {
                    counterLabel.text = "00:0" + String(45 - time)
                    
                }
            } else {
                startRecording()
                actionButton.setTitle("DONE", for: .normal)
                actionButton.tag = 1
                
            }
        } else if actionButton.tag == 1 {
            if time < 45 {
                time = time + 1
                if time < 10 {
                    counterLabel.text = "00:0" + String(time)
                } else {
                    counterLabel.text = "00:" + String(time)
                }
                
            } else {
                stopRecording()
                actionButton.setTitle("REPLAY", for: .normal)
                actionButton.tag = 2
                recordTimer.invalidate()
            }
        } else if actionButton.tag == 2 {
            if time < 60 {
                time = time + 1
                if time <= 50 {
                    tryAgainButton.setTitle("2. Try (" + String(60 - time) + ")", for: .normal)
                } else {
                    tryAgainButton.setTitle("2. Try (0" + String(60 - time) + ")", for: .normal)
                }
                
            } else {
                // times up continue
                recordTimer.invalidate()
                self.navigationController?.popViewController(animated: true)
                delegate?.doneRecordingVideo(questionIndex: questionIndex, url: finalOutputURL)
            }
        }
        
    }
    
    // Util Functions end here
    /////////////////////////////////////////////////////////////////////////////////////////////////
    

    
    //AVCaptureFileOutputRecordingDelegate
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
        } else {
            finalOutputURL = outputFileURL
            noOfRecordings = noOfRecordings + 1
            if noOfRecordings < 2 {
                time = 0
                recordTimer.invalidate()
                self.recordTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
            } else {
                //continue
                self.navigationController?.popViewController(animated: true)
                delegate?.doneRecordingVideo(questionIndex: questionIndex, url: finalOutputURL)
            }
            print("output url - \(outputFileURL)")
        }
    }
    
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    // Below this all IBActions
    
    // Action Button - Different Action based on different tags
    // Tag 1 : START button
    // Tag 2 : STOP Button
    // Tag 3 : PLAY Button
    // Tag 4 : PAUSE Button
    
    @IBAction func actionButtonPressed(_ sender: UIButton) {
        
        switch sender.tag {
        case 0:
            startRecording()
        case 1:
            stopRecording()
        case 2:
            playVideo()
        case 3:
            avPlayer.play()
            actionButton.setTitle("STOP", for: .normal)
            actionButton.tag = 4
        case 4:
            avPlayer.pause()
            actionButton.setTitle("PLAY", for: .normal)
            actionButton.tag = 3
        default:
            print("unknown tap")
        }
        
    }
    
    
    @IBAction func tryAgainButtonTapped(_ sender: UIButton) {
        if avPlayer.isPlaying || !finishedPlaying {
            avPlayer.pause()
        }
        recordTimer.invalidate()
        initUIComponents()
        actionButton.tag = 0
        finalOutputURL = nil
        recordTimer.invalidate()
        self.recordTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
    }
    
    
    @IBAction func continueButtonTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
        delegate?.doneRecordingVideo(questionIndex:questionIndex, url: finalOutputURL)
    }
    
}
