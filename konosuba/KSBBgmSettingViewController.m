//
//  GIBgmSettingViewController.m
//  konosuba
//
//  Created by 石橋 弦樹 on 2016/02/27.
//  Copyright © 2016年 Keisuke Tatsumi. All rights reserved.
//

#import "KSBBgmSettingViewController.h"
#import "KSBBgmSettingView.h"

@interface KSBBgmSettingViewController ()

@end

@implementation KSBBgmSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.headerStepperView setStepWithNumber:3];
    
    [self configBgmSettingView];
}

- (void)configBgmSettingView {
    [[[KSBBgmSettingView alloc] init] drawBgmSettingInView:self.view headerView:self.headerStepperView];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    NSLog(@"メモリやばいよ！！");
}

@end