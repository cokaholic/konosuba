//
//  CameraViewController.h
//  AdLessCam
//
//  Created by Keisuke_Tatsumi on 2014/04/10.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>

@protocol KSBCameraViewControllerDelegate;

@interface CameraViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    BOOL isRequireTakePhoto;
    BOOL isProcessing;
    BOOL isFrontMode;
    BOOL isFlashMode;
    void *bitmap;
    dispatch_queue_t queue;
    AVCaptureInput *captureInput;
    
    UIButton *shutter;
    UIButton *frontButton;
    UIButton *flashButton;
    UIButton *cancelButton;
    BOOL isAdjustingExposure;
}

@property (nonatomic,retain) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic,retain) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic,retain) AVCaptureSession *captureSession;
@property (nonatomic,strong) UIImage *imageBuffer;
@property (nonatomic, weak) id<KSBCameraViewControllerDelegate> delegate;

@end

@protocol KSBCameraViewControllerDelegate <NSObject>

- (void)didPickedImage:(UIImage *)image withIsLandscape:(BOOL)isLandscape withIsFromtMode:(BOOL)isFrontMode;
- (void)didTappedCancel;

@end

