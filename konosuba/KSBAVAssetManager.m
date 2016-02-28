//
//  KSBAVAssetManager.m
//  AudioVideoMerge
//
//  Created by Keisuke_Tatsumi on 2016/02/27.
//  Copyright © 2016年 TheAppGuruz. All rights reserved.
//

#import "KSBAVAssetManager.h"

const float kPerUnitSec = 600;
const float kMaxVolumeParameter = 2.0;

@interface KSBAVAssetManager ()

@property (nonatomic, strong) AVMutableComposition *mixComposition;
@property (nonatomic, strong) NSMutableArray *audioMixInputParameters;
@property (nonatomic, strong) AVMutableAudioMix *audioMix;
@property (nonatomic, strong) NSURL *outputURL;
@property (nonatomic, assign) CMTime videoDuration;
@property (nonatomic, assign) int idCounter;
@property (nonatomic, assign) BOOL isProcessing;

@end

@implementation KSBAVAssetManager

+ (instancetype)sharedInstance {
    
    static KSBAVAssetManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[KSBAVAssetManager alloc] init];
        [manager initConfig];
    });
    
    return manager;
}

- (void)initConfig {
    
    _mixComposition = [AVMutableComposition composition];
    _audioMixInputParameters = [[NSMutableArray alloc]init];
    _audioMix = [AVMutableAudioMix audioMix];
    _outputURL = [[NSURL alloc]init];
    _videoDuration = kCMTimeZero;
    _idCounter = 0;
    _isProcessing = NO;
}

- (void)addVideoAssetWithFilePath:(NSString *)path
                       withVolume:(float)volume {
    
    [self addVideoAssetWithFilePath:path
                      withStartTime:0
                       withPlayTime:0
                     withInsertTime:0
                         withVolume:volume];
}

- (void)addVideoAssetWithFilePath:(NSString *)path
                    withStartTime:(float)startTime
                     withPlayTime:(float)playTime
                   withInsertTime:(float)insertTime
                       withVolume:(float)volume {
    
    NSURL *video_url = [NSURL fileURLWithPath:path];
    AVURLAsset *videoAsset = [[AVURLAsset alloc]initWithURL:video_url options:nil];
    
    // set video duration
    _videoDuration = videoAsset.duration;
    
    CMTimeRange video_timeRange;
    if (startTime==0 && playTime == 0) {
        video_timeRange = CMTimeRangeMake(kCMTimeZero,videoAsset.duration);
    }
    else {
        video_timeRange = CMTimeRangeMake(CMTimeMake(startTime*kPerUnitSec, kPerUnitSec),CMTimeMake(playTime*kPerUnitSec, kPerUnitSec));
    }
    
    AVMutableCompositionTrack *compositionVideoTrack = [_mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:_idCounter];
    _idCounter++;
    [compositionVideoTrack insertTimeRange:video_timeRange ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] atTime:CMTimeMake(insertTime*kPerUnitSec, kPerUnitSec) error:nil];
    
    AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionVideoTrack];
    
    if (volume<=0) {
        [audioInputParams setVolume:0.0 atTime:kCMTimeZero];
    }
    else if(volume>=kMaxVolumeParameter) {
        [audioInputParams setVolume:kMaxVolumeParameter atTime:kCMTimeZero];
    }
    else {
        [audioInputParams setVolume:volume atTime:kCMTimeZero];
    }
    
    [_audioMixInputParameters addObject:audioInputParams];
}

- (void)addAudioAssetWithFilePath:(NSString *)path
                    withStartTime:(float)startTime
                     withPlayTime:(float)playTime
                   withInsertTime:(float)insertTime
                       withVolume:(float)volume {
    
    NSURL *audio_url = [NSURL fileURLWithPath:path];
    AVURLAsset *audioAsset = [[AVURLAsset alloc]initWithURL:audio_url options:nil];
    
    CMTimeRange audio_timeRange;
    if (startTime==0 && playTime == 0) {
        audio_timeRange = CMTimeRangeMake(kCMTimeZero,audioAsset.duration);
    }
    else {
        audio_timeRange = CMTimeRangeMake(CMTimeMake(startTime*kPerUnitSec, kPerUnitSec),CMTimeMake(playTime*kPerUnitSec, kPerUnitSec));
    }
    
    AVMutableCompositionTrack *compositionAudioTrack = [_mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:_idCounter];
    _idCounter++;
    [compositionAudioTrack insertTimeRange:audio_timeRange ofTrack:[[audioAsset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0] atTime:CMTimeMake(insertTime*kPerUnitSec, kPerUnitSec) error:nil];
    
    AVMutableAudioMixInputParameters *audioInputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:compositionAudioTrack];
    
    if (volume<=0) {
        [audioInputParams setVolume:0.0 atTime:kCMTimeZero];
    }
    else if(volume>=kMaxVolumeParameter) {
        [audioInputParams setVolume:kMaxVolumeParameter atTime:kCMTimeZero];
    }
    else {
        [audioInputParams setVolume:volume atTime:kCMTimeZero];
    }
    
    [_audioMixInputParameters addObject:audioInputParams];
}

- (void)clear {
    
    [self initConfig];
}

- (void)merge:(mergeCompletion)handler {
    
    if (_isProcessing) {
        return;
    }
    
    _isProcessing = YES;
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    NSString *outputFilePath = [docsDir stringByAppendingPathComponent:kDefaultFileName];
    NSURL *outputFileUrl = [NSURL fileURLWithPath:outputFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:outputFilePath])
        [[NSFileManager defaultManager] removeItemAtPath:outputFilePath error:nil];
    
    AVAssetExportSession* _assetExport = [[AVAssetExportSession alloc] initWithAsset:_mixComposition presetName:AVAssetExportPresetMediumQuality];
    _assetExport.outputFileType = @"com.apple.quicktime-movie";
    _assetExport.outputURL = outputFileUrl;
    
    _audioMix.inputParameters = _audioMixInputParameters;
    _assetExport.audioMix = _audioMix;
    
    [_assetExport exportAsynchronouslyWithCompletionHandler:
     ^(void ) {
         dispatch_async(dispatch_get_main_queue(), ^{
             [self exportDidFinish:_assetExport withCompletion:handler];
         });
     }];
}

- (void)exportDidFinish:(AVAssetExportSession*)session withCompletion:(mergeCompletion)handler
{
    if(session.status == AVAssetExportSessionStatusCompleted){
        _outputURL = session.outputURL;
        _isProcessing = NO;
        handler(YES);
    }
}

- (void)saveToLibrary:(saveCompletion)handler {
    
    if (_isProcessing) {
        return;
    }
    
    _isProcessing = YES;
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:_outputURL]) {
        [library writeVideoAtPathToSavedPhotosAlbum:_outputURL
                                    completionBlock:^(NSURL *assetURL, NSError *error){
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            _isProcessing = NO;
                                            handler(YES, error);
                                        });
                                    }];
    }
}

- (NSURL *)getOutputURL {
    
    return _outputURL;
}

@end
