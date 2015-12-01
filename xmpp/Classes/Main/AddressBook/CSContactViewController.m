//
//  CSContactViewController.m
//  xmpp
//
//  Created by 石冬冬 on 15/11/28.
//  Copyright © 2015年 石冬冬. All rights reserved.
//

#import "CSContactViewController.h"
#import "CSContactCell.h"
#import "CSChatViewController.h"
@interface CSContactViewController () <NSFetchedResultsControllerDelegate>{
    NSFetchedResultsController *_resultsContrl;
}
/**好友*/
@property (strong,nonatomic) NSArray *users;
@property (nonatomic, strong)  XMPPUserCoreDataStorageObject *user;

@end
@implementation CSContactViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    [self loadUserData];
    
}
- (void) loadUserData {
    //显示好友数据 (保存到XMPPRoster.splite)
    
    //1 上下文 关联数据库文件
    NSManagedObjectContext *rosterContext = [CSXMPPTool sharedCSXMPPTool].rosterStorage.mainThreadManagedObjectContext;
    
    //2 request 请求查询哪张表
    NSFetchRequest *requset = [NSFetchRequest fetchRequestWithEntityName:@"XMPPUserCoreDataStorageObject"];
    
    //设置排序
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"displayName" ascending:YES];
    requset.sortDescriptors = @[sort];
    
    //过滤
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"subscription != %@",@"none"];
    requset.predicate = pre;
    
    //3 执行 请求
    NSError *error = nil;
    _resultsContrl = [[NSFetchedResultsController alloc] initWithFetchRequest:requset managedObjectContext:rosterContext sectionNameKeyPath:nil cacheName:nil];
    _resultsContrl.delegate = self;
    [_resultsContrl performFetch:&error];
//    NSArray *users = [rosterContext executeFetchRequest:requset error:&error];
//    self.users = users;
//    CSLog(@"%@",users);
}
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _resultsContrl.fetchedObjects.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
    CSContactCell *cell = [[CSContactCell alloc] initCellWithTableView:tableView];
    //获取对应的好友
    XMPPUserCoreDataStorageObject *user = _resultsContrl.fetchedObjects[indexPath.row];
    
    
    //通过kvo监听用户状态的改变
//    [user addObserver:self forKeyPath:@"sectionNum" options:NSKeyValueObservingOptionNew context:nil];
    
    //显示好友头像
    cell.avatarImg.layer.cornerRadius = 20;
    cell.avatarImg.clipsToBounds = YES;
    if (user.photo) {
        cell.avatarImg.image = user.photo;
    } else {
        //从服务器获取头像
        
       NSData * imgData = [[CSXMPPTool sharedCSXMPPTool].vCardAvatar photoDataForJID:user.jid];
        if (imgData) {
            cell.avatarImg.image = [UIImage imageWithData:imgData];

        } else {
            cell.avatarImg.image = [UIImage imageNamed:@"avatar_default_small"];
        }
    }
    NSString *name =  user.displayName;
    //表识用户是否在线
    //0：在线 1：离开 2：离线
    switch ([user.sectionNum integerValue]) {
        case 0:
            cell.nameLbl.text = [NSString stringWithFormat:@"[在线]%@",name];
//             cell.statusLbl.text = @"在线";
//            cell.statusLbl.textColor = [UIColor blueColor];
            break;
        case 1:
            cell.nameLbl.text = [NSString stringWithFormat:@"[离开]%@",name];

//            cell.statusLbl.text = @"离开";
//            cell.statusLbl.textColor = [UIColor lightGrayColor];
            break;
        case 2:
            cell.nameLbl.text = [NSString stringWithFormat:@"[离线]%@",name];

//            cell.statusLbl.text = @"离线";
//            cell.statusLbl.textColor = [UIColor lightGrayColor];
            break;
            
        default:
            break;
    }   return cell;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  50;
}
#pragma mark - 结果控制器的代理  数据库内容改变就会调用该方法
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView reloadData];
}
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
//    [self.tableView reloadData];
//}
#pragma mark - 删除好友
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //删除好友
        XMPPUserCoreDataStorageObject *user = _resultsContrl.fetchedObjects[indexPath.row];
       
        [[CSXMPPTool sharedCSXMPPTool].roster removeUser:user.jid];
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    XMPPUserCoreDataStorageObject *user = _resultsContrl.fetchedObjects[indexPath.row];
    self.user = user;
    XMPPJID *friendsJid =  [_resultsContrl.fetchedObjects[indexPath.row] jid];
    //进入聊天控制器
    [self performSegueWithIdentifier:@"toChatVcSegue" sender:friendsJid];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    id destVc = segue.destinationViewController;
    if ([destVc isKindOfClass:[CSChatViewController class]]) {
        CSChatViewController *chatVc = destVc;
        chatVc.friendJid = sender;
        chatVc.nickName = self.user.displayName;
    }
}
@end
