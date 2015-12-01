//
//  CSContactCell.m
//  xmpp
//
//  Created by 石冬冬 on 15/11/28.
//  Copyright © 2015年 石冬冬. All rights reserved.
//

#import "CSContactCell.h"

@implementation CSContactCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (instancetype) initCellWithTableView:(UITableView *) tableView {
    static NSString *Id = @"users";
    CSContactCell *cell = [tableView dequeueReusableCellWithIdentifier:Id];
    if (cell == nil) {
        cell = [[CSContactCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Id];
    }
    return cell;
}
@end
