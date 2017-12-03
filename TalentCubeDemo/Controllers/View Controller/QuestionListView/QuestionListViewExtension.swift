//
//  QuestionListViewExtension.swift
//  TalentCubeDemo
//
//  Created by Abrar Niyazi on 03/12/17.
//  Copyright © 2017 Abrar Niyazi. All rights reserved.
//

import Foundation
import UIKit

// All protocols, extension for QueListViewController goes here

extension QueListViewController: RecordingDoneProtocol {
    func doneRecordingVideo(questionIndex: Int, url: URL) {
        if videoURLs == nil {
            videoURLs = VideoURLs()
            videoURLs?.recordedURLs = []
        }
        videoURLs?.recordedURLs?.insert(url, at: questionIndex)
    }
}
