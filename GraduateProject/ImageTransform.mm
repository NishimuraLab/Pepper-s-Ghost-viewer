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

+ (UIImage *)MaskedImage:(UIImage *)objectImg{
    cv::Mat src, gray;
    UIImageToMat(objectImg, src);
    //    UIImageToMat(backImg, back);
    cv::cvtColor(src, gray, CV_RGB2GRAY);
    
//    mask = src.clone();
    //    cv::cvtColor(mask, mask, cv::COLOR_RGB2GRAY);
    
//    src.copyTo(back, mask);
    
    return MatToUIImage(gray);
}
@end
