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
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let type = UserDefaults.standard.integer(forKey: ALGORITHM)
        let threshold = UserDefaults.standard.float(forKey: THRESHOLD)
        let algorithm = type == 0 ? "KNN" : "MOG2"
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
        present(controller, animated: true, completion: nil)
    }
    
    func qb_imagePickerController(_ picker: QBImagePickerController!, didFinishPickingAssets assets: [Any]!) {
        var resorces : [AVAsset] = []
        let manager = PHImageManager.default()
        assets.forEach { (_item) in
            let item = _item as! PHAsset
            let semaphore = DispatchSemaphore.init(value: 0)
            manager.requestAVAsset(forVideo: item, options: nil, resultHandler: { (asset, audioMix, info) in
                resorces.append(asset!)
                semaphore.signal()
            })
            semaphore.wait()
        }
        
        
        let vc : ViewController = AppUtil.viewControllerFromId(id: "ViewController") as! ViewController
        vc.assets = resorces
        picker.dismiss(animated: false, completion: nil)
        self.present(vc, animated: true, completion: nil)

    }
    
    func qb_imagePickerControllerDidCancel(_ imagePickerController: QBImagePickerController!) {
        dismiss(animated: true, completion: nil)
    }
    
    func presentMovieView() {
        let vc : ViewController = AppUtil.viewControllerFromId(id: "ViewController") as! ViewController
        present(vc, animated: false, completion: nil)
    }

}
