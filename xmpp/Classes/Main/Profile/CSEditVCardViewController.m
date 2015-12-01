//
//  CSEditVCardViewController.m
//  xmpp
//
//  Created by 石冬冬 on 15/11/27.
//  Copyright © 2015年 石冬冬. All rights reserved.
//

#import "CSEditVCardViewController.h"
@interface CSEditVCardViewController ()
@property (weak, nonatomic) IBOutlet UITextField *editTextField;
@end
@implementation CSEditVCardViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置标题
    self.title = self.cell.textLabel.text;
    self.editTextField.text = self.cell.detailTextLabel.text;
}
- (IBAction)saveBtnClick:(id)sender {
    
    self.cell.detailTextLabel.text = self.editTextField.text;
    
    [self.cell layoutSubviews];
    
    [self.navigationController popViewControllerAnimated:YES];
    
    //通知代理
    if ([self.delegate respondsToSelector:@selector(editVCardViewController:didFinishedSave:)]) {
        [self.delegate editVCardViewController:self didFinishedSave:sender];
    }
}
@end
