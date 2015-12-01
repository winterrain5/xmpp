//
//  CSMainMessageController.m
//  xmpp
//
//  Created by 石冬冬 on 15/11/27.
//  Copyright © 2015年 石冬冬. All rights reserved.
//

#import "CSMainMessageController.h"
#import "XMPPvCardTemp.h"
#import "CSEditVCardViewController.h"
@interface CSMainMessageController () <UITableViewDelegate,CSEditVCardViewControllerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UILabel *accountLbl;
@property (weak, nonatomic) IBOutlet UILabel *position;
@property (weak, nonatomic) IBOutlet UILabel *telLbl;
@property (weak, nonatomic) IBOutlet UILabel *emaiLbl;
@property (weak, nonatomic) IBOutlet UIButton *avatarImage;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLbl;
@property (weak, nonatomic) IBOutlet UILabel *orgUnitLbl;
@property (weak, nonatomic) IBOutlet UILabel *departmentLbl;

@end
@implementation CSMainMessageController
- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    //登录用户的电子名片信息
    XMPPvCardTemp *myvCard = [CSXMPPTool sharedCSXMPPTool].vCard.myvCardTemp;
    //显示头像 和 账号 使用电子名片模块
    self.avatarImage.layer.cornerRadius = 38;
    self.avatarImage.clipsToBounds = YES;
    if (myvCard.photo) {
        [self.avatarImage setBackgroundImage:[UIImage imageWithData:myvCard.photo] forState:UIControlStateNormal];
    } else {
        [self.avatarImage setBackgroundImage:[UIImage imageNamed:@"avatar_default"] forState:UIControlStateNormal];
    }
    
    //    self.userLbl.text = myvCard.jid.user;
    self.accountLbl.text = [CSAccount shareAccount].user;
    self.nickNameLbl.text = myvCard.nickname;
    
    self.orgUnitLbl.text = myvCard.orgName;
    
    if (myvCard.orgUnits.count > 0) {
        self.departmentLbl.text = [myvCard.orgUnits objectAtIndex:0];
    }
    self.position.text =  myvCard.title;
    
    self.telLbl.text = myvCard.note;
    
    NSArray *emails = myvCard.emailAddresses;
    if (emails.count > 0) {
        self.emaiLbl.text = emails[0];
    }
    
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
   
    //根据tag 操作
    
    //获取cell
    UITableViewCell *selectCell = [tableView cellForRowAtIndexPath:indexPath];
    
    NSInteger tag = selectCell.tag;
    

    if (tag == 1) {
        
        CSLog(@"进入下一个");

    }
    
    if (tag == 2) {
        return;
         CSLog(@"没有操作");
    }
   
}
/**
 *  选择图片
 */
- (void) chooseImg {
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"照相" otherButtonTitles:@"图片库", nil];
    sheet.delegate = self;
    [sheet showInView:self.view];
    
}

/**
 *  选择器
 */
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 2) return;
    
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    //设置代理
    imgPicker.delegate = self;
    imgPicker.allowsEditing = YES; //允许编辑图片
    
    if (buttonIndex == 0) { //照相
        imgPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
    } else { //图片库
       imgPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    }
    
    // 显示控制器
    [self presentViewController:imgPicker animated:YES completion:nil];
    
}
#pragma mark -选择器的代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    //获取修改后的图片
    UIImage *editImg = info[UIImagePickerControllerEditedImage];
    
    [self.avatarImage setBackgroundImage:editImg forState:UIControlStateNormal];
    
    //移除控制器
    [self dismissViewControllerAnimated:YES completion:nil];
    
    //保存图片到服务器
    [self editVCardViewController:nil didFinishedSave:nil];
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //获取目标控制器
    id dsetVc = segue.destinationViewController;
    if ([dsetVc isKindOfClass:[CSEditVCardViewController class]]) {
        CSEditVCardViewController *editVc = dsetVc;
        editVc.cell = sender;
        editVc.delegate = self;
    }
    
}
#pragma mark - 编辑信息控制器的代理
- (void) editVCardViewController:(CSEditVCardViewController *)edtiVc didFinishedSave:(id)sender {
    CSLog(@"保存完成");
    
    XMPPvCardTemp *myvCard = [CSXMPPTool sharedCSXMPPTool].vCard.myvCardTemp;
    
    //重新设置myvCard 的信息
    
    myvCard.photo = UIImageJPEGRepresentation(self.avatarImage.currentBackgroundImage, 0.75);
    myvCard.nickname = self.nickNameLbl.text;
    myvCard.orgName = self.orgUnitLbl.text;
    if (self.departmentLbl.text != nil) {
        myvCard.orgUnits = @[self.departmentLbl.text];
    }
    myvCard.title = self.position.text;
    myvCard.note = self.telLbl.text;
    if (self.emaiLbl.text.length > 0) {
        myvCard.emailAddresses = @[self.emaiLbl.text];
    }
    
    
    //数据保存到服务器
    [[CSXMPPTool sharedCSXMPPTool].vCard updateMyvCardTemp:myvCard];
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
   
        return 40;

}
/**
 *  修改头像
 */
- (IBAction)modifyAvatar {
    [self chooseImg];
}
@end
