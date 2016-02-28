//
//  KSBBgmTrimViewController.m
//  konosuba
//
//  Created by Keisuke_Tatsumi on 2016/02/28.
//  Copyright © 2016年 Keisuke Tatsumi. All rights reserved.
//

#import "KSBBgmTrimViewController.h"
#import "RETrimControl.h"
#import "KSBResultViewController.h"
#import "KSBMovieManager.h"
#import "KSBAVAssetManager.h"
#import <AVFoundation/AVFoundation.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "KSBAVAssetManager.h"

@interface KSBBgmTrimViewController () <RETrimControlDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *doneButton;
@property (nonatomic, strong) UIButton *skipButton;
@property (nonatomic, strong) UIScrollView *trimBaseScrollView;
@property (nonatomic, strong) RETrimControl *trimControl;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, assign) CGFloat leftValue;
@property (nonatomic, assign) CGFloat rightValue;
@property (nonatomic, assign) BOOL isPlaying;
@property (nonatomic, assign) BOOL isProcessing;
@property (nonatomic, assign) BOOL isWaitingSelector;

@end

@implementation KSBBgmTrimViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _isPlaying = NO;
    _isProcessing = NO;
    _isWaitingSelector = NO;
    
    [self.headerStepperView setStepWithNumber:4];
    
    [self configAudioFile];
    
    [self configTitleLabel];
    [self configTrimControl];
    [self configPlayButton];
    [self configSkipButton];
    [self configDoneButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [_player pause];
    _isPlaying = NO;
}

- (void)configAudioFile {
    
    _isProcessing = YES;
    
    AVAsset *asset = [AVAsset assetWithURL:_fileURL];
    _playerItem = [AVPlayerItem playerItemWithAsset:asset];
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    
    [_player addObserver:self
              forKeyPath:@"status"
                 options:NSKeyValueObservingOptionNew
                 context:&_player];
}


- (void)configTitleLabel {
    
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, kStepperBottomHeight, CGRectGetWidth(APPFRAME_RECT), 40)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = DEFAULT_FONT_BOLD(20);
    _titleLabel.text = @"BGMのトリミング";
    [self.view addSubview:_titleLabel];
}

- (void)configTrimControl {
    CMTime cmTime = _playerItem.asset.duration;
    Float64 sec = CMTimeGetSeconds(cmTime);
    Float64 numberOfWidth = (sec/30.0f);
    
    _trimBaseScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, _titleLabel.bottom, _titleLabel.width, 100)];
    _trimBaseScrollView.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.4];
    _trimBaseScrollView.contentSize = CGSizeMake(CGRectGetWidth(APPFRAME_RECT)*numberOfWidth, 100);
    [self.view addSubview:_trimBaseScrollView];
    
    _trimControl = [[RETrimControl alloc]initWithFrame:CGRectMake(kDefaultMargin*2, 36, CGRectGetWidth(APPFRAME_RECT)*numberOfWidth - kDefaultMargin*4, 28)];
    _trimControl.length = sec;
    _trimControl.maxDuration = 10.0;
    _trimControl.delegate = self;
    _trimControl.userInteractionEnabled = NO;
    [_trimBaseScrollView addSubview:_trimControl];
}

- (void)configPlayButton {
    
    _playButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    _playButton.backgroundColor = [UIColor greenColor];
    [_playButton addTarget:self
                    action:@selector(playOrStop)
          forControlEvents:UIControlEventTouchUpInside];
    _playButton.enabled = NO;
    _playButton.center = CGPointMake(_trimBaseScrollView.contentCenter.x, _trimBaseScrollView.bottom + _playButton.height/2 + kDefaultMargin);
    [self.view addSubview:_playButton];
}

- (void)configSkipButton {
    
    _skipButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _skipButton.frame = CGRectMake(kDefaultMargin, CGRectGetHeight(APPFRAME_RECT) - 80 - kDefaultMargin, _titleLabel.width - kDefaultMargin*2, 40);
    _skipButton.backgroundColor = [UIColor yellowColor];
    [_skipButton setTitle:@"BGMを入れない" forState:UIControlStateNormal];
    _skipButton.tintColor = [UIColor colorWithCSS:kColorCodeWhite];
    _skipButton.titleLabel.font = DEFAULT_FONT_BOLD(15);
    [_skipButton addTarget:self
                    action:@selector(showConvertViewController)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_skipButton];
}

- (void)configDoneButton {
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _doneButton.frame = CGRectMake(kDefaultMargin, CGRectGetHeight(APPFRAME_RECT) - 40 + kDefaultMargin, _titleLabel.width - kDefaultMargin*2, 40);
    _doneButton.backgroundColor = [UIColor greenColor];
    [_doneButton setTitle:@"アニメを生成" forState:UIControlStateNormal];
    _doneButton.tintColor = [UIColor colorWithCSS:kColorCodeWhite];
    _doneButton.titleLabel.font = DEFAULT_FONT_BOLD(15);
    [_doneButton addTarget:self
                    action:@selector(addBGM)
          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_doneButton];
}

- (void)playOrStop {
    
    if (_isProcessing) {
        return;
    }
    
    if (_isWaitingSelector) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                 selector:@selector(pausePlayer)
                                                   object:nil];
        _isWaitingSelector = NO;
    }
    
    if (_isPlaying) {
        [_player pause];
    }
    else {
        [_player play];
    }
    
    _isPlaying = !_isPlaying;
}

- (void)addBGM {
    
    [[KSBAVAssetManager sharedInstance] addAudioAssetWithFilePath:_fileURL.path
                                                    withStartTime:_leftValue
                                                     withPlayTime:_rightValue - _leftValue
                                                   withInsertTime:0
                                                       withVolume:0.5];
    
    [self showConvertViewController];
}

