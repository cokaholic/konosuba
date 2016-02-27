//
//  ImageProcessor.h
//  COMIX
//
//  Created by Keisuke_Tatsumi on 2014/07/29.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface ImageProcessor : NSObject

@property(nonatomic, strong)UIImage *effectImage;

-(id)initWithImageNamed:(NSString*)effectImagePath;

-(UIImage *)process:(UIImage *)fromImage;

@end
