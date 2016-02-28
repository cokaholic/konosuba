//
//  SecondViewController.m
//  COMIX
//
//  Created by Keisuke_Tatsumi on 2014/07/29.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import <Social/Social.h>
#import "SecondViewController.h"
#import "KSBMovieManager.h"
#import "KSBBgmSettingViewController.h"
#import "KSBMovieManager.h"
#import "CameraViewController.h"

@interface SecondViewController () <KSBCameraViewControllerDelegate>

@property (nonatomic, strong) CameraViewController *cameraViewController;

@end


@implementation SecondViewController

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
    
    [self.headerStepperView setStepWithNumber:1];
    
    processors = @[[[ImageProcessor alloc] initWithImageNamed:@"1_1"],
                   [[ImageProcessor alloc] initWithImageNamed:@"2_1"],
                   [[ImageProcessor alloc] initWithImageNamed:@"3_1"],
                   [[ImageProcessor alloc] initWithImageNamed:@"1_2"],
                   [[ImageProcessor alloc] initWithImageNamed:@"2_2"],
                   [[ImageProcessor alloc] initWithImageNamed:@"3_2"]];
    
    int a = arc4random()%3;
    int b;
    if (a == 0) b = 3;
    else if (a == 1) b = 4;
    else if (a == 2) b = 5;
    KSBMovieManager *manager = [KSBMovieManager sharedInstance];
    manager.a = a;
    manager.b = b;
    
    
    
//    int a = 0;
//    int b = 1;
    
    
    //非重複判定
//    for (; ; ) {
//        b = arc4random()%10;
//        if (a!=b) {
//            break;
//        }
//    }
    
    processor_top = processors[a];
    processor_bottom = processors[b];
    
    imgFlag = YES;
    cameraFlag = YES;
    libraryFlag = NO;
    editingFlag1 = NO;
    editingFlag2 = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    
