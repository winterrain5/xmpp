//
//  CSEditVCardController.m
//  xmpp
//
//  Created by 石冬冬 on 15/11/30.
//  Copyright © 2015年 石冬冬. All rights reserved.
//

#import "CSEditVCardController.h"
#import "CSMainMessageController.h"
@interface CSEditVCardController ()
@property (weak, nonatomic) IBOutlet UITextField *nickNameTf;
@property (weak, nonatomic) IBOutlet UITextField *orgUnitTf;
@property (weak, nonatomic) IBOutlet UITextField *departmentTf;
@property (weak, nonatomic) IBOutlet UITextField *positionTf;
@property (weak, nonatomic) IBOutlet UITextField *emailTf;

@property (weak, nonatomic) IBOutlet UITextField *telTf;
@end

@implementation CSEditVCardController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nickNameTf.text = self.msgController.nickNameLbl.text;
    self.orgUnitTf.text = self.msgController.orgUnitLbl.text;
    self.departmentTf.text = self.msgController.departmentLbl.text;
    self.positionTf.text = self.msgController.position.text;
    self.emailTf.text = self.msgController.emaiLbl.text;
    self.telTf.text = self.msgController.telLbl.text;
}

- (IBAction)saveBtnClick:(id)sender {
    
    self.msgController.nickNameLbl.text = self.nickNameTf.text;
    self.msgController.orgUnitLbl.text = self.orgUnitTf.text ;
    self.msgController.departmentLbl.text = self.departmentTf.text ;
    self.msgController.position.text = self.positionTf.text ;
    self.msgController.emaiLbl.text = self.emailTf.text ;
    self.msgController.telLbl.text = self.telTf.text ;
    
    [self.msgController.tableView layoutSubviews];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    //通知代理
    if ([self.delegate respondsToSelector:@selector(editVCardController:didFinishedSave:)]) {
        [self.delegate editVCardController:self didFinishedSave:sender];
    }
}



@end
