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
    
    // 動画のURLを生成
    NSString *urlString = @"https://example.com/hoge.mp4";
    NSURL *url = [NSURL URLWithString:urlString];
    
    // URLを元に`AVPlayer`を生成
    self.player = [[AVPlayer alloc] initWithURL:url];
    
    // viewのlayerに`AVPlayer`のインスタンスをセット
    self.playerView = [[AVPlayerView alloc] initWithFrame:self.view.frame];
    [(AVPlayerLayer*)self.playerView.layer setPlayer:self.player];
    
    // 該当のビューを表示
    [self.view addSubview:self.playerView];
    
    // `status`の変化を監視
    [self.player addObserver:self
                  forKeyPath:@"status"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
}

// `status`の値を監視して、再生可能になったら再生
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (self.player.status == AVPlayerItemStatusReadyToPlay) {
        [self.player removeObserver:self forKeyPath:@"status"];
        [self.player play];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