//    backgroundImgView = [[UIImageView alloc]initWithFrame:self.view.bounds];
//    backgroundImgView.image = [UIImage imageNamed:@"top_shade.png"];
//    backgroundImgView.contentMode = UIViewContentModeScaleAspectFill;
//    backgroundImgView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
//    [self.view addSubview:backgroundImgView];
    
    previewImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, kNavigationBarHeight + kDefaultMargin, CGRectGetWidth(APPFRAME_RECT), 240 * SCREEN_RECT_PERCENT)];
    previewImgView.contentMode = UIViewContentModeScaleAspectFit;
    previewImgView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:previewImgView];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]init];
    tapGesture.numberOfTapsRequired = 1;
    [tapGesture addTarget:self action:@selector(tappedPreviewImgView)];
    [previewImgView addGestureRecognizer:tapGesture];
    
    previewImgView2 = [[UIImageView alloc]initWithFrame:CGRectMake(0, previewImgView.bottom, CGRectGetWidth(APPFRAME_RECT), 240 * SCREEN_RECT_PERCENT)];
    previewImgView2.contentMode = UIViewContentModeScaleAspectFit;
    previewImgView2.backgroundColor = [UIColor clearColor];
    [self.view addSubview:previewImgView2];
    
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc]init];
    tapGesture2.numberOfTapsRequired = 1;
    [tapGesture2 addTarget:self action:@selector(tappedPreviewImgView2)];
    [previewImgView2 addGestureRecognizer:tapGesture2];
    
    backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(self.view.frame.size.width/4*3,CGRectGetHeight(SCREEN_RECT) - 50,self.view.frame.size.width/4,50);
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backBtn addTarget:self
                action:@selector(backToTop)
      forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraBtn.frame = CGRectMake(0,CGRectGetHeight(SCREEN_RECT) - 50,self.view.frame.size.width/4*3,50);
    [cameraBtn setBackgroundImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
    [cameraBtn addTarget:self
                  action:@selector(cameraOrLibrary)
        forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraBtn];
    
//    twitterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    twitterBtn.frame = CGRectMake(0, self.view.bounds.size.height-100, self.view.bounds.size.width/4, 50);
//    [twitterBtn setBackgroundImage:[UIImage imageNamed:@"twitter.png"] forState:UIControlStateNormal];
//    [twitterBtn addTarget:self
//                   action:@selector(postToTwitter)
//         forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:twitterBtn];
//    twitterBtn.hidden = YES;
//    
//    facebookBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//    facebookBtn.frame = CGRectMake(self.view.bounds.size.width/4, self.view.bounds.size.height-100, self.view.bounds.size.width/4, 50);
//    [facebookBtn setBackgroundImage:[UIImage imageNamed:@"facebook.png"] forState:UIControlStateNormal];
//    [facebookBtn addTarget:self
//                    action:@selector(postToFacebook)
//          forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:facebookBtn];
//    facebookBtn.hidden = YES;
    
    saveBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    saveBtn.frame = CGRectMake(0, CGRectGetHeight(SCREEN_RECT) - 50, self.view.frame.size.width/4*3, 50);
    saveBtn.backgroundColor = [UIColor greenColor];
    saveBtn.tintColor = [UIColor colorWithCSS:kColorCodeWhite];
    saveBtn.titleLabel.font = DEFAULT_FONT_BOLD(15);
    [saveBtn setTitle:@"この２コマに決定！" forState:UIControlStateNormal];
    [saveBtn addTarget:self
                action:@selector(saveImageToPhotosAlbum)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:saveBtn];
    saveBtn.hidden = YES;
    
    _cameraViewController = [[CameraViewController alloc]init];
    _cameraViewController.delegate = self;
    
    libraryView = [[UIImagePickerController alloc]init];
    libraryView.delegate = self;
    libraryView.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    libraryView.allowsEditing = YES;
    
    frameImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(APPFRAME_RECT), 240 * SCREEN_RECT_PERCENT)];
    frameImage.image = processor_top.effectImage;
    [_cameraViewController.view addSubview:frameImage];
    
    brankImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, frameImage.bottom, CGRectGetWidth(APPFRAME_RECT), CGRectGetHeight(SCREEN_RECT)-frameImage.bottom - 50)];
    brankImgView.backgroundColor = [UIColor blackColor];
    brankImgView.alpha = 0.7;
    [_cameraViewController.view addSubview:brankImgView];
    
    imageScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, previewImgView.frame.size.height)];
    imageScrollView.contentSize = CGSizeMake(10+(10*160), previewImgView.frame.size.height);
    imageScrollView.backgroundColor = [UIColor colorWithRed:249.0f/255.0f green:217.0f/255.0f blue:63.0f/255.0f alpha:1.0];
    imageScrollView.showsHorizontalScrollIndicator = NO;
    imageScrollView.showsVerticalScrollIndicator = NO;
    imageScrollView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height+previewImgView.frame.size.height);
    [self.view addSubview:imageScrollView];
    
    UIButton *frameImages[10];
    
    for (int i=0; i<10; i++) {
        
        frameImages[i] = [UIButton buttonWithType:UIButtonTypeCustom];
        frameImages[i].frame = CGRectMake(10+(i*160), (previewImgView.frame.size.height-133)/2, 150, 133);
        frameImages[i].backgroundColor = [UIColor blackColor];
        frameImages[i].tag = i;
        if (i==0) {
            [frameImages[i] setBackgroundImage:[UIImage imageNamed:@"1-1.png"] forState:UIControlStateNormal];
        }
        if (i==1) {
            [frameImages[i] setBackgroundImage:[UIImage imageNamed:@"2-1.png"] forState:UIControlStateNormal];
        }
        if (i==2) {
            [frameImages[i] setBackgroundImage:[UIImage imageNamed:@"2-1.png"] forState:UIControlStateNormal];
        }
        if (i==3) {
            [frameImages[i] setBackgroundImage:[UIImage imageNamed:@"1-2.png"] forState:UIControlStateNormal];
        }
        if (i==4) {
            [frameImages[i] setBackgroundImage:[UIImage imageNamed:@"2-2.png"] forState:UIControlStateNormal];
        }
        if (i==5) {
            [frameImages[i] setBackgroundImage:[UIImage imageNamed:@"3-2.png"] forState:UIControlStateNormal];
        }
             
        [frameImages[i] addTarget:self
                           action:@selector(selectedFrame:)
                 forControlEvents:UIControlEventTouchUpInside];
        [imageScrollView addSubview:frameImages[i]];
    }
    
    filters =  @[@"Original",
                 @"CISRGBToneCurveToLinear",
                 @"CIPhotoEffectChrome",
                 @"CIPhotoEffectInstant",
                 @"CIPhotoEffectMono",
                 @"CISepiaTone",
                 @"CIPhotoEffectFade",
                 @"CIPhotoEffectProcess",
                 @"CIPhotoEffectTransfer",
                 @"CIColorPosterize",
                 @"CIColorInvert",
                 ];
    
    filterNames = @[@"フィルターなし",
                    @"くっきり",
                    @"明るめ",
                    @"インスタントカメラ",
                    @"モノクロ",
                    @"セピア",
                    @"クール",
                    @"ビンテージ",
                    @"カントリー",
                    @"ポスター",
                    @"色反転",
                    ];
    
    pickerBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, previewImgView.frame.size.height)];
    pickerBackView.backgroundColor = [UIColor colorWithRed:249.0f/255.0f green:217.0f/255.0f blue:63.0f/255.0f alpha:1.0];
    pickerBackView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height+previewImgView.frame.size.height);
    [self.view addSubview:pickerBackView];
    
    filterPicView = [[UIPickerView alloc]init];
    filterPicView.delegate = self;
    filterPicView.dataSource = self;
    filterPicView.backgroundColor = [UIColor clearColor];
    [pickerBackView addSubview:filterPicView];
    pickerBackView.hidden = YES;
    
    frameTabBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    frameTabBtn.frame = CGRectMake(0, self.view.bounds.size.height+100, self.view.bounds.size.width/2, 50);
    [frameTabBtn setTitle:@"フレーム！" forState:UIControlStateNormal];
    frameTabBtn.backgroundColor = [UIColor blackColor];
    frameTabBtn.tintColor = [UIColor colorWithRed:249.0f/255.0f green:217.0f/255.0f blue:63.0f/255.0f alpha:1.0];
    frameTabBtn.titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:[UIFont labelFontSize]+5];
    frameTabBtn.tag = 1;
    [frameTabBtn addTarget:self
                    action:@selector(changeTab:)
          forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:frameTabBtn];
    
    filterTabBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    filterTabBtn.frame = CGRectMake(self.view.bounds.size.width/2, self.view.bounds.size.height+100, self.view.bounds.size.width/2, 50);
    [filterTabBtn setTitle:@"フィルター！" forState:UIControlStateNormal];
    filterTabBtn.backgroundColor = [UIColor blackColor];
    filterTabBtn.tintColor = [UIColor colorWithRed:249.0f/255.0f green:217.0f/255.0f blue:63.0f/255.0f alpha:1.0];
    filterTabBtn.titleLabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:[UIFont labelFontSize]+5];
    filterTabBtn.tag = 2;
    [filterTabBtn addTarget:self
                     action:@selector(changeTab:)
           forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:filterTabBtn];
    
    //広告
