//
//  CSContactCell.h
//  xmpp
//
//  Created by 石冬冬 on 15/11/28.
//  Copyright © 2015年 石冬冬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSContactCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *statusLbl;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImg;
@property (weak, nonatomic) IBOutlet UILabel *nameLbl;
- (instancetype) initCellWithTableView:(UITableView *) tableView;
@end
