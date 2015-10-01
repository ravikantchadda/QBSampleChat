//
//  ChatMessageVC.h
//  QBSampleChat
//
//  Created by ravi kant on 9/24/15.
//  Copyright © 2015 Net Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMChatViewController.h"
@interface ChatMessageVC : QMChatViewController
- (void)refreshMessagesShowingProgress:(BOOL)showingProgress;

@property (nonatomic, strong) QBChatDialog* dialog;
@property (nonatomic, assign) BOOL shouldUpdateNavigationStack;
@end