- (void)showConvertViewController {
    
    [SVProgressHUD showWithStatus:@"動画生成中"];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // time-consuming task
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            
            KSBMovieManager *manager = [KSBMovieManager sharedInstance];
            
            // 動画の長さを取得
            NSString *fileName1;// = @"1_1";
            NSString *fileName2;// = @"1_2";
            
            if (manager.a==0) {fileName1 = @"1_1"; fileName2 = @"1_2";}
            if (manager.a==1) {fileName1 = @"2_1"; fileName2 = @"2_2";}
            if (manager.a==2) {fileName1 = @"3_1"; fileName2 = @"3_2";}
            
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
//            Float64 moveTime = 1;
            
            //動画生成条件
            
            UIImageView *imgView1 = [[UIImageView alloc] initWithImage:manager.image];
            UIImageView *imgView2 = [[UIImageView alloc] initWithImage:manager.image.copy];
//            UIImageView *imgView3 = [[UIImageView alloc] initWithImage:manager.image.copy];
            CGRect d = imgView1.frame;
            d.origin.y -= 360;
            imgView2.frame = d;
            Float64 sec = 1;
            
            
            KSBAnimationAction *action1 = [[KSBAnimationAction alloc] initWithImageView:imgView1 duration:sec1 destValue:[NSValue valueWithCGPoint:imgView1.origin] scale:@(1)];
            KSBAnimationAction *action2 = [[KSBAnimationAction alloc] initWithImageView:imgView1 duration:sec destValue:[NSValue valueWithCGPoint:d.origin] scale:@(1)];
            KSBAnimationAction *action3 = [[KSBAnimationAction alloc] initWithImageView:imgView2 duration:sec2 destValue:[NSValue valueWithCGPoint:d.origin] scale:@(1)];
            
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
            NSString *fileName = @"tmpMovie";
            NSString *destPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *tmpMoviePath = [NSString stringWithFormat:@"%@/%@.mp4", destPath, fileName];
            
            KSBAVAssetManager *assetManager = [KSBAVAssetManager sharedInstance];
            [assetManager clear];
            
            [assetManager addVideoAssetWithFilePath:tmpMoviePath withVolume:1.0];
            [assetManager addAudioAssetWithFilePath:[[NSBundle mainBundle] pathForResource:fileName1 ofType:@"mp3"]
                                      withStartTime:0
                                       withPlayTime:sec1
                                     withInsertTime:0
                                         withVolume:1
             ];
            [assetManager addAudioAssetWithFilePath:[[NSBundle mainBundle] pathForResource:fileName2 ofType:@"mp3"]
                                      withStartTime:0
                                       withPlayTime:sec2
                                     withInsertTime:(sec1 - 2)
                                         withVolume:1
             ];
            
            //
            [assetManager merge:^(BOOL finished) {
                if (finished) {
                    [assetManager saveToLibrary:^(BOOL finished,NSError *error){
                        if (finished) {
                            [SVProgressHUD dismiss];
                            KSBResultViewController *rvc = [[KSBResultViewController alloc] init];
                            [self.navigationController pushViewController:rvc animated:YES];
                        }
                    }];
                }
            }];
        });
    });
}

#pragma mark RETrimControlDelegate

- (void)trimControl:(RETrimControl *)trimControl didChangeLeftValue:(CGFloat)leftValue rightValue:(CGFloat)rightValue
{
    NSLog(@"Left = %f, right = %f", leftValue, rightValue);
    
    _leftValue = leftValue;
    _rightValue = rightValue;
}

- (void)trimControlDidEndPanScroll:(RETrimControl *)trimControl {
    
    if (_isProcessing) {
        return;
    }
    
    [_player pause];
    [_playerItem seekToTime:CMTimeMake(_leftValue, 1.0) completionHandler:^(BOOL finished) {
        
        if (finished) {
            [_player play];
            
            _isPlaying = YES;
            
            if (_isWaitingSelector) {
                [NSObject cancelPreviousPerformRequestsWithTarget:self
                                                         selector:@selector(pausePlayer)
                                                           object:nil];
            }
            
            [self performSelector:@selector(pausePlayer) withObject:nil afterDelay:_rightValue - _leftValue];
            _isWaitingSelector = YES;
        }
    }];
}

- (void)pausePlayer {
    
    [_player pause];
    _isPlaying = NO;
    _isWaitingSelector = NO;
}

#pragma mark - Player Status Observe
-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context
{
    if([_player status] == AVPlayerItemStatusReadyToPlay){
        
        [_player removeObserver:self forKeyPath:@"status"];
        
        _trimControl.userInteractionEnabled = YES;
        _playButton.enabled = YES;
        _isProcessing = NO;
        
    }
    else if ([_player status] == AVPlayerItemStatusFailed){
        
        [_player removeObserver:self forKeyPath:@"status"];
        
        NSLog(@"Status Failed...");
        
        _trimControl.userInteractionEnabled = YES;
        _playButton.enabled = YES;
        _isProcessing = NO;
    }
    else if ([_player status] == AVPlayerItemStatusUnknown){
        
        [_player removeObserver:self forKeyPath:@"status"];
        
        NSLog(@"Status Unknown...");
        
        _trimControl.userInteractionEnabled = YES;
        _playButton.enabled = YES;
        _isProcessing = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    _player = nil;
    
    @try {
        [_player removeObserver:self
                     forKeyPath:@"status"];
    }
    @catch (id exception) {
       // nothing.
    }
    
}

@end
