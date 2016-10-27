//
//  AVFoundationUtil.m
//  MultiCamera
//
//  Created by Naoto Takahashi on 2016/07/01.
//  Copyright © 2016年 Naoto Takahashi. All rights reserved.
//
#import "UIKit/UIKit.h"
#import "AVFoundationUtil.h"

@implementation AVFoundationUtil

+ (UIImage *)imageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // ピクセルバッファのベースアドレスをロックする
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get information of the image
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0);
    
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // RGBの色空間
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef newContext = CGBitmapContextCreate(baseAddress,
                                                    width,
                                                    height,
                                                    8,
                                                    bytesPerRow,
                                                    colorSpace,
                                                    kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(newContext);
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    
    CGImageRelease(imageRef);
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    return ret;
}

+ (AVCaptureVideoOrientation)videoOrientationFromDeviceOrientation:(UIDeviceOrientation)deviceOrientation
{
    AVCaptureVideoOrientation orientation;
    switch (deviceOrientation) {
        case UIDeviceOrientationUnknown:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortrait:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationPortraitUpsideDown:
            orientation = AVCaptureVideoOrientationPortraitUpsideDown;
            break;
        case UIDeviceOrientationLandscapeLeft:
            orientation = AVCaptureVideoOrientationLandscapeRight;
            break;
        case UIDeviceOrientationLandscapeRight:
            orientation = AVCaptureVideoOrientationLandscapeLeft;
            break;
        case UIDeviceOrientationFaceUp:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
        case UIDeviceOrientationFaceDown:
            orientation = AVCaptureVideoOrientationPortrait;
            break;
    }
    return orientation;
}
//Quoted from http://qiita.com/edo_m18/items/16480f831fd76ab88b6e

+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image
{
    NSDictionary *options = @{ (NSString *)kCVPixelBufferCGImageCompatibilityKey: @YES,
                               (NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey: @YES, };
    
    CVPixelBufferRef pxbuffer = NULL;
    
    CGFloat width  = CGImageGetWidth(image);
    CGFloat height = CGImageGetHeight(image);
    CVPixelBufferCreate(kCFAllocatorDefault,
                        width,
                        height,
                        kCVPixelFormatType_32ARGB,
                        (__bridge CFDictionaryRef)options,
                        &pxbuffer);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    size_t bitsPerComponent       = 8;
    size_t bytesPerRow            = 4 * width;
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata,
                                                 width,
                                                 height,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 rgbColorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}

+ (void)makeVideoFromCGImages:(NSURL*)url : (NSArray<UIImage*>*)images{
    NSInteger width = 640;
    NSInteger height = 360;
    
    // パスは適切な保存先を指定
    AVAssetWriter *videoWriter = [[AVAssetWriter alloc] initWithURL:url fileType:AVFileTypeQuickTimeMovie error:nil];
    // アウトプットの設定
    NSDictionary *outputSettings =
  @{
    AVVideoCodecKey : AVVideoCodecH264,
    AVVideoWidthKey : @(width),
    AVVideoHeightKey: @(height),
    };
    
    // writer inputを生成
    AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
    
    // writerに、writer inputを設定
    [videoWriter addInput:writerInput];
    
    // source pixel buffer attributesを設定
    NSDictionary *sourcePixelBufferAttributes =
  @{
    (NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32ARGB),
    (NSString *)kCVPixelBufferWidthKey: @(width),
    (NSString *)kCVPixelBufferHeightKey: @(height),
    };
    
    // writer input pixel buffer adaptorを生成
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:sourcePixelBufferAttributes];

    //
    writerInput.expectsMediaDataInRealTime = YES;
    
    // 生成開始できるか確認
    if (![videoWriter startWriting]) {
        // Error!
    }
    
    // 動画生成開始
    [videoWriter startSessionAtSourceTime:kCMTimeZero];
    // pixel bufferを宣言
    CVPixelBufferRef buffer = NULL;
    // 現在のフレームカウント
    int i = 1;
    // FPS
    int32_t fps = 20;
    
    // 全画像をバッファに貯めこむ
    // Quoted by http://iphonedevsdk.com/forum/iphone-sdk-development/77999-make-a-video-from-nsarray-of-uiimages.html
    
    while(1) {
        @autoreleasepool {
            if (writerInput.readyForMoreMediaData) {
                
                CMTime frameTime = CMTimeMake(1, fps);
                CMTime lastTime=CMTimeMake(i, fps);
                CMTime presentTime=CMTimeAdd(lastTime, frameTime);
                
                // 動画の時間を生成（その画像の表示する時間。開始時点と表示時間を渡す）
                
                // CGImageからバッファを生成
                if(i >= images.count){
                    buffer = NULL;
                }else{
                    UIImage *image = images[i];
                    buffer = [self pixelBufferFromCGImage: image.CGImage];
                }
                
                if(buffer){
                    NSLog(@"%d",i);
                    [adaptor appendPixelBuffer:buffer withPresentationTime:presentTime];
                    i++;
                }else{
                    // 動画生成終了
                    [writerInput markAsFinished];
//                    [videoWriter endSessionAtSourceTime:CMTimeMake((int64_t)(frameCount - 1) * fps * durationForEachImage, fps)];
                    
                    [videoWriter finishWritingWithCompletionHandler:^{
                        // Finish!
                    }];
                    
                    // 後片付け
                    CVPixelBufferPoolRelease(adaptor.pixelBufferPool);
                    break;
                }
            }
        }
    }
    

}

@end
