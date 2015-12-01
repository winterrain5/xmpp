//
//  AppDelegate.m
//  xmpp
//
//  Created by 石冬冬 on 15/11/27.
//  Copyright © 2015年 石冬冬. All rights reserved.
//

#import "AppDelegate.h"
#import "DDTTYLogger.h"
#import "DDLog.h"
@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
   
    //配置XMPP日志
//    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    //判断用户是否登录
    if ([CSAccount shareAccount].isLogin) {
        //转到主界面
        id mainVc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController
                     ];
        self.window.rootViewController = mainVc;
        
        //自动登录
        [[CSXMPPTool sharedCSXMPPTool] xmppLogin:nil];
    }
    
    // 注册通知
    if ([UIDevice currentDevice].systemVersion.doubleValue >= 8.0) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert|UIUserNotificationTypeBadge|UIUserNotificationTypeSound categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
    return YES;
}
@end
