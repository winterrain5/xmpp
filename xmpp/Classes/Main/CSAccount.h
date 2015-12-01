//
//  CSAccount.h
//  xmpp
//
//  Created by 石冬冬 on 15/11/27.
//  Copyright © 2015年 石冬冬. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSAccount : NSObject
/**用户登录的用户名 和 密码*/
@property (nonatomic, copy) NSString *user;
@property (nonatomic, copy) NSString *pwd;

/**用户注册的用户名 和 密码*/
@property (nonatomic, copy) NSString *registerUser;
@property (nonatomic, copy) NSString *registerPwd;
/**判断用户是否登录*/
@property (nonatomic, assign,getter=isLogin) BOOL login;
/**服务器的域名*/
@property (nonatomic, copy,readonly) NSString *domain;
/**服务器的IP*/
@property (nonatomic, copy,readonly) NSString *host;
/**服务器的端口*/
@property (nonatomic, assign,readonly) int port;


+ (instancetype) shareAccount;
/**
 *  保存最新的登录信息到沙盒
 */
- (void)saveToSandBox;
@end
