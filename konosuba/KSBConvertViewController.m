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
    CGRect d = imgView.frame;
    d.origin.y += 200;
    
    KSBAnimationAction *action1 = [[KSBAnimationAction alloc] initWithImageView:imgView duration:@(2) destValue:[NSValue valueWithCGPoint:imgView.origin] scale:@(2)];
    KSBAnimationAction *action2 = [[KSBAnimationAction alloc] initWithImageView:action1.afterImageView duration:@(2) destValue:[NSValue valueWithCGPoint:d.origin] scale:@(1)];
    KSBAnimationAction *action3 = [[KSBAnimationAction alloc] initWithImageView:action2.afterImageView duration:@(2) destValue:[NSValue valueWithCGPoint:d.origin] scale:@(0.5)];
    
    // 移動後のframe
    
    [manager addAnimationAction:action1];
    [manager addAnimationAction:action2];
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
