//
//  ImageProcessor.m
//  COMIX
//
//  Created by Keisuke_Tatsumi on 2014/07/29.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import "ImageProcessor.h"

@implementation ImageProcessor

-(id)initWithImageNamed:(NSString*)effectImagePath{
    
    self.effectImage = [UIImage imageNamed:effectImagePath];
    
    return self;
}

-(UIImage *)process:(UIImage *)fromImage{
    
    CGRect frame = CGRectMake(0, 0, 320, 284);
    UIGraphicsBeginImageContextWithOptions(frame.size, NO, 0.0);
    
    [fromImage drawInRect:frame];
    [self.effectImage drawInRect:frame];
    
    UIImage *getImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return getImage;
}

@end