//    banner1 = [[GADBannerView alloc]initWithFrame:CGRectMake(0.0, self.view.bounds.size.height-GAD_SIZE_320x50.height, GAD_SIZE_320x50.width, GAD_SIZE_320x50.height)];
//    banner1.adUnitID = MY_BANNER_UNIT_ID;
//    banner1.rootViewController = self;
//    [self.view addSubview:banner1];
//    [banner1 loadRequest:[GADRequest request]];
}

-(void)viewDidAppear:(BOOL)animated{
    
    if (cameraFlag) {
        
        [self cameraOrLibrary];
    }
}

- (void)didPickedImage:(UIImage *)image withIsLandscape:(BOOL)isLandscape withIsFromtMode:(BOOL)isFrontMode {
    
    if (imgFlag) {
        
        CGSize size = CGSizeMake(480, 360);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        
        if (isFrontMode) {
            [image drawInRect:CGRectMake(0, 0, 480, 640)];
        }
        else {
            [image drawInRect:CGRectMake(0, 0, 480, 852)];
        }
        
        previewImgView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //オリジナルイメージの保持
        originalImage1 = previewImgView.image;
        filterImage1 = originalImage1;
        
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        [[processor_top process:previewImgView.image] drawInRect:CGRectMake(0, 0, 480, 360)];
        previewImgView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self.headerStepperView setStepWithNumber:2];
        
        cameraFlag = NO;
        imgFlag = NO;
        previewImgView.userInteractionEnabled = YES;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        
        CGSize size = CGSizeMake(480, 360);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        
        if (isFrontMode) {
            [image drawInRect:CGRectMake(0, 0, 480, 640)];
        }
        else {
            [image drawInRect:CGRectMake(0, 0, 480, 852)];
        }
        
        previewImgView2.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //オリジナルイメージの保持
        originalImage2 = previewImgView2.image;
        filterImage2 = originalImage2;
        
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        [[processor_bottom process:previewImgView2.image] drawInRect:CGRectMake(0, 0, 480, 360)];
        previewImgView2.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        cameraFlag = NO;
        
        //        cameraBtn.hidden = YES;
        //        twitterBtn.hidden = NO;
        //        facebookBtn.hidden = NO;
        saveBtn.hidden = NO;
        cameraBtn.hidden = YES;
        previewImgView2.userInteractionEnabled = YES;
        
        CGSize size2 = CGSizeMake(480, 720);
        UIGraphicsBeginImageContextWithOptions(size2, NO, 0.0);
        [previewImgView.image drawInRect:CGRectMake(0, 0, 480, 360)];
        [previewImgView2.image drawInRect:CGRectMake(0, 360, 480, 360)];
        composited_img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *getImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    if (libraryFlag) {
        getImage = [info objectForKey:UIImagePickerControllerEditedImage];
    }
    
    if (imgFlag) {
        
        CGSize size = CGSizeMake(480, 360);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        
        if (libraryFlag) {
            [getImage drawInRect:CGRectMake(0, 0, 480, 480)];
        }
        else{
            [getImage drawInRect:CGRectMake(0, 0, 480, 641)];
        }
        
        previewImgView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //オリジナルイメージの保持
        originalImage1 = previewImgView.image;
        filterImage1 = originalImage1;
        
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        [[processor_top process:previewImgView.image] drawInRect:CGRectMake(0, 0, 480, 360)];
        previewImgView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self.headerStepperView setStepWithNumber:2];
        
        cameraFlag = NO;
        imgFlag = NO;
        previewImgView.userInteractionEnabled = YES;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    else{
        
        CGSize size = CGSizeMake(480, 360);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        
        if (libraryFlag) {
            [getImage drawInRect:CGRectMake(0, 0, 480, 480)];
        }
        else{
            [getImage drawInRect:CGRectMake(0, 0, 480, 641)];
        }
        
        previewImgView2.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //オリジナルイメージの保持
        originalImage2 = previewImgView2.image;
        filterImage2 = originalImage2;
        
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        [[processor_bottom process:previewImgView2.image] drawInRect:CGRectMake(0, 0, 480, 360)];
        previewImgView2.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        cameraFlag = NO;
        
//        cameraBtn.hidden = YES;
//        twitterBtn.hidden = NO;
//        facebookBtn.hidden = NO;
        saveBtn.hidden = NO;
        cameraBtn.hidden = YES;
        previewImgView2.userInteractionEnabled = YES;
        
        CGSize size2 = CGSizeMake(480, 720);
        UIGraphicsBeginImageContextWithOptions(size2, NO, 0.0);
        [previewImgView.image drawInRect:CGRectMake(0, 0, 480, 360)];
        [previewImgView2.image drawInRect:CGRectMake(0, 360, 480, 360)];
        composited_img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)didTappedCancel {
    
    cameraFlag = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (actionSheet.tag==1) {
        
        if (buttonIndex==0) {
            libraryFlag = NO;
            [self goCameraView];
        }
        else{
            libraryFlag = YES;
            [self goLibraryView];
        }
    }
}

//ピッカービューに表示する列数を返す
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    
    return 1;
}

