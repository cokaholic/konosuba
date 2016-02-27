//
//  KSBBgmTrimViewController.m
//  konosuba
//
//  Created by Keisuke_Tatsumi on 2016/02/28.
//  Copyright © 2016年 Keisuke Tatsumi. All rights reserved.
//

#import "KSBBgmTrimViewController.h"

@interface KSBBgmTrimViewController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *doneButton;

@end

@implementation KSBBgmTrimViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.headerStepperView setStepWithNumber:4];
    
    [self titleLabel];
    [self configDoneButton];
}

- (void)configTitleLabel {
    
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, kStepperBottomHeight, CGRectGetWidth(APPFRAME_RECT), 40)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = DEFAULT_FONT_BOLD(20);
    _titleLabel.text = @"BGMのトリミング";
    [self.view addSubview:_titleLabel];
}

- (void)configDoneButton {
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _doneButton.frame = CGRectMake(0, CGRectGetHeight(APPFRAME_RECT) - 40 - kDefaultMargin, _titleLabel.width, 40);
    _doneButton.backgroundColor = [UIColor greenColor];
    [_doneButton setTitle:@"アニメを生成" forState:UIControlStateNormal];
    _doneButton.tintColor = [UIColor colorWithCSS:kColorCodeWhite];
    _doneButton.titleLabel.font = DEFAULT_FONT_BOLD(15);
    [_doneButton addTarget:self
                    action:@selector(showConvertViewController)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_doneButton];
}

- (void)showConvertViewController {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
