//
//  CSXMPPTool.h
//  xmpp
//
//  Created by 石冬冬 on 15/11/27.
//  Copyright © 2015年 石冬冬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Singleton.h"
#import "XMPPFramework.h"
typedef enum {
    XMPPResultTypeSuccess,
    XMPPResultTypeFailure,
    XMPPResultTypeRegisterFailure,
    XMPPResultTypeRegisterSucess
}XMPPResultType;

/**
 *  与服务器交互的结果
 */
typedef void (^XMPPResultBlock)(XMPPResultType);

@interface CSXMPPTool : NSObject
singleton_interface(CSXMPPTool)
/**标识连接服务器 是登录还是注册 No代表登录操作  yes 代表注册操作*/
@property (nonatomic, assign,getter=isRegisterOperation) BOOL registerOperation;
 /**花名册*/
@property (nonatomic, strong) XMPPRoster *roster;
/**花名册数据存储*/
@property (nonatomic, strong) XMPPRosterCoreDataStorage *rosterStorage;
/**电子名片模块*/
@property (nonatomic, strong) XMPPvCardTempModule *vCard;
/**电子名片数据存储*/
@property (nonatomic, strong) XMPPvCardCoreDataStorage *vCardStorage;
/**电子名片头像模块*/
@property (nonatomic, strong)  XMPPvCardAvatarModule *vCardAvatar;
/**与服务器交互的核心类*/
@property (nonatomic, strong)   XMPPStream *xmppStream;
/**消息模块*/
@property (nonatomic, strong) XMPPMessageArchiving *msgArching;
/**消息数据存储*/
@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *msgAcrhingStorage;
/**断网自动连接*/
@property (nonatomic, strong) XMPPReconnect *reconnect;

@property (nonatomic, strong) XMPPRosterMemoryStorage *rosterMemoryStorage;
@property (nonatomic, strong) XMPPIncomingFileTransfer *incomingFileTransfer;
/**
 *  xmpp用户登录
 */
- (void) xmppLogin:(XMPPResultBlock) resultBlock;
/**
 *  xmpp用户注销
 */
- (void) xmppLogout;

- (void) xmppRegister:(XMPPResultBlock) resultBlock;
@end
