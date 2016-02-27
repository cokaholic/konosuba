//
//  KSBAVAssetManager.h
//  AudioVideoMerge
//
//  Created by Keisuke_Tatsumi on 2016/02/27.
//  Copyright © 2016年 TheAppGuruz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <MediaPlayer/MediaPlayer.h>

typedef void(^mergeCompletion)(BOOL finished);
typedef void(^saveCompletion)(BOOL finished, NSError *error);

static NSString *kDefaultFileName = @"final_video_file.mp4";

@interface KSBAVAssetManager : NSObject

+ (instancetype)sharedInstance;

- (void)addVideoAssetWithFilePath:(NSString *)path
                       withVolume:(float)volume;

- (void)addVideoAssetWithFilePath:(NSString *)path
                    withStartTime:(float)startTime
                     withPlayTime:(float)playTime
                   withInsertTime:(float)insertTime
                       withVolume:(float)volume;

- (void)addAudioAssetWithFilePath:(NSString *)path
                    withStartTime:(float)startTime
                     withPlayTime:(float)playTime
                   withInsertTime:(float)insertTime
                       withVolume:(float)volume;
- (void)clear;
- (void)merge:(mergeCompletion)handler;
- (void)saveToLibrary:(saveCompletion)handler;
- (NSURL *)getOutputURL;

@end
