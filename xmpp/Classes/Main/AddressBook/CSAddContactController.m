//
//  CSAddContactController.m
//  xmpp
//
//  Created by 石冬冬 on 15/11/29.
//  Copyright © 2015年 石冬冬. All rights reserved.
//

#import "CSAddContactController.h"
#import "ProgressHUD.h"
@interface CSAddContactController ()
@property (weak, nonatomic) IBOutlet UITextField *addFriendsTextField;

@end

@implementation CSAddContactController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    
}
- (IBAction)addFriendsBtnClick {
    NSString *user = self.addFriendsTextField.text;
    //用户名称是一个完整的JID
    XMPPJID *userJID = [XMPPJID jidWithUser:user domain:[CSAccount shareAccount].domain resource:nil];
    
    //不能添加自己为好友
    if ([user isEqualToString:[CSAccount shareAccount].user]) {
        [self showMsg:@"不能添加自己为好友"];
        return;
    }
    
    //已经存在好友无需添加
    BOOL userExists =  [[CSXMPPTool sharedCSXMPPTool].rosterStorage userExistsWithJID:userJID xmppStream:[CSXMPPTool sharedCSXMPPTool].xmppStream];
    if (userExists) {
        [self showMsg:@"好友已存在"];
        return;
    }
    
    //添加好友（订阅）
    [[CSXMPPTool sharedCSXMPPTool].roster subscribePresenceToUser:userJID];
    // 存在问题 添加不存在的好友时通讯录也会显示
    // 解决办法：过滤数据库的subscription字段查询请求
    //none: 对方没有同意添加好友 to:发给对方的请求 form：别人发来的请求 both：互为好友
    [ProgressHUD show:@"添加成功\n等待对方接受"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [ProgressHUD dismiss];
    });
    [self.navigationController popViewControllerAnimated:YES];

}


- (void) showMsg:(NSString *) msg {
    UIAlertView *alertView  = [[UIAlertView alloc] initWithTitle:@"提示" message:msg delegate:nil cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alertView show];
}



@end
