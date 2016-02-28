//
//  CameraViewController.m
//  AdLessCam
//
//  Created by Keisuke_Tatsumi on 2014/04/10.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import "CameraViewController.h"

@interface CameraViewController ()
{
    AVCaptureDevice *captureKVODevice;
}

@property (nonatomic, assign) BOOL isLandscape;

@end

@implementation CameraViewController

@synthesize imageBuffer;
@synthesize videoOutput;
@synthesize previewLayer;
@synthesize captureSession;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //StatusBarを隠す
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    //Flag初期化
    isFlashMode=NO;
    isFrontMode=NO;
    _isLandscape = NO;
    
    //撮影画像を保持するためのバッファを作成する。
    [self makeBuffer];
    
    //セッションオブジェクトを生成
    captureSession = [[AVCaptureSession alloc]init];
    
    //入力デバイスとしてビデオを選択
    captureKVODevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    captureInput = [AVCaptureDeviceInput deviceInputWithDevice:captureKVODevice
                                                         error:&error];
    [captureSession addInput:captureInput];
    
    //セッションのプリセットを設定
    [captureSession beginConfiguration];
    captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
    [captureSession commitConfiguration];
    
    //出力を初期化
    videoOutput = [[AVCaptureVideoDataOutput alloc]init];
    videoOutput.videoSettings = @{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)};
    videoOutput.alwaysDiscardsLateVideoFrames = YES;
    [captureSession addOutput:videoOutput];
    
    //出力を毎フレーム呼ぶための設定
    dispatch_queue_t videoQueue = dispatch_queue_create("com.coma-tech.myQueue", NULL);
    [videoOutput setSampleBufferDelegate:self
                                   queue:videoQueue];
    
    //プレビュー表示
    previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:previewLayer atIndex:0];
    
    //queue
    queue = dispatch_queue_create("com.coma-tech.takingPhotoQueue", DISPATCH_QUEUE_SERIAL);
    
    //セッションを開始
    [captureSession startRunning];
    
    //タップジェスチャー処理のオブジェクトを画面に追加
    UIGestureRecognizer *gesture;
    gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapped:)];
    [self.view addGestureRecognizer:gesture];
    
    //KVOで露出制御の状況を監視する
    [captureKVODevice addObserver:self
                    forKeyPath:@"adjustingExposure"
                       options:NSKeyValueObservingOptionNew
                       context:nil];
    
    //UINavigationBarの設置
    UIView *navigationBar = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(SCREEN_RECT)-50, CGRectGetWidth(SCREEN_RECT), 50)];
    navigationBar.backgroundColor = [UIColor blackColor];
    navigationBar.alpha = 0.7;
    [self.view addSubview:navigationBar];
    
    //シャッターボタン
    shutter = [UIButton buttonWithType:UIButtonTypeCustom];
    shutter.frame = CGRectMake(CGRectGetWidth(SCREEN_RECT)/2-25, CGRectGetHeight(SCREEN_RECT)-50, 50, 50);
    [shutter setBackgroundImage:[UIImage imageNamed:@"shutter.png"] forState:UIControlStateNormal];
    [shutter addTarget:self
                action:@selector(pressShutter)
      forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shutter];
    
    //フロントボタン
    frontButton = [UIButton buttonWithType:UIButtonTypeCustom];
    frontButton.frame = CGRectMake(0, CGRectGetHeight(SCREEN_RECT)-50, 50, 50);
    [frontButton setBackgroundImage:[UIImage imageNamed:@"front.png"] forState:UIControlStateNormal];
    [frontButton addTarget:self
                    action:@selector(frontButtonTapped)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:frontButton];
    
    //フラッシュボタン
    flashButton = [UIButton buttonWithType:UIButtonTypeCustom];
    flashButton.frame = CGRectMake((frontButton.frame.origin.x + 50 +shutter.frame.origin.x)/2-25, CGRectGetHeight(SCREEN_RECT)-50, 50, 50);
    [flashButton setBackgroundImage:[UIImage imageNamed:@"flash.png"] forState:UIControlStateNormal];
    [flashButton addTarget:self
                    action:@selector(flashButtonTapped)
          forControlEvents:UIControlEventTouchUpInside];
    flashButton.alpha = 0.5;
    [self.view addSubview:flashButton];
    
    //キャンセルボタン
    cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelButton.frame = CGRectMake(shutter.right, CGRectGetHeight(SCREEN_RECT) - 50, CGRectGetWidth(SCREEN_RECT) - shutter.right, 50);
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelButton.titleLabel.font = DEFAULT_FONT(15);
    cancelButton.tintColor = [UIColor whiteColor];
    [cancelButton addTarget:self
                     action:@selector(cancelButtonTapped)
           forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cancelButton];
    
    // start monitoring device orientation changes.
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(didRotate)
     name:UIDeviceOrientationDidChangeNotification
     object:nil];
}

