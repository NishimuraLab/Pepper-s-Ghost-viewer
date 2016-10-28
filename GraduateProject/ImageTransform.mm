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

+ (UIImage *)extractObjectImage:(UIImage *)targetImg : (UIImage *)backImg{
    //Mat系に変換
    cv::Mat targetMat, backMat, outputMat, mask;
    cv::UMat src, back, output;
    UIImageToMat(targetImg, targetMat);
    UIImageToMat(backImg, backMat);
    
    //背景差分アルゴリズムの選択
//    cv::Ptr< cv::BackgroundSubtractor> substractor = cv::createBackgroundSubtractorMOG2();
    cv::Ptr< cv::BackgroundSubtractor> substractor = cv::createBackgroundSubtractorKNN();
//    substractor->apply(targetMat, mask);
    cv::absdiff(targetMat, backMat, outputMat);
    return MatToUIImage(outputMat);
}
@end