//ピッカービューに表示する行数を返す
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    
    return filters.count;
}

////ピッカービューに表示する文字列を返す
//-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
//    
//    return filterNames[row];
//}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    
    return 40;
}

- (UIView *)pickerView:(UIPickerView *)pictView  viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView*)view{
    
    UILabel* fontlabel = (UILabel*)view;
    
    if (!fontlabel) {
        
        fontlabel =  [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ([pictView rowSizeForComponent:component].width), 40)];
        
        fontlabel.adjustsFontSizeToFitWidth = YES;
        
        fontlabel.backgroundColor = [UIColor clearColor];
    }
    
    fontlabel.text = filterNames[row];
    
    fontlabel.font = [UIFont fontWithName:@"HiraKakuProN-W6" size:[UIFont labelFontSize]+5];
    
    fontlabel.textAlignment = NSTextAlignmentCenter;
    
    return fontlabel;
    
}

//ピッカービューで選択されたときの反応
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    //「Original」が選択されたときは加工前の画像が表示される
    if (row == 0) {
        
        if (editingFlag1) {
            
            filterImage1 = originalImage1;
            
            CGSize size = CGSizeMake(480, 360);
            UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
            [[processor_top process:originalImage1] drawInRect:CGRectMake(0, 0, 480, 360)];
            previewImgView.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        else if (editingFlag2){
            
            filterImage2 = originalImage2;
            
            CGSize size = CGSizeMake(480, 360);
            UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
            [[processor_bottom process:originalImage2] drawInRect:CGRectMake(0, 0, 480, 360)];
            previewImgView2.image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            CGSize size2 = CGSizeMake(480, 720);
            UIGraphicsBeginImageContextWithOptions(size2, NO, 0.0);
            [previewImgView.image drawInRect:CGRectMake(0, 0, 480, 360)];
            [previewImgView2.image drawInRect:CGRectMake(0, 360, 480, 360)];
            composited_img = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
        }
        
        //ここで終了させる
        return;
    }
    
    CIImage *ciImage;
    if (editingFlag1) {
        
        ciImage = [[CIImage alloc] initWithImage:originalImage1];
    }
    else if (editingFlag2){
        
        ciImage = [[CIImage alloc] initWithImage:originalImage2];
    }
    
    //フィルターを設定
    CIFilter *filter = [CIFilter filterWithName:filters[row]
                                  keysAndValues:kCIInputImageKey, ciImage, nil];
    
    //入力パラメータをデフォルトに設定
    [filter setDefaults];
    
    //フィルターを施した出力画像を生成
    CIImage *outputImage = [filter outputImage];
    
    //画像を元の向きに戻すためにCIImageをCGImageに変換
    CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:outputImage
                                                                  fromRect:[outputImage extent]];
    
    if (editingFlag1) {
        
        filterImage1 = [UIImage imageWithCGImage:cgImage];
        
        CGSize size = CGSizeMake(480, 360);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        [[processor_top process:filterImage1] drawInRect:CGRectMake(0, 0, 480, 360)];
        previewImgView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else if (editingFlag2){
        
        filterImage2 = [UIImage imageWithCGImage:cgImage];
        
        CGSize size = CGSizeMake(480, 360);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        [[processor_bottom process:filterImage2] drawInRect:CGRectMake(0, 0, 480, 360)];
        previewImgView2.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGSize size2 = CGSizeMake(480, 720);
        UIGraphicsBeginImageContextWithOptions(size2, NO, 0.0);
        [previewImgView.image drawInRect:CGRectMake(0, 0, 480, 360)];
        [previewImgView2.image drawInRect:CGRectMake(0, 360, 480, 360)];
        composited_img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    //使い終わった画像をリリース
    CGImageRelease(cgImage);
}

-(void)backToTop{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)cameraOrLibrary{
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc]initWithTitle:@"どこから画像を取得しますか？"
                                                            delegate:self
                                                   cancelButtonTitle:nil
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"カメラ",@"フォトライブラリ", nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actionSheet.tag=1;
    [actionSheet showInView:self.view];
}

