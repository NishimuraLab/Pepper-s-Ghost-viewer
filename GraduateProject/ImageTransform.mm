//
//  ImageTransform.m
//  GraduateProject
//
//  Created by Naoto Takahashi on 2016/10/22.
//  Copyright © 2016年 Naoto Takahashi. All rights reserved.
//

#import "GraduateProject-Bridging-Header.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
#import <opencv2/highgui/highgui.hpp>


@implementation ImageTransform

//背景差分アルゴリズムの選択
cv::Ptr< cv::BackgroundSubtractor> substractor;

+ (void)setSubstructor:(int)algorithm threshold:(int)threshold{
    if(algorithm == 0){
        substractor = cv::createBackgroundSubtractorKNN(100, threshold, false);
    }else{
        substractor = cv::createBackgroundSubtractorMOG2(100, 5, false);
    }
}

+ (UIImage *)extractObjectImage:(UIImage *)targetImg{
    //Mat初期化
    cv::Mat targetMat, backMat, outputMat, mask;
    //UIImageへ変換
    UIImageToMat(targetImg, targetMat);
    //メディアンフィルタでゴマ塩ノイズを発生させないようにする
    cv::medianBlur(targetMat, targetMat, 3);
    //MOG2に入れて処理をかけ、mask画像を入手
    substractor->apply(targetMat, mask);
    //モルフォロジー(オープニング)でノイズを減らす
    cv::morphologyEx(mask, mask, cv::MORPH_OPEN, cv::Mat());
    //outputへmaskしたimageを渡す
    targetMat.copyTo(outputMat, mask);
    UIImage* maskImg = MatToUIImage(mask);
    UIImage* outputImg = MatToUIImage(outputMat);
    UIImage* originImg = MatToUIImage(targetMat);
    return MatToUIImage(outputMat);
}

+ (UIImage *)extractObjectImgWithBackImg:(UIImage *)targetImg : (UIImage *)backImg{
    cv::Mat targetMat, backMat, diffMat, outputMat;
    
    UIImageToMat(targetImg, targetMat);
    UIImageToMat(backImg, backMat);
    
    //前景物体ありとなしで差分を取る
    cv::absdiff(targetMat, backMat, diffMat);
    //差分したものをグレースケールに変換
    cv::cvtColor(diffMat, diffMat, cv::COLOR_RGB2GRAY);
    //メディアンフィルタで平滑化
    cv::medianBlur(diffMat, diffMat, 3);
    //2値化する
    cv::threshold(diffMat, diffMat, 40, 255, cv::THRESH_BINARY);
    UIImage * before = MatToUIImage(diffMat);
    //モルフォロジー(オープニング)でノイズを減らす
    cv::morphologyEx(diffMat, diffMat, cv::MORPH_OPEN, cv::Mat());
    UIImage * after = MatToUIImage(diffMat);
    //オリジナルにマスクをかける
    targetMat.copyTo(outputMat, diffMat);
    //マスク後のイメージを返す
    return MatToUIImage(outputMat);
}

+ (void)unsetSubstructor{
    substractor->clear();
}
@end


