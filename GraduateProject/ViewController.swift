//
//  ViewController.swift
//  GraduateProject
//
//  Created by Naoto Takahashi on 2016/10/21.
//  Copyright © 2016年 Naoto Takahashi. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var nView: AVPlayerView!
    @IBOutlet weak var eView: AVPlayerView!
    @IBOutlet weak var wView: AVPlayerView!
    @IBOutlet weak var sView: AVPlayerView!
    
    var playerItem : AVPlayerItem!
    var asset : AVURLAsset!
    var player : AVQueuePlayer!
    var looper : AVPlayerLooper!
    
    let imagesPath = "/Users/reastral/Desktop/GraduateProject/images/"
    let productsPath = "/Users/reastral/Desktop/GraduateProject/products/"
    let filterdMovieName = "gray.mov"
    
    @IBOutlet weak var initialView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //動画ソース選択して、AVAssetに
        let URLString = self.productsPath + filterdMovieName
        let url = URL.init(fileURLWithPath: URLString)
        self.asset = AVURLAsset.init(url: url)
        
        //動画を切り出して、フィルターをかける
        DispatchQueue.global(qos: .default).async {
            self.movie2FilteredImages(asset: self.asset)
            DispatchQueue.main.async {
                //フェードアウトしてPlayerを表示
                self.fadeOutView(view: self.initialView)
                
                //プレイヤーに加工済みのアセットをSet
                self.playerItem = AVPlayerItem.init(asset: self.asset)
                //KVO登録
                self.playerItem.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
                self.player = AVQueuePlayer(playerItem: self.playerItem)
                //ルーパーを作成して、動画をループする(iOS10からの機能)
                self.looper = AVPlayerLooper(player: self.player, templateItem: self.playerItem)
            }
        }
    }

    func fadeOutView(view : UIView){
        UIView.beginAnimations("fadeOut", context: nil)
        UIView.setAnimationCurve(.easeOut)
        UIView.setAnimationDuration(0.3)
        view.alpha = 0
        UIView.commitAnimations()
    }
    
    //動画をFPSごとに画像に変換し、フィルターをかけるメソッド
    func movie2FilteredImages(asset : AVURLAsset){
        //ローカルから動画を読み出し
        let generator = AVAssetImageGenerator(asset: asset)
        generator.requestedTimeToleranceAfter = kCMTimeZero
        generator.requestedTimeToleranceBefore = kCMTimeZero
        let fps = 20
        let end = Int(CMTimeGetSeconds(asset.duration)) * fps
        var images : [UIImage] = []
        
        //切り出した画像の数回ループし、フィルターをかけてファイルを作成
        (0 ..< end).forEach { (i) in
            var time = CMTimeMake(Int64(i), Int32(fps))
            do{
                let image : CGImage = try generator.copyCGImage(at: time, actualTime: &time)
                let genImage : UIImage = UIImage(cgImage: image)
                //OpenCVにてフィルター処理
                let filteredImg = ImageTransform.maskedImage(genImage)
                images.append(filteredImg!)
                let data = UIImageJPEGRepresentation(filteredImg!, 0.6)
                let fileName = String.init(format: imagesPath + "%i.jpg", i)
                let jpgUrl = URL(fileURLWithPath: fileName)
                try data?.write(to: jpgUrl)
                print("書き込み完了")
            }catch{
                print("Errors has detected!")
            }
            DispatchQueue.main.async {
                //Progress更新
                let progress  = Float(i) / Float(end)
                self.progressBar.progress = progress
            }
        }
        //動画作成
        let path = productsPath + filterdMovieName
        let url = URL(fileURLWithPath: path)
        AppUtil.removeFilesWhenInit(path: path)
        AVFoundationUtil.makeVideo(fromCGImages: url, images)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            let status : AVPlayerItemStatus = playerItem.status
            
            switch status {
            case .readyToPlay:
                print("動画を再生します。")
                //TODO: 冗長性をなくす
                nView.player = player
                eView.player = player
                wView.player = player
                sView.player = player
                
                nView.setVideoFillMode(mode: AVLayerVideoGravityResizeAspectFill as NSString)
                eView.setVideoFillMode(mode: AVLayerVideoGravityResizeAspectFill as NSString)
                wView.setVideoFillMode(mode: AVLayerVideoGravityResizeAspectFill as NSString)
                sView.setVideoFillMode(mode: AVLayerVideoGravityResizeAspectFill as NSString)
                
                nView.player.play()
                eView.player.play()
                wView.player.play()
                sView.player.play()
            case .failed:
                print("再生に失敗しました")
            case .unknown:
                print("unknown")
            }
        }else{
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }


}

