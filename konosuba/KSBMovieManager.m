//
//  MovieMaker.m
//  sample
//
//  Created by 石橋 弦樹 on 2016/02/27.
//  Copyright © 2016年 石橋 弦樹. All rights reserved.
//

#import "KSBMovieManager.h"
#import "UIImage+Util.h"
#import <AVFoundation/AVFoundation.h>

@implementation KSBMovieManager{
    
    CGSize _windowSize;
    NSTimeInterval _delay;
    int _frameRate;
    CGRect _srcFrame;
    CGRect _destFrame;
    NSMutableArray *_actions;
}

+ (instancetype)sharedInstance {
    
    static KSBMovieManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KSBMovieManager alloc] init];
        [manager initConfig];
    });
    
    return manager;
}

- (CGSize)getWindowSize {
    return _windowSize;
}

- (void)initConfig {
    // デフォルト値
    self.destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    self.outputFileName = @"tmpMovie"; //日付名でもいいかも
    self.bgImage = [UIImage imageWithColor:[UIColor grayColor]];
    _windowSize = CGSizeMake(400, APPFRAME_RECT.size.height); // 幅を400以上にしないと動画生成時におかしくなるので。。。
    _actions = [NSMutableArray array];
}

/**
 *  画像を動かす条件を追加する
 *
 *  @param action 動作させるためのアクションを指定
 */
- (void)addAnimationAction:(KSBAnimationAction *)action {
    [_actions addObject:action];
}

/**
 *  動画を生成処理
 */
- (void)startMakingMovieWithFPS:(double)fps {
    
    NSError *error;
    _frameRate = fps;
    
    // すでにファイルがあれば削除
    NSString *path = [NSString stringWithFormat:@"%@/%@.mp4", self.destPath, self.outputFileName];
    NSLog(@"%@", path);
    NSFileManager *fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:path])
    {
        [fm removeItemAtPath:path error:&error];
    }
    
    // 出力準備
    NSURL *url = [NSURL fileURLWithPath:path];
    AVAssetWriter *writer = [[AVAssetWriter alloc] initWithURL:url fileType:AVFileTypeMPEG4 error:&error];
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              AVVideoCodecH264, AVVideoCodecKey,
                              @(_windowSize.width), AVVideoWidthKey,
                              @(_windowSize.height), AVVideoHeightKey,
                              nil];
    
    AVAssetWriterInput *writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:settings];
    AVAssetWriterInputPixelBufferAdaptor *adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:writerInput sourcePixelBufferAttributes:nil];
    
    writerInput.expectsMediaDataInRealTime = YES;
    [writer addInput:writerInput];
    
    // 出力処理
    CVPixelBufferRef buffer = NULL;
    int frameCount = 0;
    
    [writer startWriting];
    [writer startSessionAtSourceTime:kCMTimeZero];
    
    for (KSBAnimationAction *action in _actions) {
    
//        NSLog(@"loop");
        CGPoint imageViewOrigin = action.imageView.origin;
        double dt = action.duration.doubleValue / (double)_frameRate;
        double dx = (action.destValue.CGPointValue.x - imageViewOrigin.x) / (double)_frameRate;
        double dy = (action.destValue.CGPointValue.y - imageViewOrigin.y) / (double)_frameRate;
        CGFloat newX = imageViewOrigin.x;
        CGFloat newY = imageViewOrigin.y;
        
        // 拡大率()
        // 横拡大率
        double ds = (action.scale.doubleValue - 1) / (double)_frameRate;
        double newDs = 1;
//        double s_width = [action getDestFrame].size.width / [action getSrcFrame].size.width;
//        double s_height = [action getDestFrame].size.height / [action getSrcFrame].size.height;
//        double ds_width = s_width - 1.0 / (double)_frameRate;
//        double ds_height = s_height - 1.0 / (double)_frameRate;
//        double newS_width = s_width;
//        double newS_height = s_height;
        
        for (int i = 1; i * dt <= action.duration.doubleValue; i++) { // コマ数
            // 5
            @autoreleasepool {
                
                UIGraphicsBeginImageContext(_windowSize);
                
                // 画像拡大
                newDs += ds;
                
                CGSize sz = CGSizeMake(action.imageView.image.size.width*newDs,
                                       action.imageView.image.size.height*newDs);
                [action.imageView.image drawInRect:CGRectMake(0, 0, sz.width, sz.height)];
                UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
                
                [self.bgImage drawAtPoint:CGPointZero];
                [newImage drawAtPoint:CGPointMake(newX, newY)];
                newX += dx;
                newY += dy;
                
                UIImage *composedImage = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
                
                buffer = [self pixelBufferFromCGImage:[composedImage CGImage] andSize:_windowSize time:i];
                
                BOOL result = NO;
                if (adaptor.assetWriterInput.readyForMoreMediaData)
                {
                    CMTime frameTime = CMTimeMake(frameCount, _frameRate);
                    result = [adaptor appendPixelBuffer:buffer withPresentationTime:frameTime];
                    
                    [NSThread sleepForTimeInterval:0.05];
                }
                
                CVPixelBufferRelease(buffer);
                
                frameCount++;
                
                if (!result)
                {
                    NSLog(@"error: image %d ", frameCount);
                    
                    break;
                }
            }
        }
        
    }
    // 完了処理
    // 1
    [writerInput markAsFinished];
    [writer endSessionAtSourceTime:CMTimeMake(frameCount - 1, _frameRate)];
    [writer finishWritingWithCompletionHandler:^{
        
        // 2
        NSLog(@"write end");
    }];
}

- (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image andSize:(CGSize)size time:(int)time
{
    // 1
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             @YES, kCVPixelBufferCGImageCompatibilityKey,
                             @YES, kCVPixelBufferCGBitmapContextCompatibilityKey,
                             nil];
    
    // 2
    CVPixelBufferRef pxbuffer = NULL;
    CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32ARGB,
                        (__bridge CFDictionaryRef)options, &pxbuffer);
    
    // 3
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    
    // 4
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    
    // 5
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, 4 * size.width, rgbColorSpace, (CGBitmapInfo)kCGImageAlphaNoneSkipFirst);
    
    // 6
    CGFloat width = CGImageGetWidth(image);
    CGFloat height = CGImageGetHeight(image);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    
    // 7
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    // 8
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    // 9
    return pxbuffer;
}
@end