-(void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

-(void)makeBuffer{
    //撮影画像を保持するためのバッファを作成する。
    size_t width;
    size_t height;
    if (!isFrontMode) {
        width = 1920;
        height = 1080;
    }
    else{
        width = 640;
        height = 480;
    }
    
    size_t captureSize = width * height * 4;
    bitmap = malloc(captureSize);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef dataProviderRef = CGDataProviderCreateWithData(NULL,
                                                                     bitmap,
                                                                     captureSize,
                                                                     NULL);
    
    CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
    CGImageRef cgImage = CGImageCreate(width, height, 8, 32, width*4, colorSpace, bitmapInfo, dataProviderRef, NULL, 0, kCGRenderingIntentDefault);
    self.imageBuffer = [UIImage imageWithCGImage:cgImage];
    CGColorSpaceRelease(colorSpace);
    CGDataProviderRelease(dataProviderRef);
}

//シャッターボタンの反応
-(void)pressShutter{
    if (!isProcessing) {
        isRequireTakePhoto = YES;
        if(isFlashMode){
            dispatch_sync(queue, ^{
                Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
                if (captureDeviceClass != nil) {
                    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                    if ([device hasTorch] && [device hasFlash]){
                        [device lockForConfiguration:nil];
                        if (isFlashMode) {
                            [device setTorchMode:AVCaptureTorchModeOn];
                            [device setFlashMode:AVCaptureFlashModeOn];
                        } else {
                            [device setTorchMode:AVCaptureTorchModeOff];
                            [device setFlashMode:AVCaptureFlashModeOff];
                        }
                        [device unlockForConfiguration];
                    }
                }
                sleep(1);
            });
        }
    }
}

//タップジェスチャーのハンドラの実装
-(void)tapped:(UIGestureRecognizer*)gesture{
    
    //タップ位置
    CGPoint pos = [gesture locationInView:gesture.view];
    
    //座標系の変換と、値の正規化
    CGSize viewSize = self.view.bounds.size;
    CGPoint pointOfInterest = CGPointMake(pos.y/viewSize.height, 1.0 - pos.x/viewSize.width);
    
    //フォーカス位置と露出制御位置をAVCaptureDevice に設定する
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    NSError *error = nil;
    if (![captureDevice lockForConfiguration:&error]) {
        
        NSLog(@"error:%@",error);
        
        return;
    }
    
    //フォーカス位置を設定
    if ([captureDevice isFocusPointOfInterestSupported]&&[captureDevice isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        
        captureDevice.focusPointOfInterest = pointOfInterest;
        captureDevice.focusMode = AVCaptureFocusModeAutoFocus;
    }
    
    //露出制御位置を設定
    if ([captureDevice isExposurePointOfInterestSupported]&&[captureDevice isExposureModeSupported:AVCaptureExposureModeAutoExpose]) {
        
        isAdjustingExposure = YES;
        
        captureDevice.exposurePointOfInterest = pointOfInterest;
        captureDevice.exposureMode = AVCaptureExposureModeAutoExpose;
    }
    
    [captureDevice unlockForConfiguration];
}

//露出制御完了時の処理
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    
    if ([keyPath isEqual:@"adjustingExposure"]) {
        if (!isAdjustingExposure) {
            return;
        }
        
        if ([[change objectForKey:NSKeyValueChangeNewKey]boolValue]==NO) {
            isAdjustingExposure = NO;
            
            AVCaptureDevice *captureDevice;
            captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
            
            NSError *error = nil;
            
            if ([captureDevice lockForConfiguration:&error]) {
                
                [captureDevice setExposureMode:AVCaptureExposureModeLocked];
                [captureDevice unlockForConfiguration];
            }
        }
    }
}

//フラッシュボタン
- (void)flashButtonTapped{
    if (isFlashMode || isFrontMode) {
        isFlashMode = NO;
        flashButton.alpha = 0.5;
    }
    else{
        isFlashMode = YES;
        flashButton.alpha = 1.0;
    }
}

- (void)frontButtonTapped{
    AVCaptureDevice *captureDevice;
    if(!isFrontMode){
        isFrontMode = YES;
        
        [self makeBuffer];
        
        //セッションのプリセットを設定
        [captureSession beginConfiguration];
        captureSession.sessionPreset = AVCaptureSessionPreset640x480;
        [captureSession commitConfiguration];
        
        captureDevice = [self frontFacingCameraIfAvailable];
        
        [captureSession removeInput:captureInput];
        captureInput = [AVCaptureDeviceInput
                        deviceInputWithDevice:captureDevice
                        error:nil];
        [captureSession addInput:captureInput];
    } else {
        isFrontMode = NO;
        
        [self makeBuffer];
        
        captureDevice = [self backCamera];
        
        [captureSession removeInput:captureInput];
        captureInput = [AVCaptureDeviceInput
                        deviceInputWithDevice:captureDevice
                        error:nil];
        [captureSession addInput:captureInput];
        
        //セッションのプリセットを設定
        [captureSession beginConfiguration];
        captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
        [captureSession commitConfiguration];
    }
}

- (void)cancelButtonTapped {
    
    [self.delegate didTappedCancel];
}

- (AVCaptureDevice *)frontFacingCameraIfAvailable
{
    //  look at all the video devices and get the first one that's on the front
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionFront)
        {
            captureDevice = device;
            [self forceToSwitchFlashOff];
            break;
        }
    }
    
    //  couldn't find one on the front, so just get the default video device.
    if ( ! captureDevice)
    {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    return captureDevice;
}

