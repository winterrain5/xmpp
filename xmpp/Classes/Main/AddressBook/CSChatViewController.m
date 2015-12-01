//
//  CSChatViewController.m
//  xmpp
//
//  Created by 石冬冬 on 15/11/29.
//  Copyright © 2015年 石冬冬. All rights reserved.
//

#import "CSChatViewController.h"
#import <AVFoundation/AVAudioRecorder.h>
//#import <AVFoundation/AVAudioSettings.h>
#import <Availability.h>
#import <AVFoundation/AVAudioPlayer.h>
@interface CSChatViewController () <NSFetchedResultsControllerDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,XMPPOutgoingFileTransferDelegate> {
    /**结果控制器*/
    NSFetchedResultsController *_resultController;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *chatTf;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomConstraint;
@property (nonatomic, retain) AVAudioRecorder   *recorder;
@property (nonatomic, retain) AVAudioPlayer     *player;

@property (nonatomic, strong) XMPPOutgoingFileTransfer *xmppOutgoingFileTransfer;

@end

@implementation CSChatViewController
- (XMPPOutgoingFileTransfer *)xmppOutgoingFileTransfer
{
    if (!_xmppOutgoingFileTransfer) {
        _xmppOutgoingFileTransfer = [[XMPPOutgoingFileTransfer alloc] initWithDispatchQueue:dispatch_get_global_queue(0, 0)];
        [_xmppOutgoingFileTransfer activate:[CSXMPPTool sharedCSXMPPTool].xmppStream];
        [_xmppOutgoingFileTransfer addDelegate:self delegateQueue:dispatch_get_global_queue(0, 0)];
    }
    return _xmppOutgoingFileTransfer;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //分割字符
    NSArray *strArray = [self.nickName componentsSeparatedByString:@"@"];
    //得到需要的字符串
    if (strArray.count > 0) {
        self.title = [strArray objectAtIndex:0];

    } else {
        self.title = self.nickName;
    }

    //去掉分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //禁止选中
    self.tableView.allowsSelection = NO;
    //背景色
    CGFloat grayColor = 240/255.0;
    self.tableView.backgroundColor = [UIColor colorWithRed:grayColor green:grayColor blue:grayColor alpha:1];
    
    //加载数据库的聊天数据
    [self loadMsgData];
    
    
    // 键盘监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbFrmWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(kbFrmWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    
}
- (void) loadMsgData {
    //1 上下文
    NSManagedObjectContext *msgContext = [CSXMPPTool sharedCSXMPPTool].msgAcrhingStorage.mainThreadManagedObjectContext;
    
    //2 查询请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"XMPPMessageArchiving_Message_CoreDataObject"];
    
    // 过滤(当前登录用户 并且是好友的聊天消息)
    //当前登录用户的Jid
    NSString *loginUserJid = [CSXMPPTool sharedCSXMPPTool].xmppStream.myJID.bare;
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"streamBareJidStr = %@ AND bareJidStr = %@",loginUserJid,self.friendJid.bare];
    request.predicate = pre;
    
    //设置排序
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    request.sortDescriptors = @[timeSort];
    
