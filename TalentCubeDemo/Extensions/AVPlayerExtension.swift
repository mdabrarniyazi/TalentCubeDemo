//
//  AVPlayerExtension.swift
//  TalentCubeDemo
//
//  Created by Abrar Niyazi on 02/12/17.
//  Copyright © 2017 Abrar Niyazi. All rights reserved.
//

import Foundation
import AVFoundation

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
