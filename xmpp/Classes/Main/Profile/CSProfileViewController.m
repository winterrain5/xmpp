
//
//  CSProfileViewController.m
//  xmpp
//
//  Created by 石冬冬 on 15/11/27.
//  Copyright © 2015年 石冬冬. All rights reserved.
//

#import "CSProfileViewController.h"
#import "AppDelegate.h"
#import "XMPPvCardTemp.h"
@interface CSProfileViewController () <NSFetchedResultsControllerDelegate>{
    NSFetchedResultsController *_resultController;
}
@property (weak, nonatomic) IBOutlet UIImageView *avtarImage;

@property (weak, nonatomic) IBOutlet UILabel *userLbl;
@end

@implementation CSProfileViewController
- (IBAction)logoutBtnClick:(id)sender {
    
    [[CSXMPPTool sharedCSXMPPTool] xmppLogout];
    
    //注销的时候  把沙盒里的状态设置为NO
    [CSAccount shareAccount].login = NO;
    [[CSAccount shareAccount] saveToSandBox];
    
    //回到登录界面
    [UIStoryboard showInitialVCWithName:@"Login"];

}
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.scrollEnabled = NO;
    
    //登录用户的电子名片信息
    XMPPvCardTemp *myvCard = [CSXMPPTool sharedCSXMPPTool].vCard.myvCardTemp;
    
    //显示头像 和 账号 使用电子名片模块
    self.avtarImage.layer.cornerRadius = 35;
    self.avtarImage.clipsToBounds = YES;
    if (myvCard.photo) {
        self.avtarImage.image = [UIImage imageWithData:myvCard.photo];
    } else {
        self.avtarImage.image = [UIImage imageNamed:@"avatar_default"];
    }
    
    self.userLbl.text = [@"账号:" stringByAppendingString:[CSAccount shareAccount].user];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source



@end
