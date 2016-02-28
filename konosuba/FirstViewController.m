//
//  FirstViewController.m
//  COMIX
//
//  Created by Keisuke_Tatsumi on 2014/07/29.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import "FirstViewController.h"
#import "SecondViewController.h"
#import "KSBConvertViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.headerStepperView setStepWithNumber:1];
    
    backgroundImgView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    backgroundImgView.image = [UIImage imageNamed:@"top.png"];
    backgroundImgView.contentMode = UIViewContentModeScaleAspectFill;
    backgroundImgView.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
    [self.view addSubview:backgroundImgView];
    
    cameraBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cameraBtn.frame = self.view.bounds;
    cameraBtn.backgroundColor = [UIColor clearColor];
    [cameraBtn addTarget:self
                  action:@selector(goCameraView)
        forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cameraBtn];
}

-(void)viewWillAppear:(BOOL)animated{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

-(void)goCameraView{
    SecondViewController *svc = [[SecondViewController alloc]init];
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:svc];
    nvc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
