//
//  CSMainMessageController.h
//  xmpp
//
//  Created by 石冬冬 on 15/11/27.
//  Copyright © 2015年 石冬冬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSMainMessageController : UITableViewController
@property (weak, nonatomic) IBOutlet UILabel *accountLbl;
@property (weak, nonatomic) IBOutlet UILabel *position;
@property (weak, nonatomic) IBOutlet UILabel *telLbl;
@property (weak, nonatomic) IBOutlet UILabel *emaiLbl;
@property (weak, nonatomic) IBOutlet UIButton *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *orgUnitLbl;
@property (weak, nonatomic) IBOutlet UILabel *departmentLbl;


@end
