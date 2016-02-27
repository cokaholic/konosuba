//
//  GIBgmSettingViewController.m
//  konosuba
//
//  Created by 石橋 弦樹 on 2016/02/27.
//  Copyright © 2016年 Keisuke Tatsumi. All rights reserved.
//

#import "KSBBgmSettingViewController.h"
#import "TSLibraryImport.h"
#import "KSBBgmTrimViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

static NSString * const kCellIdentifier = @"Cell";

@interface KSBBgmSettingViewController () <UITableViewDataSource, UITableViewDelegate, MPMediaPickerControllerDelegate>

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *addButton;
@property (nonatomic, strong) NSString *pathDocuments;
@property (nonatomic, strong) NSArray *bgmDirectory;
@property (nonatomic, strong) NSMutableArray *bgmFilePaths;
@property (nonatomic, strong) NSString *fileName;

@end

@implementation KSBBgmSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.headerStepperView setStepWithNumber:3];
    
    [self configFiles];
    [self configTitleLabel];
    [self configAddButton];
    [self configTableView];
}

-(void)viewWillAppear:(BOOL)animated{
    
    //Documentsの中身
    _bgmDirectory = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:_pathDocuments error:nil];
    //ミュージックテーブルビューの内容
    _bgmFilePaths = [NSMutableArray array];
    _bgmFilePaths = [NSMutableArray arrayWithArray:_bgmDirectory];
    
    //テーブルビューのリロード
    [_tableView reloadData];
}

- (void)configFiles {
    
    BOOL isDirectory;
    _pathDocuments = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/bgm"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:_pathDocuments isDirectory:&isDirectory] || !isDirectory) {
        NSError *error = nil;
        NSDictionary *attr = [NSDictionary dictionaryWithObject:NSFileProtectionComplete
                                                         forKey:NSFileProtectionKey];
        [[NSFileManager defaultManager] createDirectoryAtPath:_pathDocuments
                                  withIntermediateDirectories:YES
                                                   attributes:attr
                                                        error:&error];
        if (error)
            NSLog(@"Error creating directory path: %@", [error localizedDescription]);
    }
    
    //Documentsの中身
    _bgmDirectory = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:_pathDocuments error:nil];
    _bgmFilePaths = [NSMutableArray array];
    if (NOT_NULL(_bgmDirectory)) {
        _bgmFilePaths = [NSMutableArray arrayWithArray:_bgmDirectory];
    }
}

- (void)configTitleLabel {
    
    _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, kStepperBottomHeight, CGRectGetWidth(APPFRAME_RECT), 40)];
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = DEFAULT_FONT_BOLD(20);
    _titleLabel.text = @"BGMの設定";
    [self.view addSubview:_titleLabel];
}

- (void)configAddButton {
    
    _addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    _addButton.frame = CGRectMake(0, _titleLabel.bottom, _titleLabel.width, 40);
    _addButton.backgroundColor = [UIColor greenColor];
    [_addButton setTitle:@"ライブラリから追加する" forState:UIControlStateNormal];
    _addButton.tintColor = [UIColor colorWithCSS:kColorCodeWhite];
    _addButton.titleLabel.font = DEFAULT_FONT_BOLD(15);
    [_addButton addTarget:self
                   action:@selector(openMusicLibrary)
         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_addButton];
}

- (void)configTableView {
    
    _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, _addButton.bottom, _titleLabel.width, CGRectGetHeight(APPFRAME_RECT) - _addButton.bottom + CGRectGetHeight(STATUSBAR_RECT))];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _bgmFilePaths.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:kCellIdentifier];
    }
    
    cell.textLabel.text = [_bgmFilePaths objectAtIndex:indexPath.row];
    cell.textLabel.font = DEFAULT_FONT(13);
    cell.textLabel.numberOfLines = 1;
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //ファイルへのパス
    NSString *filePath = [_pathDocuments stringByAppendingPathComponent:[_bgmFilePaths objectAtIndex:indexPath.row]];
    NSURL *outURL = [NSURL fileURLWithPath:filePath];
    
    KSBBgmTrimViewController *trimViewController = [[KSBBgmTrimViewController alloc]init];
    trimViewController.fileURL = outURL;
    
    [self.navigationController pushViewController:trimViewController animated:YES];
}

- (void)openMusicLibrary {
    
    MPMediaPickerController *mv = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    mv.delegate= self;
    mv.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:mv animated:YES completion:nil];
}

#pragma mark - MPMediaPickerControllerDelegate

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection{
    
    //TODO: インジケーターを回す
//    [indicator startAnimating];
    
    for (MPMediaItem* item in mediaItemCollection.items) {
        NSString* title = [item valueForProperty:MPMediaItemPropertyTitle];
        NSString* artist = [item valueForProperty:MPMediaItemPropertyArtist];
        NSURL* assetURL = [item valueForProperty:MPMediaItemPropertyAssetURL];
        if (nil == assetURL) {
            /**
             * !!!: When MPMediaItemPropertyAssetURL is nil, it typically means the file
             * in question is protected by DRM. (old m4p files)
             */
            return;
        }
        
        //音楽ファイル名の取得
        _fileName = [artist stringByAppendingFormat:@"-%@",title];
        
        //音楽データのインポート
        [self exportAssetAtURL:assetURL withTitle:[artist stringByAppendingFormat:@"-%@",title] viewController:mediaPicker MediaItem:item];
        
        [mediaPicker dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - TSLibrary methods

- (NSString*)musicPath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

- (void)exportAssetAtURL:(NSURL*)assetURL withTitle:(NSString*)title viewController:(UIViewController*)viewCtr MediaItem:(MPMediaItem*)item{
    
    // create destination URL
    NSString* ext = [TSLibraryImport extensionForAssetURL:assetURL];
    NSURL *outURL = [[NSURL fileURLWithPath:[[self musicPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"bgm/%@", title]]] URLByAppendingPathExtension:ext];
    // we're responsible for making sure the destination url doesn't already exist
    [[NSFileManager defaultManager] removeItemAtURL:outURL error:nil];
    
    // create the import object
    TSLibraryImport* import = [[TSLibraryImport alloc] init];
    [import importAsset:assetURL toURL:outURL completionBlock:^(TSLibraryImport* import) {
        /*
         * If the export was successful (check the status and error properties of
         * the TSLibraryImport instance) you know have a local copy of the file
         * at `outURL` You can get PCM samples for processing by opening it with
         * ExtAudioFile. Yay!
         *
         * Here we're just playing it with AVPlayer
         */
        if (import.status != AVAssetExportSessionStatusCompleted) {
            // something went wrong with the import
            NSLog(@"Error importing: %@", import.error);
            
            //TODO: インジケーターを止める
//            [indicator stopAnimating];
            
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error..."
                                                           message:@"BGMの追加に失敗しました..."
                                                          delegate:self
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:@"OK", nil];
            [alert show];
            
            return;
        }
        
        // import completed
        NSLog(@"outURL :%@",outURL);
        
        _bgmDirectory = [[NSFileManager defaultManager]contentsOfDirectoryAtPath:_pathDocuments error:nil];
        //ミュージックテーブルビューの内容
        _bgmFilePaths = [NSMutableArray array];
        _bgmFilePaths = [NSMutableArray arrayWithArray:_bgmDirectory];
        
        //テーブルビューのリロード
        [_tableView reloadData];
        
        //TODO: インジケーターを止める
//        [indicator stopAnimating];
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"インポート成功！"
                                                       message:@"ファイルのインポートが完了しました！"
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:@"OK", nil];
        [alert show];
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    NSLog(@"メモリやばいよ！！");
}

@end
