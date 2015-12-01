//
//  CSEditVCardViewController.h
//  xmpp
//
//  Created by 石冬冬 on 15/11/27.
//  Copyright © 2015年 石冬冬. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CSEditVCardViewController;
@protocol CSEditVCardViewControllerDelegate <NSObject>

- (void) editVCardViewController:(CSEditVCardViewController *)edtiVc
                 didFinishedSave:(id) sender;

@end
@interface CSEditVCardViewController : UITableViewController
@property (nonatomic, weak) UITableViewCell *cell;
@property (nonatomic, assign) id<CSEditVCardViewControllerDelegate> delegate;

@end
