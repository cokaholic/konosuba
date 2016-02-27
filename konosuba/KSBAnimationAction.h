//
//  GIAnimatioonAction.h
//  sample
//
//  Created by 石橋 弦樹 on 2016/02/27.
//  Copyright © 2016年 石橋 弦樹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface KSBAnimationAction : NSObject

@property(nonatomic, retain) UIImageView *imageView;
@property(nonatomic, retain) NSNumber *duration;
@property(nonatomic, retain) NSValue *destValue;
@property(nonatomic, retain) NSNumber *scale;

- (id)initWithImageView:(UIImageView *)imageView
                 duration:(NSNumber *)duration
                destValue:(NSValue *)destValue
                    scale:(NSNumber *)scale;

- (UIImageView *)afterImageView;

//- (void)setDuration:(NSTimeInterval)duration srcFrame:(CGRect)srcFrame destFrame:(CGRect)destFrame;
//- (NSTimeInterval)getDuration;
//- (CGRect)getSrcFrame;
//- (CGRect)getDestFrame;

@end
