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

@end
