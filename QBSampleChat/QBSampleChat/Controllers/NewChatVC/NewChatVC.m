//
//  NewChatVC.m
//  QBSampleChat
//
//  Created by ravi kant on 9/23/15.
//  Copyright © 2015 Net Solutions. All rights reserved.
//

#import "NewChatVC.h"

@interface NewChatVC ()
@property (nonatomic, copy) NSArray *customUsers;
@property (nonatomic, assign, getter=isUsersAreDownloading) BOOL usersAreDownloading;
@end

@implementation NewChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    self.title = @"New Chat";
     [self retrieveUsers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}
- (IBAction)createNewChat:(id)sender {
    __weak __typeof(self) weakSelf = self;
    [self createChatWithName:nil completion:^(QBChatDialog *dialog) {
        __typeof(self) strongSelf = weakSelf;
        if( dialog != nil ) {
            //   [strongSelf navigateToChatViewControllerWithDialog:dialog];
        }
        else {
            //   [SVProgressHUD showErrorWithStatus:@"Can not create dialog"];
        }
    }];

}

- (void)createChatWithName:(NSString *)name completion:(void(^)(QBChatDialog* dialog))completion
{
    NSMutableIndexSet* indexSet = [NSMutableIndexSet indexSet];
    [self.tableView.indexPathsForSelectedRows enumerateObjectsUsingBlock:^(NSIndexPath* obj, NSUInteger idx, BOOL *stop) {
        [indexSet addIndex:obj.row];
    }];
    
    NSArray *selectedUsers = [self.users objectsAtIndexes:indexSet];
    
    if (selectedUsers.count == 1) {
        // Creating private chat dialog.
        [ServicesManager.instance.chatService createPrivateChatDialogWithOpponent:selectedUsers.firstObject completion:^(QBResponse *response, QBChatDialog *createdDialog) {
            if( !response.success  && createdDialog == nil ) {
                completion(nil);
            }
            else {
                completion(createdDialog);
            }
        }];
    } else {
        assert("no users given");
    }
}

#pragma mark - QB retrieveUsers
- (void)retrieveUsers
{
    __weak __typeof(self)weakSelf = self;
    
    // Retrieving users from cache.
    [ServicesManager.instance.usersService cachedUsersWithCompletion:^(NSArray *users) {
        if (users != nil && users.count != 0) {
            [weakSelf loadDataSourceWithUsers:users];
        } else {
            [weakSelf downloadLatestUsers];
        }
    }];
}
#pragma mark - QB downloadLatestUsers
- (void)downloadLatestUsers
{
    if (self.isUsersAreDownloading) return;
    
    self.usersAreDownloading = YES;
    
    __weak __typeof(self)weakSelf = self;
    [appDelegate() loadActivityAlert];
    
    // Downloading latest users.
    [ServicesManager.instance.usersService downloadLatestUsersWithSuccessBlock:^(NSArray *latestUsers) {
        [appDelegate() dismissActivityAlert];
        [weakSelf loadDataSourceWithUsers:latestUsers];
        weakSelf.usersAreDownloading = NO;
    } errorBlock:^(QBResponse *response) {
        [appDelegate() dismissActivityAlert];
        weakSelf.usersAreDownloading = NO;
    }];
}
- (void)loadDataSourceWithUsers:(NSArray *)users
{
    [self func_GetUsersDetails:qbUsersMemoryStorage.unsortedUsers];
    
}

#pragma mark - QB func_GetUsersDetails
-(void)func_GetUsersDetails:(NSArray*)users{
    _excludeUsersIDs = @[];
    _customUsers =  [[users copy] sortedArrayUsingComparator:^NSComparisonResult(QBUUser *obj1, QBUUser *obj2) {
        return [obj1.login compare:obj2.login options:NSNumericSearch];
    }];
    
    NSArray *tempArray;
    
    tempArray = _customUsers == nil ? qbUsersMemoryStorage.unsortedUsers : _customUsers;
    NSMutableArray *mUsers;
    mUsers = [NSMutableArray array];
    [mUsers addObjectsFromArray:tempArray];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID == %d", [QBChat instance].currentUser.ID];
    NSArray *newArray = [mUsers filteredArrayUsingPredicate:predicate];
    NSLog(@"%d",(int)[newArray count]);
    if (newArray.count>0) {
        [mUsers removeObjectsInArray:newArray];
    }
    _users = [mUsers copy];
    [self.tableView reloadData];
    
    
    
    
}
- (void)addUsers:(NSArray *)users {
    NSMutableArray *mUsers;
    if( _users != nil ){
        mUsers = [_users mutableCopy];
    }
    else {
        mUsers = [NSMutableArray array];
    }
    [mUsers addObjectsFromArray:users];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ID == %d", [QBChat instance].currentUser.ID];
    NSArray *newArray = [mUsers filteredArrayUsingPredicate:predicate];
    NSLog(@"%d",(int)[newArray count]);
    if (newArray.count>0) {
        [mUsers removeObjectsInArray:newArray];
    }
    _users = [mUsers copy];
    
    [self.tableView reloadData];
}
- (void)setExcludeUsersIDs:(NSArray *)excludeUsersIDs {
    if  (excludeUsersIDs == nil) {
        _users = self.customUsers == nil ? self.customUsers : qbUsersMemoryStorage.unsortedUsers;
        return;
    }
    if ([excludeUsersIDs isEqualToArray:self.users]) {
        return;
    }
    if (self.customUsers == nil) {
        _users = [qbUsersMemoryStorage.unsortedUsers filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (ID IN %@)", self.excludeUsersIDs]];
    } else {
        _users = self.customUsers;
    }
    // add excluded users to future remove
    NSMutableArray *excludedUsers = [NSMutableArray array];
    [_users enumerateObjectsUsingBlock:^(QBUUser *obj, NSUInteger idx, BOOL *stop) {
        for (NSNumber *excID in excludeUsersIDs) {
            if (obj.ID == excID.integerValue) {
                [excludedUsers addObject:obj];
            }
        }
    }];
    
    //remove excluded users
    NSMutableArray *mUsers = [_users mutableCopy];
    [mUsers removeObjectsInArray:excludedUsers];
    _users = [mUsers copy];
}

- (NSUInteger)indexOfUser:(QBUUser *)user {
    return [self.users indexOfObject:user];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.users.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newchatcell"];
    
//    UIImageView *userImage = (UIImageView *)[cell viewWithTag:101];
//    userImage.layer.cornerRadius = userImage.frame.size.width/2.0;
//    userImage.layer.borderColor = [UIColor darkGrayColor].CGColor;
//    userImage.layer.borderWidth = 4.0;
    
    
    QBUUser *user = (QBUUser *)self.users[indexPath.row];
    UILabel *userName = (UILabel *)[cell viewWithTag:102];
    userName.text = user.fullName;
    
    return cell;
    
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // [self checkJoinChatButtonState];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self checkJoinChatButtonState];
}





/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