-(void)goCameraView{
    
    if (imgFlag) {
        [self presentViewController:_cameraViewController animated:YES completion:nil];
    }
    else{
        frameImage.image = processor_bottom.effectImage;
        [self presentViewController:_cameraViewController animated:YES completion:nil];
    }
}

-(void)goLibraryView{
    
    if (imgFlag) {
        [self presentViewController:libraryView animated:YES completion:nil];
    }
    else{
        frameImage.image = processor_bottom.effectImage;
        [self presentViewController:libraryView animated:YES completion:nil];
    }
}

-(void)saveImageToPhotosAlbum{
    
    // 次のステップへ！
    // Managerに一時保存
    KSBMovieManager *manager = [KSBMovieManager sharedInstance];
    manager.image = composited_img;
    
    // 画面遷移
    KSBBgmSettingViewController *bsvc = [[KSBBgmSettingViewController alloc] init];
    [self.navigationController pushViewController:bsvc animated:YES];
    
    
    //画像をフォトアルバムに保存
//    UIImageWriteToSavedPhotosAlbum(composited_img, nil, nil, nil);
//    
//    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"写真の保存"
//                                                   message:@"写真をカメラロールに保存したぜ！"
//                                                  delegate:self
//                                         cancelButtonTitle:nil
//                                         otherButtonTitles:@"OK", nil];
//    [alert show];
}

