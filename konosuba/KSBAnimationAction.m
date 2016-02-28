//
//  GIAnimatioonAction.m
//  sample
//
//  Created by 石橋 弦樹 on 2016/02/27.
//  Copyright © 2016年 石橋 弦樹. All rights reserved.
//

#import "KSBAnimationAction.h"

@implementation KSBAnimationAction{
//    NSTimeInterval _duration;
//    CGRect _srcFrame;
//    CGRect _destFrame;
}

- (id)initWithImageView:(UIImageView *)imageView
                 duration:(NSNumber *)duration
                destValue:(NSValue *)destValue
                  scale:(NSNumber *)scale {
    if (self != nil) {
        self.imageView = imageView;
        self.duration = duration;
        self.destValue = destValue;
        self.scale = scale;
    }
    return self;
}

// 使えない
- (UIImageView *)afterImageView {
    CGRect newRect = self.imageView.frame;
    newRect.origin = self.destValue.CGPointValue;
    
    // UIImageのりサイズ
//    UIImage *img_af;
//    float widthPer = self.scale.doubleValue;
//    float heightPer = self.scale.doubleValue;
//    
//    CGRect newRect = CGRectZero;
//    newRect.origin = self.destValue.CGPointValue;
//    newRect.size = CGSizeMake(self.imageView.size.width * widthPer, self.imageView.size.height * heightPer);
    self.imageView.frame = newRect;
//    CGSize resize = CGSizeMake(self.imageView.size.width * widthPer, self.imageView.size.height * heightPer);
//    UIGraphicsBeginImageContext(resize);
//    [self.imageView.image drawInRect:CGRectMake(0, 0, resize.width, resize.height)];
//    img_af = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
//    UIImageView *newImageView = [[UIImageView alloc] initWithImage:img_af];
//    UIImageView *newImageView = [[UIImageView alloc] initWithFrame:newRect];
//    newImageView.image = self.imageView.image;
//    CGRect tmpRect = newImageView.frame;
//    tmpRect.origin = newRect.origin;
//    newImageView.frame = tmpRect;
//    newRect.size = img_af.size;
//    UIImageView *newImageView = [[UIImageView alloc] initWithFrame:newRect];
//    newImageView.image = img_af;
    return self.imageView;

}

//- (void)setDuration:(NSTimeInterval)duration srcFrame:(CGRect)srcFrame destFrame:(CGRect)destFrame {
//    _duration = duration;
//    _srcFrame = srcFrame;
//    _destFrame = destFrame;
//}
//
//- (NSTimeInterval)getDuration {
//    return _duration;
//}
//
//- (CGRect)getSrcFrame {
//    return _srcFrame;
//}
//
//- (CGRect)getDestFrame {
//    return _destFrame;
//}

@end
