//
//  PlayVideoExtension.swift
//  TalentCubeDemo
//
//  Created by Abrar Niyazi on 02/12/17.
//  Copyright © 2017 Abrar Niyazi. All rights reserved.
//

import Foundation
import AVFoundation


// Extension for RecordVideoViewController

extension RecordAndPlayViewController {
    
    // Play Video
    func playVideo(){
        
        updateUIAfterREPLAYButton()
        setUpAVPlayer()
        avPlayer.play()
    }
    
    //Setup AVPlayer
    func setUpAVPlayer(){
        finishedPlaying = false
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = videoPlayer.bounds
        avPlayerLayer.masksToBounds = true
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        videoPlayer.layer.insertSublayer(avPlayerLayer, at: 0)
        view.layoutIfNeeded()
        
        let playerItem = AVPlayerItem(url: finalOutputURL! as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
        avPlayer.volume = 1
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
        
    }
    
    // Notify when player did finish playing
    @objc func playerDidFinishPlaying(note: NSNotification) {
        print("Video Finished")
        finishedPlaying = true
        if videoURLs?.recordedURLs![optional: questionIndex] != nil {
            actionButton.setTitle("PLAY", for: .normal)
            actionButton.tag = 3
        } else {
            updateUIAfterDonePlaying()
        }
        
    }
    
}