-(void)postToTwitter{
    
    if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Twitterエラー"
                                                       message:@"Twitterアカウントが設定されていません"
                                                      delegate:nil
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@"OK", nil];
        [alert show];
    }
    else{
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [controller addImage:composited_img];
        controller.completionHandler = ^(SLComposeViewControllerResult result){
            
            NSString *socialType = @"Twitter";
            
            switch (result) {
                case SLComposeViewControllerResultDone:
                    
                    [self alertForSLComposeViewControllerResult:socialType resultNum:0];
                    break;
                case SLComposeViewControllerResultCancelled:
                    
                    [self alertForSLComposeViewControllerResult:socialType resultNum:1];
                    break;
                default:
                    
                    [self alertForSLComposeViewControllerResult:socialType resultNum:2];
                    break;
            }
            
            
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        
        [self presentViewController:controller
                                     animated:YES
                                   completion:^{
                                       NSLog(@"%@",controller.view.subviews);
                                   }];
    }
}

-(void)postToFacebook{
    
    if (![SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Facebookエラー"
                                                       message:@"Facebookアカウントが設定されていません"
                                                      delegate:nil
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@"OK", nil];
        [alert show];
    }
    else{
        
        SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [controller addImage:composited_img];
        
        controller.completionHandler = ^(SLComposeViewControllerResult result){
            
            NSString *socialType = @"Facebook";
            
            switch (result) {
                case SLComposeViewControllerResultDone:
                    
                    
                    [self alertForSLComposeViewControllerResult:socialType resultNum:0];
                    break;
                case SLComposeViewControllerResultCancelled:
                    
                    [self alertForSLComposeViewControllerResult:socialType resultNum:1];
                    break;
                default:
                    
                    [self alertForSLComposeViewControllerResult:socialType resultNum:2];
                    break;
            }
            
            
            [self dismissViewControllerAnimated:YES completion:nil];
        };
        
        [self presentViewController:controller animated:YES completion:nil];
    }
}

-(void)alertForSLComposeViewControllerResult:(NSString *)socialType resultNum:(int)resultNum{
    
    if (resultNum==0) {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"投稿完了！"
                                                       message:[NSString stringWithFormat:@"%@への投稿が完了しました！",socialType]
                                                      delegate:nil
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@"OK", nil];
        [alert show];
    }
    else if (resultNum==1){
        
        //キャンセルした場合は、特に表示しない
    }
    else if (resultNum==2){
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"予期せぬエラー"
                                                       message:[NSString stringWithFormat:@"%@への投稿に失敗しました、、、",socialType]
                                                      delegate:nil
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@"OK", nil];
        [alert show];
    }
}

