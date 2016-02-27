//
//  GIAnimatioonAction.m
//  sample
//
//  Created by 石橋 弦樹 on 2016/02/27.
//  Copyright © 2016年 石橋 弦樹. All rights reserved.
//

#import "KSBAnimationAction.h"

@implementation KSBAnimationAction{
    NSTimeInterval _duration;
    CGRect _srcFrame;
    CGRect _destFrame;
}

- (void)setDuration:(NSTimeInterval)duration srcFrame:(CGRect)srcFrame destFrame:(CGRect)destFrame {
    _duration = duration;
    _srcFrame = srcFrame;
    _destFrame = destFrame;
}

- (NSTimeInterval)getDuration {
    return _duration;
}

- (CGRect)getSrcFrame {
    return _srcFrame;
}

- (CGRect)getDestFrame {
    return _destFrame;
}

@end
