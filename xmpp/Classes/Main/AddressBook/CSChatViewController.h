//
//  CSChatViewController.h
//  xmpp
//
//  Created by 石冬冬 on 15/11/29.
//  Copyright © 2015年 石冬冬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSChatViewController : UIViewController
/**好友的jid*/
@property (nonatomic, strong) XMPPJID *friendJid;
@property (nonatomic, copy) NSString *nickName;

@end
