//
//  CSXMPPTool.m
//  xmpp
//
//  Created by 石冬冬 on 15/11/27.
//  Copyright © 2015年 石冬冬. All rights reserved.
//

#import "CSXMPPTool.h"


@interface CSXMPPTool () <XMPPStreamDelegate>{
  
    
    XMPPResultBlock _resultBlock; // 结果回调
}
/*
 
 登录步骤
初始化xmppStream

连接服务器（传一个jID）

连接成功 发送密码

发送一个“在线消息”给服务器 默认登录成功是不在线的 -》可以通知其他用户你上线了
 */
/**
 *  初始化stream
 */
- (void) setupStream;
/**
 *  释放资源
 */
- (void) tearDownStream;
/**
 *  连接到服务器
 */
- (void) connectToHost;
/**
 *  发送密码
 */
- (void) sendPwdToHost;
/**
 *  发送在线消息给服务器
 */
- (void) sendOnLine;
/**
 *  发送离线消息给服务器
 */
- (void) sendOffLine;
/**
 *  与服务器断开连接
 */
- (void) disConnectFromHost;
@end
@implementation CSXMPPTool


singleton_implementation(CSXMPPTool)

#pragma mark -公共方法

#pragma mark -用户登录
- (void)xmppLogin:(XMPPResultBlock) resultBlock{
    
    //不管什么情况 把以前的连接断开
    [_xmppStream disconnect];
    
    //保存resultBlock
    _resultBlock = resultBlock;
    //连接到服务器
    [self connectToHost];
}
#pragma mark - 用户注册
- (void)xmppRegister:(XMPPResultBlock) resultBlock {
   
    //不管什么情况 把以前的连接断开
    [_xmppStream disconnect];
   
    _resultBlock = resultBlock;
    // 1 发送 “注册jid” 给服务器 请求一个长连接
    [self connectToHost];
    // 2 连接成功  发送密码
}
#pragma mark - 用户注销
- (void)xmppLogout {
    //注销
    //1 发送离线消息
    [self sendOffLine];
    //2 断开连接
    [self disConnectFromHost];
}
#pragma mark - xmppStream的代理
/**
 *  连接建立成功
 */
- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    CSLog(@"建立连接成功");
    
    
    if (self.isRegisterOperation) { //注册
        NSError *error = nil;
        NSString *registerPwd = [CSAccount shareAccount].registerPwd;
        [_xmppStream registerWithPassword:registerPwd error:&error];
        if (error) {
            CSLog(@"%@",error);
        }
    } else {
        //连接成功发送登录密码
        [self sendPwdToHost];
    }
    
}
/**
 *  与服务器断开连接
 */
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    CSLog(@"与服务器断开连接%@",error);
}
/**
 *  登录成功
 */
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
//    CSLog(@"%s",__func__);
    CSLog(@"登录成功");
    //登录成功 发送在线消息
    [self sendOnLine];
    
    //回调resultBlock
    
    if(_resultBlock) {
        _resultBlock(XMPPResultTypeSuccess);
    }
    
}
/**
 *  登录失败
 */
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error {
    CSLog(@"登录失败%@",error);
    
    if(_resultBlock) {
        _resultBlock(XMPPResultTypeFailure);
    }
}
/**
 *  注册成功
 */
- (void) xmppStreamDidRegister:(XMPPStream *)sender {
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeRegisterSucess);
    }
    CSLog(@"注册成功");
}
/**
 *  注册失败
 */
- (void) xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error {
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeRegisterFailure);
    }
    CSLog(@"注册失败%@",error);
}

#pragma mark - 私有方法
/**
 *  初始化stream
 */
- (void)setupStream {
    //初始化
    _xmppStream = [[XMPPStream alloc] init];
    
    //添加XMPP模块
    
    // 添加电子名片模块
    _vCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _vCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:_vCardStorage];
    //激活
    [_vCard activate:_xmppStream];
    
    //电子名片模块还会配合 “头像模块” 使用
    _vCardAvatar = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_vCard];
    [_vCardAvatar activate:_xmppStream];
    //设置代理 所有的代理方法在子线程调用
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    
    
    //花名册模块
    _rosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterStorage];
    [_roster activate:_xmppStream];
    
    
    //消息模块
    _msgAcrhingStorage = [[XMPPMessageArchivingCoreDataStorage alloc] init];
    _msgArching = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_msgAcrhingStorage];
    [_msgArching activate:_xmppStream];
    
    //断网自动连接模块
    _reconnect = [[XMPPReconnect alloc] init];
    [_reconnect activate:_xmppStream];
    
   
    
    //5、文件接收
    _incomingFileTransfer = [[XMPPIncomingFileTransfer alloc] initWithDispatchQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)];
    [_incomingFileTransfer activate:self.xmppStream];
    [_incomingFileTransfer addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [_incomingFileTransfer setAutoAcceptFileTransfers:YES];

}
- (void) tearDownStream {
    //移除代理
    [_xmppStream removeDelegate:self];
    
    //取消模块
    [_vCard deactivate];
    [_vCardAvatar deactivate];
    [_roster deactivate];
    [_msgArching deactivate];
    [_reconnect deactivate];
    
    //断开与服务器连接
    [_xmppStream disconnect];
    
    //清空资源
    _xmppStream = nil;
    _vCardAvatar = nil;
    _vCardStorage = nil;
    _vCard = nil;
    _roster = nil;
    _rosterStorage = nil;
    _msgArching = nil;
    _msgAcrhingStorage = nil;
    _reconnect = nil;
    
}
/**
 *  连接到服务器
 */
- (void) connectToHost {
    if (_xmppStream == nil) {
        [self setupStream];
    }
    
    //设置jID
    CSAccount *account = [CSAccount shareAccount];
    XMPPJID *myJID = nil;
    if (self.isRegisterOperation) { //注册请求
        NSString *registerUser = account.registerUser;
        myJID = [XMPPJID jidWithUser:registerUser domain:account.domain resource:nil];
        } else { // 登录请求
        //resource 用户登录客户端设备登录的类型
        //从沙盒获取保存的账号
        NSString *user = [CSAccount shareAccount].user;
        myJID = [XMPPJID jidWithUser:user domain:account.domain resource:nil];
        
    }
    _xmppStream.myJID = myJID;
    
    //设置主机地址
    _xmppStream.hostName = account.host;
    
    //设置主机端口号 （默认为5222 可以不用设置）
    _xmppStream.hostPort = account.port;
    
    //发起连接
    NSError *error= nil;
    [_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error];
    if (error) {
        CSLog(@"%@",error);
    } else {
        CSLog(@"发起连接成功");
    }
}
/**
 *  发送密码
 */
- (void) sendPwdToHost {
    NSError *error = nil;
    //从沙盒获取保存的账号
    NSString *pwd = [CSAccount shareAccount].pwd;
    [_xmppStream authenticateWithPassword:pwd error:&error];
    if (error) {
        CSLog(@"%@",error);
    } else {
        CSLog(@"发送成功");
    }
}
/**
 *  发送在线消息给服务器
 */
- (void)sendOnLine {
    
    //xmpp框架把所有的指令封装成对象
    XMPPPresence *presence = [XMPPPresence presence];
    [_xmppStream sendElement:presence];
}
/**
 *  发送离线消息
 */
- (void)sendOffLine {
    XMPPPresence *offLine = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offLine];
}
/**
 *  与服务器断开
 */
- (void)disConnectFromHost {
    [_xmppStream disconnect];
}
- (void)dealloc {
    [self tearDownStream];
}
@end
