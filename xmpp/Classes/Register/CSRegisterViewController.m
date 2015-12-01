//
//  CSRegisterViewController.m
//  xmpp
//
//  Created by 石冬冬 on 15/11/27.
//  Copyright © 2015年 石冬冬. All rights reserved.
//

#import "CSRegisterViewController.h"
#import "ProgressHUD.h"
@interface CSRegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;

@end

@implementation CSRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}
- (IBAction)cancellBtnClick:(UIBarButtonItem *)sender {
    //返回登录界面
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}
- (IBAction)registerBtnClick {
    //保存注册的用户名和密码
    [CSAccount shareAccount].registerUser = self.userField.text;
    [CSAccount shareAccount].registerPwd = self.pwdField.text;
    [ProgressHUD show:@"注册中..."];
 
    
    //注册
    __weak typeof(self) selfVc = self;
    [CSXMPPTool sharedCSXMPPTool].registerOperation = YES;
    [[CSXMPPTool sharedCSXMPPTool] xmppRegister:^(XMPPResultType typeResult) {
        [selfVc handelXMPPResult:typeResult];
    }];
    
    
}
- (void) handelXMPPResult:(XMPPResultType) typeResult {
    //主线程工作
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [ProgressHUD dismiss];
        
        if (typeResult == XMPPResultTypeRegisterSucess) {
            [ProgressHUD show:@"注册成功"];
        } else {
           
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ProgressHUD showError:@"用户名重复"];

            });
            
        }
        
    });
}

@end
