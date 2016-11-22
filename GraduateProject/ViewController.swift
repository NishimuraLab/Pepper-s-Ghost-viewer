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
    var originAsset : AVURLAsset!
    var filteredAsset : AVURLAsset!
    var player : AVQueuePlayer!
    var looper : AVPlayerLooper!
    
    open var assetURL : URL?
    
    let productsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/products/"
    let filterdMovieName = "gray.mov"
    
    let fileManager = FileManager.default
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var initialView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var percentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !fileManager.fileExists(atPath: productsPath) {
            try! fileManager.createDirectory(at: URL.init(fileURLWithPath: productsPath), withIntermediateDirectories: true, attributes: nil)
        }
        if assetURL == nil {
            let URLString = Bundle.main.path(forResource: "N", ofType: "mov")
            assetURL = URL.init(fileURLWithPath: URLString!)
        }
        //動画ソース選択して、AVAssetに
        self.originAsset = AVURLAsset.init(url: assetURL!)
        
        //動画を切り出して、フィルターをかける
        DispatchQueue.global(qos: .default).async {
            let images : [UIImage] = self.movie2FilteredImages(asset: self.originAsset)
            
            //動画作成
            DispatchQueue.main.async {
                self.progressLabel.text = "静止画から動画を作成しています..."
            }
            
            let path = self.productsPath + self.filterdMovieName
            let url = URL(fileURLWithPath: path)
            AppUtil.removeFilesWhenInit(path: path)
            AVFoundationUtil.makeVideo(fromUIImages: self, url, images, Int32(AppUtil.fps))
            DispatchQueue.main.async {
                //フェードアウトしてPlayerを表示
                self.fadeOutView(view: self.initialView)
                self.initPlayer()
            }
        }
    }

    func initPlayer() {
        let movieFilePath = self.productsPath + self.filterdMovieName
        if !fileManager.fileExists(atPath: movieFilePath) {
            print("作成されたファイルが存在しません")
            exit(0)
        }
        self.filteredAsset = AVURLAsset(url: URL(fileURLWithPath: movieFilePath))
        //プレイヤーに加工済みのアセットをSet
        self.playerItem = AVPlayerItem.init(asset: self.filteredAsset)
        //KVO登録
        self.playerItem.addObserver(self, forKeyPath: "status", options: [.new, .initial], context: nil)
        self.player = AVQueuePlayer(playerItem: self.playerItem)
        //ルーパーを作成して、動画をループする(iOS10からの機能)
        self.looper = AVPlayerLooper(player: self.player, templateItem: self.playerItem)
    }

    func fadeOutView(view : UIView){
        UIView.beginAnimations("fadeOut", context: nil)
        UIView.setAnimationCurve(.easeOut)
        UIView.setAnimationDuration(0.3)
        view.alpha = 0
        UIView.commitAnimations()
    }
    
    //動画をFPSごとに画像に変換し、フィルターをかけるメソッド
    func movie2FilteredImages(asset : AVURLAsset) -> [UIImage]{
        //ローカルから動画を読み出し
        let generator = AVAssetImageGenerator(asset: asset)
        generator.requestedTimeToleranceAfter = kCMTimeZero
        generator.requestedTimeToleranceBefore = kCMTimeZero
        generator.maximumSize = AppUtil.size
        let fps = AppUtil.fps
        let end = Int(CMTimeGetSeconds(asset.duration)) * fps
        var images : [UIImage] = []
        
        //切り出した画像の数回ループし、フィルターをかけてファイルを作成
        (0 ..< end).forEach { (i) in
            var time = CMTimeMake(Int64(i), Int32(fps))
            do{
                let image : CGImage = try generator.copyCGImage(at: time, actualTime: &time)
                let genImage : UIImage = UIImage(cgImage: image)
                //OpenCVにてフィルター処理
                let filteredImg = ImageTransform.extractObjectImage(genImage)
                images.append(filteredImg!)
            }catch{
                print("Errors has detected!")
            }
            DispatchQueue.main.async {
                //Progress更新
                let progress  = Float(i) / Float(end)
                self.progressBar.progress = progress
                let percent = Int(ceil(progress * 100))
                self.percentLabel.text = String(percent) + "%"
            }
        }
        //メモリ解放
        ImageTransform.unsetSubstructor()
        
        return images
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

