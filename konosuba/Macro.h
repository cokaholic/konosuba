//
//  Macro.h
//  awaji
//
//  Created by Keisuke_Tatsumi on 2016/01/24.
//  Copyright © 2016年 Keisuke Tatsumi. All rights reserved.
//

// App Frame
#define APPFRAME_RECT [UIScreen mainScreen].applicationFrame
#define STATUSBAR_RECT [UIApplication sharedApplication].statusBarFrame

// Screen Rect Percent
#define SCREEN_RECT_PERCENT [UIScreen mainScreen].applicationFrame.size.width/320.0f

// iOS Version
#define IOS_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

// Font
#define DEFAULT_FONT(textSize) [UIFont fontWithName:@"HiraKakuProN-W3" size:textSize]
#define DEFAULT_FONT_BOLD(textSize) [UIFont fontWithName:@"HiraKakuProN-W6" size:textSize]

// Null Checker
#define NOT_NULL(_instance) (_instance && ![_instance isKindOfClass:[NSNull class]])
#define CHECK_NULL_STRING(_instance) NOT_NULL(_instance) ? _instance : @""
#define CHECK_NULL_NUMBER(_instance) NOT_NULL(_instance) ? _instance : @0