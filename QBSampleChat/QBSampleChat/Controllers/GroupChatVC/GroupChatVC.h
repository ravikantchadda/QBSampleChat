//
//  GroupChat.h
//  QBSampleChat
//
//  Created by ravi kant on 9/23/15.
//  Copyright © 2015 Net Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GroupChatVC : UITableViewController
/**
 *  Adds users to datasource.
 *
 *  @param users NSArray of users to add.
 */
- (void)addUsers:(NSArray *)users;

/**
 *  Default: empty []
 *  Excludes users with given ids from data source
 */

/**
 *  @return Array of QBUUser instances
 */
@property (nonatomic, strong, readonly) NSArray *users;
@property (nonatomic, strong) NSArray *excludeUsersIDs;
@property (nonatomic, assign) BOOL isLoginDataSource;

- (NSUInteger)indexOfUser:(QBUUser *)user;
@end
