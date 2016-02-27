//
//  SecondViewController.h
//  COMIX
//
//  Created by Keisuke_Tatsumi on 2014/07/29.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageProcessor.h"
#import "KSBStepperViewController.h"
//#import "GADBannerView.h"
//#define MY_BANNER_UNIT_ID @"ca-app-pub-1043692751731091/1099515967"

@interface SecondViewController : KSBStepperViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
{
    UIImagePickerController *cameraView;
    UIImagePickerController *libraryView;
    UIImageView *backgroundImgView;
    UIImageView *previewImgView;
    UIImageView *previewImgView2;
    UIImageView *frameImage;
    UIImageView *brankImgView;
    UIImage *originalImage1;
    UIImage *originalImage2;
    UIImage *filterImage1;
    UIImage *filterImage2;
    UIImage *composited_img;
    UIButton *cameraBtn;
    UIButton *backBtn;
    UIButton *twitterBtn;
    UIButton *facebookBtn;
    UIButton *saveBtn;
    UIScrollView *imageScrollView;
    UIPickerView *filterPicView;
    UIView *pickerBackView;
    UIButton *frameTabBtn;
    UIButton *filterTabBtn;
    CGPoint beforePoint;
    NSArray *filters;
    NSArray *filterNames;
    NSArray *processors;
    ImageProcessor *processor_top;
    ImageProcessor *processor_bottom;
    BOOL cameraFlag;
    BOOL imgFlag;
    BOOL libraryFlag;
    BOOL editingFlag1;
    BOOL editingFlag2;
    
//    GADBannerView *banner1;
}
@end
