//
//  KSBBgmTrimViewController.m
//  konosuba
//
//  Created by Keisuke_Tatsumi on 2016/02/28.
//  Copyright © 2016年 Keisuke Tatsumi. All rights reserved.
//

#import "KSBBgmTrimViewController.h"
#import "RETrimControl.h"
#import <AVFoundation/AVFoundation.h>

@interface KSBBgmTrimViewController () <RETrimControlDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UIButton *doneButton;
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
    [self configDoneButton];
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

- (void)configDoneButton {
    
    _doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _doneButton.frame = CGRectMake(kDefaultMargin, CGRectGetHeight(APPFRAME_RECT) - 40 + kDefaultMargin, _titleLabel.width - kDefaultMargin*2, 40);
    _doneButton.backgroundColor = [UIColor greenColor];
    [_doneButton setTitle:@"アニメを生成" forState:UIControlStateNormal];
    _doneButton.tintColor = [UIColor colorWithCSS:kColorCodeWhite];
    _doneButton.titleLabel.font = DEFAULT_FONT_BOLD(15);
    [_doneButton addTarget:self
                    action:@selector(showConvertViewController)
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

- (void)showConvertViewController {
    
    
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

@end
