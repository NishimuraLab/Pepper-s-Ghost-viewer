//
//  AppUtil.swift
//  
//
//  Created by Naoto Takahashi on 2016/10/26.
//
//

import Foundation

class AppUtil {
    class func removeFilesWhenInit(path : String) {
        let manager = FileManager()
        if manager.fileExists(atPath: path) {
            do{
                try manager.removeItem(atPath: path)
            }catch{
                print("ファイルの削除に失敗")
            }
        }
    }
}