    //执行请求
    _resultController = [[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:msgContext sectionNameKeyPath:nil cacheName:nil];
    _resultController.delegate = self;
    NSError *error;
    [_resultController performFetch:&error];

}
#pragma mark 键盘将显示
-(void)kbFrmWillShow:(NSNotification *)notifi{
    CGRect kbBounds = [notifi.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    // 键盘的高度
    CGFloat keyboardH = kbBounds.size.height;
    
    // iPad横屏时键盘的高度是bounds的width[打印测试即可]
    BOOL isLandscape = UIInterfaceOrientationIsLandscape(self.interfaceOrientation);
    if (!iSiPhoneDevice && isLandscape) {
        keyboardH = kbBounds.size.width;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        //self.view.y = -keyboardH;
        self.bottomConstraint.constant = keyboardH;
        [self.view layoutIfNeeded];
    }];
}
#pragma mark 键盘将消失
-(void)kbFrmWillHide:(NSNotification *)notifi{
    [UIView animateWithDuration:0.25 animations:^{
        //self.view.y = 0;
        self.bottomConstraint.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - 结果控制器的代理
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
    
    //滚动表格到当前行
    NSIndexPath *lastIndex = [NSIndexPath indexPathForRow:_resultController.fetchedObjects.count - 1 inSection:0];
    [self.tableView scrollToRowAtIndexPath:lastIndex atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma - tableView的数据源
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _resultController.fetchedObjects.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //获取聊天信息
    XMPPMessageArchiving_Message_CoreDataObject *msgObj = _resultController.fetchedObjects[indexPath.row];
    
    
    //判断消息的类型有没有附件
    //1  获取原始XML数据
    XMPPMessage *message = msgObj.message;
//    CSLog(@"%@",message);
    // 获取附件类型
    NSString *bodyType = [message attributeStringValueForName:@"bodyType"];
    
    // 判断是发出消息还是接收消息
    NSString *identifier = msgObj.isOutgoing?@"TextMessageRight":@"TextMessageLeft";
    if ([bodyType isEqualToString:@"image"]) { //图片
        identifier = msgObj.isOutgoing?@"ImgMessageRight":@"ImgMessageLeft";
        //2 遍历message的子节点
        NSArray *child = message.children;
        for (XMPPElement *note in child) {
            if([[note name] isEqualToString:@"attachment"]) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                //将获取的附件字符串转成图片
                NSString *imgBase64Str = [note stringValue];
                NSData *imgData = [[NSData alloc] initWithBase64EncodedString:imgBase64Str options:0];
                UIImage *img = [UIImage imageWithData:imgData];
                UIImageView *imgMsg = (UIImageView *) [cell viewWithTag:100];
                imgMsg.image = img;
                return cell;
            }

    }
    
    } else if ([bodyType isEqualToString:@"sound"]) { //音频
    
    
    }

    //文字消息
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    UILabel *contentLabel = (UILabel *)[cell viewWithTag:100];
    contentLabel.text = message.body;
    
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}
#pragma mark 发送聊天数据
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    NSString *msgContent = textField.text;
    
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    [msg addBody:msgContent];
    [[CSXMPPTool sharedCSXMPPTool].xmppStream sendElement:msg];
    
    //清空输入框文本
    textField.text = nil;
    
    
    return true;
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self.chatTf endEditing:YES];
}
- (IBAction)attachmentBtnClick:(id)sender {
    
    //从图片库选取图片
    UIImagePickerController *imgPic = [[UIImagePickerController alloc] init];
    imgPic.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imgPic.delegate = self;
    
    [self presentViewController:imgPic animated:YES completion:nil];
}
#pragma mark -选择器的代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    //获取选择后的图片
    UIImage *selectedImg = info[UIImagePickerControllerOriginalImage];
    
    NSData *imgData = UIImagePNGRepresentation(selectedImg);
    
    [self sendAttachmentWithData:imgData bodyType:@"image"];
}
- (void) sendAttachmentWithData:(NSData *)data bodyType:(NSString *) bodyType {
   
    //发送图片
    XMPPMessage *msg = [XMPPMessage messageWithType:@"chat" to:self.friendJid];
    
    //设置类型
    [msg addAttributeWithName:@"bodyType" stringValue:bodyType];
#pragma mark -没有body就不会认attachment
    [msg addBody:bodyType];
    
    // 把附件经过“base64编码”转成字符串
   
    NSString *base64Str = [data base64EncodedStringWithOptions:0];
    //定义附件节点
    XMPPElement *attachment = [XMPPElement elementWithName:@"attachment" stringValue:base64Str];
    [msg addChild:attachment];
    [[CSXMPPTool sharedCSXMPPTool].xmppStream sendElement:msg];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    CSLog(@"%@",msg);

}
/**
 *  开始录音
 */
- (IBAction)startRecord {
    NSString *path =  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    path = [path stringByAppendingPathComponent:[XMPPStream generateUUID]];
    path = [path stringByAppendingPathExtension:@"wav"];
    
    NSURL *URL = [NSURL fileURLWithPath:path];
    NSDictionary *dic = nil;
    _recorder = [[AVAudioRecorder alloc] initWithURL:URL settings:dic error:nil];
    [_recorder prepareToRecord];
    [_recorder record];
}
- (IBAction)sendRecord {
    [_recorder stop];
//    NSArray *resources = [[CSXMPPTool sharedCSXMPPTool].roster sortedResources:YES];
//    for (XMPPResourceMemoryStorageObject *object in resources) {
//        if ([object.jid.bare isEqualToString:self.friendJid.bare]) {
//            NSData *data = [[[NSData alloc] initWithContentsOfURL:_recorder.url] copy];
//            NSError *err;
//            [self.xmppOutgoingFileTransfer sendData:data named:_recorder.url.lastPathComponent toRecipient:object.jid description:nil error:&err];
//            if (err) {
//                NSLog(@"%@",err);
//            }
//            break;
//        }
//    }
//    
//    _recorder = nil;
}
- (IBAction)cancelRecord {
}
@end
