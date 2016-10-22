//
//  AVPlayerView.swift
//  GraduateProject
//
//  Created by Naoto Takahashi on 2016/10/22.
//  Copyright © 2016年 Naoto Takahashi. All rights reserved.
//

import UIKit
import AVFoundation

class AVPlayerView: UIView{
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //0 → 0
        //1 → 90
        //2 → 180
        //3 → 270
        let rot : Double = Double(self.tag * 90)
        let angle : CGFloat = CGFloat(M_PI * rot / 180)
        self.layer.setAffineTransform(CGAffineTransform(rotationAngle: angle))
//        self.transform = CGAffineTransform(rotationAngle: angle)
    }
    // AVPlayerのgetterとsetter
    var player: AVQueuePlayer {
        get {
            let layer: AVPlayerLayer = self.layer as! AVPlayerLayer
            return layer.player as! AVQueuePlayer
        }
        set(newValue) {
            let layer: AVPlayerLayer = self.layer as! AVPlayerLayer
            layer.player = newValue
        }
    }
    // layerClassのoverride
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    func setVideoFillMode(mode: NSString) {
        let layer: AVPlayerLayer = self.layer as! AVPlayerLayer
        layer.videoGravity = mode as String
    }
}
