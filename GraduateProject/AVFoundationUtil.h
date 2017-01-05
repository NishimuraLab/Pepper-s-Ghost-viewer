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

+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image;

- (void)makeVideoFromUIImages:(UIViewController*)caller : (NSURL*)url : (NSArray<UIImage*>*)images : (int32_t)_fps;

@end
