//
//  KSBStepperViewController.m
//  konosuba
//
//  Created by Keisuke_Tatsumi on 2016/02/27.
//  Copyright © 2016年 Keisuke Tatsumi. All rights reserved.
//

#import "KSBStepperViewController.h"

@interface KSBStepperViewController ()

@end

@implementation KSBStepperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configStepperView];
}

- (void)configStepperView {
    
    _headerStepperView = [[StepperView alloc]init];
    _headerStepperView.startX = 0.0f;
    _headerStepperView.startY = 0.0f;
    _headerStepperView.numberTotalStep = kStepperTotalNumberOfpage;
    [_headerStepperView drawStepperInView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