- (AVCaptureDevice *)backCamera
{
    //  look at all the video devices and get the first one that's on the front
    NSArray *videoDevices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *captureDevice = nil;
    for (AVCaptureDevice *device in videoDevices)
    {
        if (device.position == AVCaptureDevicePositionBack)
        {
            captureDevice = device;
            break;
        }
    }
    //  couldn't find one on the front, so just get the default video device.
    if ( ! captureDevice)
    {
        captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    return captureDevice;
}

- (void)forceToSwitchFlashOff
{
    if(isFlashMode){
        isFlashMode = NO;
        flashButton.alpha = 0.5;
    }
}

//画像の保存
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    if (!isRequireTakePhoto) {
        return;
    }
    
    isRequireTakePhoto = NO;
    isProcessing = YES;
    
    CVPixelBufferRef pixbuff = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    if (CVPixelBufferLockBaseAddress(pixbuff, 0)==kCVReturnSuccess) {
        
        if (!isFrontMode) {
            memcpy(bitmap, CVPixelBufferGetBaseAddress(pixbuff), 1920*1080*4);
        }
        else{
            memcpy(bitmap, CVPixelBufferGetBaseAddress(pixbuff), 640*480*4);
        }
        
        //メタデータ取得＆ orientation 情報追記
        NSMutableDictionary *metadata;
        metadata = [NSMutableDictionary dictionaryWithCapacity:0];
        
        //ここでは orientation は一定 (6) とする
        [metadata setObject:[NSNumber numberWithInt:6] forKey:(NSString *)kCGImagePropertyOrientation];
        
        //画面の向きによって画像を回転修正
        if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
            NSLog(@"Left");
            
            UIImage *img;
            if (!isFrontMode) {
                img = [UIImage imageWithCGImage:self.imageBuffer.CGImage];
            }
            else{
                img = [UIImage imageWithCGImage:self.imageBuffer.CGImage scale:1.0 orientation:UIImageOrientationDown];
            }
            
            [self.delegate didPickedImage:img
                          withIsLandscape:_isLandscape
                          withIsFromtMode:isFrontMode];
            
            isProcessing = NO;
        }
        else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight){
            NSLog(@"Right");
            UIImage *img;
            if (!isFrontMode) {
                img = [UIImage imageWithCGImage:self.imageBuffer.CGImage scale:1.0 orientation:UIImageOrientationDown];
            }
            else{
                img = [UIImage imageWithCGImage:self.imageBuffer.CGImage];
            }
            [self.delegate didPickedImage:img
                          withIsLandscape:_isLandscape
                          withIsFromtMode:isFrontMode];
            isProcessing = NO;
        }
        else{
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                UIImage *saveImage = [UIImage imageWithCGImage:self.imageBuffer.CGImage scale:1.0 orientation:UIImageOrientationRight];
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.delegate didPickedImage:saveImage
                                  withIsLandscape:_isLandscape
                                  withIsFromtMode:isFrontMode];
                });
            });
            isProcessing = NO;
        }
        CVPixelBufferUnlockBaseAddress(pixbuff, 0);
    }
    
    if(isFlashMode){
        dispatch_sync(queue, ^{
            Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
            if (captureDeviceClass != nil) {
                AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
                if ([device hasTorch] && [device hasFlash]){
                    [device lockForConfiguration:nil];
                    [device setTorchMode:AVCaptureTorchModeOff];
                    [device setFlashMode:AVCaptureFlashModeOff];
                    [device unlockForConfiguration];
                }
            }
        });
    }
}

#pragma mark - 画面回転に伴う処理
-(void)didRotate{
    
    if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeLeft) {
        frontButton.transform = CGAffineTransformMakeRotation(90*M_PI/180);
        flashButton.transform = CGAffineTransformMakeRotation(90*M_PI/180);
        cancelButton.transform = CGAffineTransformMakeRotation(90*M_PI/180);
        //NSLog(@"left");
        _isLandscape = YES;
    }
    else if ([[UIDevice currentDevice] orientation] == UIDeviceOrientationLandscapeRight){
        frontButton.transform = CGAffineTransformMakeRotation(-90*M_PI/180);
        flashButton.transform = CGAffineTransformMakeRotation(-90*M_PI/180);
        cancelButton.transform = CGAffineTransformMakeRotation(-90*M_PI/180);
        _isLandscape = YES;
        //NSLog(@"right");
    }
    else{
        frontButton.transform = CGAffineTransformMakeRotation(0);
        flashButton.transform = CGAffineTransformMakeRotation(0);
        cancelButton.transform = CGAffineTransformMakeRotation(0);
        _isLandscape = NO;
        //NSLog(@"up");
    }
}

- (void)dealloc {
    [captureSession stopRunning];
    [captureKVODevice removeObserver:self
                          forKeyPath:@"adjustingExposure"];
    [[NSNotificationCenter defaultCenter]
     removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
