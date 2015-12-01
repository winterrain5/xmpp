//
//  CSAccount.m
//  xmpp
//
//  Created by 石冬冬 on 15/11/27.
//  Copyright © 2015年 石冬冬. All rights reserved.
//

#import "CSAccount.h"
#define  kuserKey @"user"
#define  kpwdKey @"pwd"
#define  kloginKey @"login"

static NSString *domain = @"shidongdong.local";
static NSString *host = @"127.0.0.1";
static int  port = 5222;
@implementation CSAccount
+ (instancetype) shareAccount {
    return  [[self alloc] init];
}
#pragma mark 分配内存创建对象 单例对象
+ (instancetype) allocWithZone:(struct _NSZone *)zone {
    static CSAccount *account;
    
    //为了线程安全
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
       
            account = [super allocWithZone:zone];
            
            //从沙盒获取上次的用户登录信息
             NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            account.user = [defaults objectForKey:kuserKey];
            account.pwd = [defaults objectForKey:kpwdKey];
            account.login = [defaults boolForKey:kloginKey];
            
        
    });
    return  account;
}
- (void)saveToSandBox {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.user forKey:kuserKey];
    [defaults setObject:self.pwd forKey:kpwdKey];
    [defaults setBool:self.login forKey:kloginKey];
    [defaults synchronize];
}
- (NSString *)domain {
    return domain;
}
- (NSString *)host {
    return host;
}
- (int)port {
    return port;
}
@end
