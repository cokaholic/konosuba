//
//  AVPlayerView.m
//  konosuba
//
//  Created by 石橋 弦樹 on 2016/02/28.
//  Copyright © 2016年 Keisuke Tatsumi. All rights reserved.
//

#import "AVPlayerView.h"

@implementation AVPlayerView

+(Class)layerClass
{
    return [AVPlayerLayer class];
}

- (AVPlayer *)player {
    return [(AVPlayerLayer *)[self layer] player];
}

- (void)setPlayer:(AVPlayer *)player {
    
    [(AVPlayerLayer *)[self layer] setPlayer:player];
}

@end
