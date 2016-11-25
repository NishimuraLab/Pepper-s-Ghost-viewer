//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CoreVideo.h>
#import "AVFoundationUtil.h"
@interface ImageTransform : NSObject

+ (void)setSubstructor:(int)type;
+ (UIImage *)extractObjectImage:(UIImage *)targetImg;
+ (UIImage *)extractObjectImgWithBackImg:(UIImage *)targetImg : (UIImage *)backImg;
+ (void)unsetSubstructor;

@end
