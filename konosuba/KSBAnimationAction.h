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

- (void)setDuration:(NSTimeInterval)duration srcFrame:(CGRect)srcFrame destFrame:(CGRect)destFrame;
- (NSTimeInterval)getDuration;
- (CGRect)getSrcFrame;
- (CGRect)getDestFrame;

@end