-(void)tappedPreviewImgView{
    
    if (editingFlag1) {
        
        previewImgView.userInteractionEnabled = NO;
        previewImgView2.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:0.4
                              delay:0.0
             usingSpringWithDamping:0.5
              initialSpringVelocity:0.6
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             frameTabBtn.center = CGPointMake(self.view.bounds.size.width/4, self.view.bounds.size.height+75);
                             filterTabBtn.center = CGPointMake(self.view.bounds.size.width/4*3, self.view.bounds.size.height+75);
                             imageScrollView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height+previewImgView.frame.size.height);
                             pickerBackView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height+previewImgView.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             
                             editingFlag1 = NO;
                             previewImgView.userInteractionEnabled = YES;
                             if (previewImgView2.image!=nil)previewImgView2.userInteractionEnabled = YES;
                         }];

    }
    else{
        
        previewImgView.userInteractionEnabled = NO;
        previewImgView2.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:0.4
                              delay:0.0
             usingSpringWithDamping:0.5
              initialSpringVelocity:0.6
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             frameTabBtn.center = CGPointMake(self.view.bounds.size.width/4, self.view.bounds.size.height-75);
                             filterTabBtn.center = CGPointMake(self.view.bounds.size.width/4*3, self.view.bounds.size.height-75);
                             imageScrollView.center = previewImgView2.center;
                             pickerBackView.center = previewImgView2.center;
                         }
                         completion:^(BOOL finished) {
                             
                             editingFlag1 = YES;
                             previewImgView.userInteractionEnabled = YES;
                         }];
    }
}

-(void)changeTab:(UIButton *)button{
    
    if (button.tag==1) {
        
        imageScrollView.hidden = NO;
        pickerBackView.hidden = YES;
    }
    else if (button.tag==2){
        
        imageScrollView.hidden = YES;
        pickerBackView.hidden = NO;
    }
}

-(void)tappedPreviewImgView2{
    
    if (editingFlag2) {
        
        previewImgView.userInteractionEnabled = NO;
        previewImgView2.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:0.4
                              delay:0.0
             usingSpringWithDamping:0.5
              initialSpringVelocity:0.6
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             previewImgView2.center = beforePoint;
                             frameTabBtn.center = CGPointMake(self.view.bounds.size.width/4, self.view.bounds.size.height+75);
                             filterTabBtn.center = CGPointMake(self.view.bounds.size.width/4*3, self.view.bounds.size.height+75);
                             imageScrollView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height+previewImgView.frame.size.height);
                             pickerBackView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height+previewImgView.frame.size.height);
                         }
                         completion:^(BOOL finished) {
                             
                             editingFlag2 = NO;
                             previewImgView.userInteractionEnabled = YES;
                             previewImgView2.userInteractionEnabled = YES;
                         }];
    }
    else{
        
        beforePoint = previewImgView2.center;
        previewImgView.userInteractionEnabled = NO;
        previewImgView2.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:0.4
                              delay:0.0
             usingSpringWithDamping:0.5
              initialSpringVelocity:0.6
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             
                             previewImgView2.center = previewImgView.center;
                             frameTabBtn.center = CGPointMake(self.view.bounds.size.width/4, self.view.bounds.size.height-75);
                             filterTabBtn.center = CGPointMake(self.view.bounds.size.width/4*3, self.view.bounds.size.height-75);
                             imageScrollView.center = beforePoint;
                             pickerBackView.center = beforePoint;
                         }
                         completion:^(BOOL finished) {
                             
                             editingFlag2 = YES;
                             previewImgView2.userInteractionEnabled = YES;
                         }];
    }
}

-(void)selectedFrame:(UIButton *)button{
    
    if (editingFlag1) {
        
        processor_top = processors[button.tag];
        
        CGSize size = CGSizeMake(480, 360);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        [[processors[button.tag] process:filterImage1] drawInRect:CGRectMake(0, 0, 480, 360)];
        previewImgView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else if (editingFlag2){
        
        processor_bottom = processors[button.tag];
        
        CGSize size = CGSizeMake(480, 360);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        [[processors[button.tag] process:filterImage2] drawInRect:CGRectMake(0, 0, 480, 360)];
        previewImgView2.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        CGSize size2 = CGSizeMake(480, 720);
        UIGraphicsBeginImageContextWithOptions(size2, NO, 0.0);
        [previewImgView.image drawInRect:CGRectMake(0, 0, 480, 360)];
        [previewImgView2.image drawInRect:CGRectMake(0, 360, 480, 360)];
        composited_img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
