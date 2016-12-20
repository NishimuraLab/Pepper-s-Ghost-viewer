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
        substractor = cv::createBackgroundSubtractorKNN(100, threshold, true);
    }else{
        substractor = cv::createBackgroundSubtractorMOG2(500, 16, true);
    }
}

+ (UIImage *)extractObjectImage:(UIImage *)targetImg{
    //Mat初期化
    cv::Mat targetMat, backMat, outputMat, mask;
    //UIImageへ変換
    UIImageToMat(targetImg, targetMat);
    //MOG2に入れて処理をかけ、mask画像を入手
    substractor->apply(targetMat, mask);
    //outputへmaskしたimageを渡す
    targetMat.copyTo(outputMat, mask);
    return MatToUIImage(outputMat);
}

+ (UIImage *)extractObjectImgWithBackImg:(UIImage *)targetImg : (UIImage *)backImg{
    cv::Mat targetMat, backMat, outputMat;
    
    UIImageToMat(targetImg, targetMat);
    UIImageToMat(backImg, backMat);
    cv::absdiff(targetMat, backMat, outputMat);
    
    return MatToUIImage(outputMat);
}

+ (void)unsetSubstructor{
    substractor->clear();
}
@end


