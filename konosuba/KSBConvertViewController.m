//
//  KSBConvertViewController.m
//  konosuba
//
//  Created by 石橋 弦樹 on 2016/02/28.
//  Copyright © 2016年 Keisuke Tatsumi. All rights reserved.
//

#import <SVProgressHUD/SVProgressHUD.h>
#import <AVFoundation/AVFoundation.h>
#import "KSBConvertViewController.h"
#import "KSBResultViewController.h"
#import "KSBAnimationAction.h"
#import "KSBMovieManager.h"
#import "KSBAVAssetManager.h"

@interface KSBConvertViewController ()

@end

@implementation KSBConvertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.headerStepperView setStepWithNumber:4];
    
    [SVProgressHUD showInfoWithStatus:@"動画変換中"];
}

- (void)viewDidAppear:(BOOL)animated {
    
    [self setMakeMovieActions];
}

- (void)setMakeMovieActions {
    
    
    
    // 動画の長さを取得
    NSString *fileName1 = @"1_1";
    NSString *fileName2 = @"1_2";
    NSURL *v1Path = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName1 ofType:@"mp3"]];
    NSURL *v2Path = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName2 ofType:@"mp3"]];
    AVAsset *asset1 = [AVAsset assetWithURL:v1Path];
    AVAsset *asset2 = [AVAsset assetWithURL:v2Path];
    AVPlayerItem *playerItem1 = [AVPlayerItem playerItemWithAsset:asset1];
    AVPlayerItem *playerItem2 = [AVPlayerItem playerItemWithAsset:asset2];
    CMTime cmTime1 = playerItem1.asset.duration;
    CMTime cmTime2 = playerItem2.asset.duration;
    Float64 sec1 = CMTimeGetSeconds(cmTime1);
    Float64 sec2 = CMTimeGetSeconds(cmTime2);
    Float64 moveTime = 0.01;
    
    //動画生成条件
    KSBMovieManager *manager = [KSBMovieManager sharedInstance];
    
    
    UIImageView *imgView = [[UIImageView alloc] initWithImage:manager.image];
    CGRect d = imgView.frame;
    d.origin.y += 200;
    
    
    KSBAnimationAction *action1 = [[KSBAnimationAction alloc] initWithImageView:imgView duration:@(sec1) destValue:[NSValue valueWithCGPoint:imgView.origin] scale:@(2)];
    KSBAnimationAction *action2 = [[KSBAnimationAction alloc] initWithImageView:action1.afterImageView duration:@(moveTime) destValue:[NSValue valueWithCGPoint:d.origin] scale:@(1)];
    KSBAnimationAction *action3 = [[KSBAnimationAction alloc] initWithImageView:action2.afterImageView duration:@(sec2) destValue:[NSValue valueWithCGPoint:d.origin] scale:@(0.5)];
    
    [manager addAnimationAction:action1];
    [manager addAnimationAction:action2];
    [manager addAnimationAction:action3];
    
    NSLog(@"Starting make movie from image");
    [manager startMakingMovieWithFPS:30];
    NSLog(@"completed make video");
    
    [SVProgressHUD showInfoWithStatus:@"音声貼り付け中"];
    NSLog(@"音声の貼付け中");
    
    /* -----音声ファイルの合成-------*/
    // 音声ファイルのパス
//    NSString *fileName = @"tmpMovie";
//    NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *tmpMoviePath = [NSString stringWithFormat:@"%@/%@.mp4", destPath, fileName];
//    
//    KSBAVAssetManager *assetManager = [KSBAVAssetManager sharedInstance];
//    [assetManager clear];
//    
//    [assetManager addVideoAssetWithFilePath:tmpMoviePath withVolume:1.0];
//    [assetManager addAudioAssetWithFilePath:[[NSBundle mainBundle] pathForResource:fileName1 ofType:@"mp3"]
//                              withStartTime:0
//                               withPlayTime:sec1
//                             withInsertTime:0
//                                 withVolume:1
//     ];
//    [assetManager addAudioAssetWithFilePath:[[NSBundle mainBundle] pathForResource:fileName2 ofType:@"mp3"]
//                              withStartTime:0
//                               withPlayTime:sec2
//                             withInsertTime:(sec1 - 2)
//                                 withVolume:1
//     ];
//    
//    [assetManager merge:^(BOOL finished) {
//        if (finished) {
//            [assetManager saveToLibrary:^(BOOL finished,NSError *error){
//                if (finished) {
//                    [SVProgressHUD dismiss];
//                    KSBResultViewController *rvc = [[KSBResultViewController alloc] init];
//                    [self.navigationController pushViewController:rvc animated:YES];
//                }
//            }];
//        }
//    }];
}
@end
