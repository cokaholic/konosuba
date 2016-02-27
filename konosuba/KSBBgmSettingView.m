//
//  KSBBgmSettingView.m
//  konosuba
//
//  Created by 石橋 弦樹 on 2016/02/27.
//  Copyright © 2016年 Keisuke Tatsumi. All rights reserved.
//

#import "KSBBgmSettingView.h"

@implementation KSBBgmSettingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)drawBgmSettingInView:(UIView *)containerView headerView:(UIView *)headerView {
    
    NSLog(@"%@", NSStringFromCGRect(headerView.frame));
    CGRect drawableRect = CGRectMake(
        kDefaultMargin,
        headerView.origin.y + kDefaultMargin,
        containerView.bounds.size.width - kDefaultMargin * 2,
        containerView.bounds.size.height - headerView.height - kDefaultMargin * 2);
//    CGRect innerRect = CGRectMake( kDefaultMargin, kDefaultMargin,
//                                  containerView.bounds.size.width - kDefaultMargin * 2,
//                                  containerView.bounds.size.height - kDefaultMargin * 2);
    CGFloat kHeight = 100;
    drawableRect.size.height = kHeight;
 
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:drawableRect];
    titleLabel.text = @"BGMの設定";
    [containerView addSubview:titleLabel];
}

@end
