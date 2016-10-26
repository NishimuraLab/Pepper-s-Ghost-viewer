//
//  AVFoundationUtil.h
//  MultiCamera
//
//  Created by Naoto Takahashi on 2016/07/01.
//  Copyright © 2016年 Naoto Takahashi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>

/**
 AVFoundation.framework用ユーティリティクラス
 */
@interface AVFoundationUtil : NSObject

/**
 サンプルバッファのデータから`UIImage`インスタンスを生成する
 
 @param     sampleBuffer       サンプルバッファ
 @return    生成した`UIImage`インスタンス
 */
+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/**
 デバイスの向きからカメラAPIの向きを判別する
 
 @param     deviceOrientation   デバイスの向き
 @return    カメラの向き
 */
+ (AVCaptureVideoOrientation)videoOrientationFromDeviceOrientation:(UIDeviceOrientation)deviceOrientation;

+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image;

@end
