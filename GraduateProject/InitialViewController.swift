//
//  InitialViewController.swift
//  GraduateProject
//
//  Created by Naoto Takahashi on 2016/10/25.
//  Copyright © 2016年 Naoto Takahashi. All rights reserved.
//

import UIKit
import AssetsLibrary

class InitialViewController : UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {

    }

    @IBAction func onTapSelectMedia(_ sender: Any) {
        if !AppUtil.isiPhone6Or6S() {
            let vc : ViewController = AppUtil.viewControllerFromId(id: "ViewController") as! ViewController
            present(vc, animated: false, completion: nil)
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let controller = UIImagePickerController()
            controller.delegate = self
            controller.sourceType = .photoLibrary
            controller.mediaTypes = ["public.movie"]
            controller.videoQuality = .type640x480
            present(controller, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
    
        let url = info[UIImagePickerControllerReferenceURL] as? URL
        let vc : ViewController = AppUtil.viewControllerFromId(id: "ViewController") as! ViewController
        vc.assetURL = url
        picker.dismiss(animated: false, completion: nil)
        self.present(vc, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}
