//
//  CSLoginViewController.m
//  xmpp
//
//  Created by 石冬冬 on 15/11/27.
//  Copyright © 2015年 石冬冬. All rights reserved.
//

#import "CSLoginViewController.h"
#import "AppDelegate.h"
#import "ProgressHUD.h"
@interface CSLoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;


@end

@implementation CSLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)registerBtnClick {
}

- (IBAction)loginBtnClick {
    //1、判断用户名 密码
    if(self.userField.text.length == 0 || self.pwdField.text.length == 0) {
        
        return;
    }
    
    [ProgressHUD show:@"正在登录...."];
    
    //2、登录到服务器
        //2.1 把用户名和密码保存到沙盒
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:self.userField.text forKey:@"user"];
//    [defaults setObject:self.pwdField.text forKey:@"pwd"];
    //同步 保存到磁盘
//    [defaults synchronize];
    
    //2.1 把用户名和密码保存到account单例
    CSAccount *account = [CSAccount shareAccount];
    account.user = self.userField.text;
    account.pwd = self.pwdField.text;
    account.login = YES;
    
    //通过block 把appdelegate的登录结果告诉CSLogingViewCoontroller
    
        //2.2 调用appdelegate的xmppLogin
    //blcok会对self进行强引用 导致循环引用
    __weak typeof(self) selfVc = self;
   
    
    //设置标识
    [CSXMPPTool sharedCSXMPPTool].registerOperation = NO;
    [[CSXMPPTool sharedCSXMPPTool] xmppLogin:^(XMPPResultType resultType) {
        
        [selfVc handlXMPPResultType:resultType];
        
    }];
    
    
}
/**
 *  处理结果
 */
- (void) handlXMPPResultType:(XMPPResultType) resultType {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (resultType == XMPPResultTypeSuccess) {
            [ProgressHUD dismiss];
            //登录成功切换到主界面
            [self changeToMain];
            
            //保存登录账户信息到沙盒
            CSAccount *account = [CSAccount shareAccount];
            account.login = YES;
            [account saveToSandBox];
        } else {
            
            [ProgressHUD show:@"用户名或者密码错误！！！"];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ProgressHUD dismiss];
            });
            NSLog(@"登录失败");
        }
    });
}

#pragma mark 跳转到主界面
- (void) changeToMain {
    
        // 获取Main.storyboard的第一个控制器
        id vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateInitialViewController];
        
        //切换window的根控制器
        [UIApplication sharedApplication].keyWindow.rootViewController = vc;
   
    
    
}



@end
