//
//  KSBConvertViewController.m
//  konosuba
//
//  Created by 石橋 弦樹 on 2016/02/28.
//  Copyright © 2016年 Keisuke Tatsumi. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import "KSBConvertViewController.h"
#import "KSBResultViewController.h"
#import "KSBAnimationAction.h"
#import "KSBMovieManager.h"

@interface KSBConvertViewController ()

@end

@implementation KSBConvertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.headerStepperView setStepWithNumber:4];
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    [SVProgressHUD showInfoWithStatus:@"動画変換中"];
    
    //動画生成条件
    KSBMovieManager *manager = [KSBMovieManager sharedInstance];
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:manager.image];
    KSBAnimationAction *action1 = [[KSBAnimationAction alloc] init];
    KSBAnimationAction *action2 = [[KSBAnimationAction alloc] init];
    KSBAnimationAction *action3 = [[KSBAnimationAction alloc] init];
    
    // 移動後のframe
    CGRect d = imgView.frame;
    d.origin.y += 200;
    
    [action1 setDuration:2 srcFrame:imgView.frame destFrame:imgView.frame];
    [manager addAnimationAction:action1];
    [action2 setDuration:3 srcFrame:imgView.frame destFrame:d];
    [manager addAnimationAction:action2];
    [action3 setDuration:2 srcFrame:d destFrame:d];
    [manager addAnimationAction:action3];
    
//    [manager animationDuration:3 frameRate:40 srcFrame:imgView.frame destFrame:d];
    
    [manager startMakingMovieWithFPS:30];
    
    [SVProgressHUD dismiss];
    KSBResultViewController *rvc = [[KSBResultViewController alloc] init];
    [self.navigationController pushViewController:rvc animated:YES];
    
}

- (void)setMakeMovieActions {
    
}
@end
