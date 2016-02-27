//
//  KSBTopViewController.m
//  konosuba
//
//  Created by Keisuke_Tatsumi on 2016/02/27.
//  Copyright © 2016年 Keisuke Tatsumi. All rights reserved.
//

#import "KSBTopViewController.h"
#import "KSBBgmSettingViewController.h"

@implementation KSBTopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.headerStepperView setStepWithNumber:1];
    
    // デバッグ用に自動で遷移
    KSBBgmSettingViewController *bsvc = [[KSBBgmSettingViewController alloc] init];
    [self.navigationController pushViewController:bsvc animated:YES];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
