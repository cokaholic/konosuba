//
//  UIImage+Util.m
//  sample
//
//  Created by 石橋 弦樹 on 2016/02/27.
//  Copyright © 2016年 石橋 弦樹. All rights reserved.
//

#import "UIImage+Util.h"

@implementation UIImage(Util)

+ (UIImage *)imageWithColor:(UIColor *)color {
//    CGRect rect = CGRectMake(0, 0, 375, 667);
    CGRect rect = CGRectZero;
    CGSize s = CGSizeMake(400, 666);
    rect.size = s;
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
