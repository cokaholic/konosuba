//
//  KSBResultViewController.m
//  konosuba
//
//  Created by 石橋 弦樹 on 2016/02/28.
//  Copyright © 2016年 Keisuke Tatsumi. All rights reserved.
//

#import "KSBResultViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "AVPlayerView.h"

@interface KSBResultViewController ()

@property (nonatomic, strong) AVPlayerView *playerView;
@property (nonatomic, strong) AVPlayer *player;

@end

@implementation KSBResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self config];
    
    // `status`の変化を監視
    [self.player addObserver:self
                  forKeyPath:@"status"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
}

- (void)config {
    
    // 動画のURLを生成
//    NSString *fileName = @"final_video_file";
    NSString *fileName = @"tmpMovie";
    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *path = [NSString stringWithFormat:@"%@/%@.mp4", destPath, fileName];
    NSURL *url = [NSURL fileURLWithPath:path];
    
    // URLを元に`AVPlayer`を生成
    self.player = [[AVPlayer alloc] initWithURL:url];
    
    // viewのlayerに`AVPlayer`のインスタンスをセット
    CGRect playerViewFrame = CGRectMake(kDefaultMargin, kStepperBottomHeight, self.view.size.width - kDefaultMargin * 2, self.view.size.height / 2.0);
    self.playerView = [[AVPlayerView alloc] initWithFrame:playerViewFrame];
    [self.playerView setBackgroundColor:[UIColor redColor]];
    [(AVPlayerLayer*)self.playerView.layer setPlayer:self.player];
    [self.view addSubview:self.playerView];
    
    // リプレイボタン
    CGRect repBtnFrm = CGRectMake(kDefaultMargin, playerViewFrame.size.height + kStepperBottomHeight + kDefaultMargin, self.view.size.width - kDefaultMargin * 2, 44);
    UIButton *repBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    repBtn.frame = repBtnFrm;
    [repBtn setTitle:@"リプレイ" forState:UIControlStateNormal];
    [repBtn addTarget:self action:@selector(replay) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:repBtn];
}

- (void)replay {
    [self.player seekToTime:kCMTimeZero];
    [self.player play];
}

// `status`の値を監視して、再生可能になったら再生
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSLog(@"observe");
    if (self.player.status == AVPlayerItemStatusReadyToPlay) {
        NSLog(@"play");
        [self.player removeObserver:self forKeyPath:@"status"];
        [self.playerView setPlayer:self.player];
        [self.player play];
        
        AVPlayerItem *item = [self.player currentItem];
        CMTime cmTime = item.asset.duration;
        Float64 sec = CMTimeGetSeconds(cmTime);
        NSLog(@"playerduration:%f", sec);
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
