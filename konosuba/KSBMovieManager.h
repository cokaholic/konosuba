//
//  MovieMaker.h
//  sample
//
//  Created by 石橋 弦樹 on 2016/02/27.
//  Copyright © 2016年 石橋 弦樹. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "KSBAnimationAction.h"

@interface KSBMovieManager : NSObject

+ (instancetype)sharedInstance;

- (CGSize)getWindowSize;

/**
 *  背景画像
 */
@property(nonatomic, retain) UIImage *bgImage;

/**
 *  動かす画像
 *  複数画像を動かす想定でArrayで保持するほうがいいかも。
 */
@property(nonatomic, retain) UIImage *image;        // 動かす画像

/**
 *  出力先ディレクトリのパス
 *  デフォルトではDocumentsのパスに保存される
 */
@property(nonatomic, retain) NSString *destPath;

/**
 *  出力ファイル名
 */
@property(nonatomic, retain) NSString *outputFileName;

/**
 *  画像を動かす条件を追加する
 *
 *  @param action 動作させるためのアクションを指定
 */
- (void)addAnimationAction:(KSBAnimationAction *)action;

/**
 *  動画を生成処理
 */
- (void)startMakingMovieWithFPS:(double) fps;

@end
