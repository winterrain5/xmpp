//
//  CSEditVCardController.h
//  xmpp
//
//  Created by 石冬冬 on 15/11/30.
//  Copyright © 2015年 石冬冬. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CSEditVCardController;
@class CSMainMessageController;
@protocol CSEditVCardControllerDelegate <NSObject>

- (void) editVCardController:(CSEditVCardController *)edtiVc
                 didFinishedSave:(id) sender;

@end
@interface CSEditVCardController : UITableViewController
@property (nonatomic, strong) CSMainMessageController *msgController;
@property (nonatomic, assign) id<CSEditVCardControllerDelegate> delegate;
@end
