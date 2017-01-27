//
//  InitialViewController.swift
//  GraduateProject
//
//  Created by Naoto Takahashi on 2016/10/25.
//  Copyright © 2016年 Naoto Takahashi. All rights reserved.
//

import UIKit
import AssetsLibrary
import QBImagePickerController

class InitialViewController : UIViewController, QBImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var algorithmLabel: UILabel!
    @IBOutlet weak var thresholdLabel: UILabel!
    
    var imagePickMode : Bool = false
    var resorces : [AVAsset] = []
    var images : [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let type = UserDefaults.standard.integer(forKey: ALGORITHM)
        let threshold = UserDefaults.standard.float(forKey: THRESHOLD)
        var algorithm : String
        
        switch type {
        case 0: algorithm = "KNN"
        case 1: algorithm = "MOG2"
        default: algorithm = "DIFF"
        }
        algorithmLabel.text = "Algorithm : " + algorithm
        thresholdLabel.text = "Threshold : " + String(threshold)
    }

    @IBAction func onTapSampleMovie(_ sender: Any) {
        presentMovieView()
    }
    @IBAction func onTapSelectMedia(_ sender: Any) {
        if !AppUtil.isiPhone6Or6S() {
            presentMovieView()
        }
        
        let controller = QBImagePickerController()
        controller.delegate = self
        controller.allowsMultipleSelection = true
        controller.maximumNumberOfSelection = 4
        controller.showsNumberOfSelectedAssets = true
        controller.mediaType = .video
        controller.prompt = "動画を4つ選択してください"
        present(controller, animated: true, completion: nil)
    }
    
    func qb_imagePickerController(_ picker: QBImagePickerController!, didFinishPickingAssets assets: [Any]!) {

        let manager = PHImageManager.default()
        
        assets.forEach { (_item) in
            let semaphore = DispatchSemaphore.init(value: 0)
            let item = _item as! PHAsset
            if imagePickMode {
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                options.resizeMode = .exact
                options.isSynchronous = true
                manager.requestImage(for: item, targetSize: CGSize(width: 400, height: 300), contentMode: .aspectFill, options: options, resultHandler: { (image, info) in
                    self.images.append(image!)
                })
            }else{
                manager.requestAVAsset(forVideo: item, options: nil, resultHandler: { (asset, audioMix, info) in
                    self.resorces.append(asset!)
                    semaphore.signal()
                })
                semaphore.wait()
            }     
        }
        
        let type = UserDefaults.standard.integer(forKey: ALGORITHM)
        if(type == 2 && !imagePickMode) {
            //背景差分の場合は、もう一度Pickerを表示して、背景を選択する
            picker.dismiss(animated: true, completion: {
                self.imagePickMode = true
                let controller = QBImagePickerController()
                controller.delegate = self
                controller.allowsMultipleSelection = true
                controller.maximumNumberOfSelection = 4
                controller.showsNumberOfSelectedAssets = true
                controller.mediaType = .image
                controller.prompt = "背景を4つ選択してください"
                self.present(controller, animated: true, completion: nil)
            })
        }else{
            let vc : ViewController = AppUtil.viewControllerFromId(id: "ViewController") as! ViewController
            vc.assets = resorces
            if !images.isEmpty {
                vc.setDiffImages(images: images)
            }
            picker.dismiss(animated: false, completion: nil)
            self.present(vc, animated: true, completion: nil)
        }

    }
    
    func qb_imagePickerControllerDidCancel(_ imagePickerController: QBImagePickerController!) {
        dismiss(animated: true, completion: nil)
    }
    
    func presentMovieView() {
        let vc : ViewController = AppUtil.viewControllerFromId(id: "ViewController") as! ViewController
        present(vc, animated: false, completion: nil)
    }

}
