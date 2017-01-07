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
    
    var playerItems : [AVPlayerItem] = []
    var filteredAssets : [AVURLAsset] = []
    var players : [AVQueuePlayer] = []
    var loopers : [AVPlayerLooper] = []
    
    var assets : [AVAsset]!
    var diffImages : [UIImage]?
    
    let productsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/products/"
    
    let fileManager = FileManager.default
    let readyFlags : [Int] = []
    var isSample : Bool = false
    

    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var initialView: UIView!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var percentLabel: UILabel!
    
    func setDiffImages(images: [UIImage]) {
        diffImages = images
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !fileManager.fileExists(atPath: productsPath) {
            try! fileManager.createDirectory(at: URL.init(fileURLWithPath: productsPath), withIntermediateDirectories: true, attributes: nil)
        }
        if assets == nil {
            isSample = true
            (0 ..< 4).forEach {i in
                self.initPlayer(i: i)
            }
            self.fadeOutView(view: self.initialView)
            return
        }
        
        //動画を切り出して、フィルターをかける
        DispatchQueue.global(qos: .default).async {
            for (i, urlAsset) in self.assets.enumerated() {
                DispatchQueue.main.async {
                    self.progressLabel.text = "動画を切り出しています(\(i + 1))..."
                }
                let images : [UIImage] = self.movie2FilteredImages(asset: urlAsset, index: i)
                
                //動画作成
                DispatchQueue.main.async {
                    self.progressLabel.text = "静止画から動画を作成しています(\(i + 1))..."
                }
                
                let path = self.productsPath + "\(i)" + ".mov"
                let url = URL(fileURLWithPath: path)
                AppUtil.removeFilesWhenInit(path: path)
                let util = AVFoundationUtil()
                util.makeVideo(fromUIImages: self, url, images, Int32(AppUtil.fps))
                
                //プレイヤーもつくる
                self.initPlayer(i: i)
                
                if i == (self.assets.count - 1) {
                    DispatchQueue.main.async {
                        //フェードアウトしてPlayerを表示
                        self.fadeOutView(view: self.initialView)
                    }
                }
            }
        }
    }


    func initPlayer(i : Int) {
        var movieFilePath = self.productsPath + "\(i)" + ".mov"
        if !fileManager.fileExists(atPath: movieFilePath) && !isSample{
            print("作成されたファイルが存在しません")
            exit(0)
        }
        
        if isSample{
            movieFilePath = Bundle.main.path(forResource: "sample", ofType: "mov")!
        }
        filteredAssets.append(AVURLAsset(url: URL(fileURLWithPath: movieFilePath)))
        //プレイヤーに加工済みのアセットをSet
        playerItems.append(AVPlayerItem(asset: filteredAssets[i]))
        //KVO登録
        playerItems[i].addObserver(self, forKeyPath: "status", options: [.new], context: nil)
        players.append(AVQueuePlayer(playerItem: playerItems[i]))
        //ルーパーを作成して、動画をループする(iOS10からの機能)
        loopers.append(AVPlayerLooper(player: players[i], templateItem: playerItems[i]))
    }

    func fadeOutView(view : UIView){
        UIView.beginAnimations("fadeOut", context: nil)
        UIView.setAnimationCurve(.easeOut)
        UIView.setAnimationDuration(0.3)
        view.alpha = 0
        UIView.commitAnimations()
    }
    
    //動画をFPSごとに画像に変換し、フィルターをかけるメソッド
    func movie2FilteredImages(asset : AVAsset, index : Int) -> [UIImage]{
        //ローカルから動画を読み出し
        let generator = AVAssetImageGenerator(asset: asset)
        generator.requestedTimeToleranceAfter = kCMTimeZero
        generator.requestedTimeToleranceBefore = kCMTimeZero
        generator.maximumSize = AppUtil.size
        let fps = AppUtil.fps
        let end = Int(CMTimeGetSeconds(asset.duration)) * fps
        var images : [UIImage] = []
        
        //差分アルゴリズムを設定
        let algorithmType = Int32(UserDefaults.standard.integer(forKey: ALGORITHM))
        var threshold = UserDefaults.standard.object(forKey: THRESHOLD)
        if threshold == nil {
            threshold = 400
        }
        if diffImages == nil {
            ImageTransform.setSubstructor(algorithmType, threshold: threshold as! Int32)
        }
        
        //切り出した画像の数回ループし、フィルターをかけてファイルを作成
        (0 ..< end).forEach { (i) in
            var time = CMTimeMake(Int64(i), Int32(fps))
            do{
                let image : CGImage = try generator.copyCGImage(at: time, actualTime: &time)
                let genImage : UIImage = UIImage(cgImage: image)
                var filteredImg : UIImage?
                //OpenCVにてフィルター処理
                if let _diffImages = diffImages {
                    filteredImg = ImageTransform.extractObjectImg(withBackImg: genImage, _diffImages[index])
                }else{
                    filteredImg = ImageTransform.extractObjectImage(genImage)
                }
                
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
        if diffImages == nil {
            //メモリ解放
            ImageTransform.unsetSubstructor()
        }
        
        return images
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if !self.readyToPlay() {
            return
        }
        
        print("動画を再生します。")
        //TODO: 冗長性をなくす
        nView.player = players[0]
        eView.player = players[1]
        wView.player = players[2]
        sView.player = players[3]
        
        nView.setVideoFillMode(mode: AVLayerVideoGravityResizeAspectFill as NSString)
        eView.setVideoFillMode(mode: AVLayerVideoGravityResizeAspectFill as NSString)
        wView.setVideoFillMode(mode: AVLayerVideoGravityResizeAspectFill as NSString)
        sView.setVideoFillMode(mode: AVLayerVideoGravityResizeAspectFill as NSString)
        
        nView.player.play()
        eView.player.play()
        wView.player.play()
        sView.player.play()
        
    }
    
    private func readyToPlay() -> Bool {
        var ready : Bool = true
        if playerItems.count != 4 {
            return false
        }
        playerItems.forEach { (item) in
            if item.status != .readyToPlay {
                ready = false
            }
        }
        return ready
    }
}

