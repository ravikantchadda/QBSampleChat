//
//  ChatVC.m
//  QBSampleChat
//
//  Created by ravi kant on 9/22/15.
//  Copyright © 2015 Net Solutions. All rights reserved.
//

#import "ChatVC.h"
#import "ChatMessageVC.h"

@interface ChatVC ()<QMChatServiceDelegate,QMAuthServiceDelegate,QMChatConnectionDelegate>
@property (nonatomic, strong) id <NSObject> observerDidBecomeActive;
@property (nonatomic, readonly) NSArray* dialogs;

@property (nonatomic, assign) BOOL shouldUpdateDialogsAfterLogIn;
@end

@implementation ChatVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
     self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
    __weak __typeof(self)weakSelf = self;
    
    self.observerDidBecomeActive = [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                                                     object:nil queue:[NSOperationQueue mainQueue]
                                                                                 usingBlock:^(NSNotification *note) {
                                                                                     __typeof(self) strongSelf = weakSelf;
                                                                                     
                                                                                     if ([[QBChat instance] isLoggedIn]) {
                                                                                         [strongSelf loadDialogs];
                                                                                     } else {
                                                                                         strongSelf.shouldUpdateDialogsAfterLogIn = YES;
                                                                                     }
                                                                                 }];
    
    //self.navigationItem.title = [NSString stringWithFormat:@"Logged in as %@", [QBSession currentSession].currentUser.login];
    
    [ServicesManager.instance.chatService addDelegate:self];
    
    [self loadDialogs];
}
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self.observerDidBecomeActive];
    [[ServicesManager instance].chatService removeDelegate:self];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark --------------------------------------------------------------------------------------------------
#pragma mark - Method to loadDialogs
- (void)loadDialogs
{
    BOOL shouldShowSuccessStatus = NO;
    if ([self dialogs].count == 0) {
        shouldShowSuccessStatus = YES;
        [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeClear];
    }
    
    __weak __typeof(self) weakSelf = self;
    [ServicesManager.instance.chatService allDialogsWithPageLimit:kDialogsPageLimit extendedRequest:nil iterationBlock:^(QBResponse *response, NSArray *dialogObjects, NSSet *dialogsUsersIDs, BOOL *stop) {
        __typeof(self) strongSelf = weakSelf;
        if (response.error != nil) {
            [SVProgressHUD showErrorWithStatus:@"Can not download"];
        }
        
        for (QBChatDialog* dialog in dialogObjects) {
            if (dialog.type != QBChatDialogTypePrivate) {
                // Joining to group chat dialogs.
                [[ServicesManager instance].chatService joinToGroupDialog:dialog failed:^(NSError *error) {
                    NSLog(@"Failed to join room with error: %@", error.localizedDescription);
                }];
            }
        }
        [strongSelf.tableView reloadData];
    } completion:^(QBResponse *response) {
        if (shouldShowSuccessStatus) {
            [SVProgressHUD showSuccessWithStatus:@"Completed"];
        }
    }];
}


#pragma mark --------------------------------------------------------------------------------------------------
#pragma mark - Method to Return dialogs
- (NSArray *)dialogs
{
    // Retrieving dialogs sorted by last message date from memory storage.
    return [ServicesManager.instance.chatService.dialogsMemoryStorage dialogsSortByLastMessageDateWithAscending:NO];
}

#pragma mark --------------------------------------------------------------------------------------------------
#pragma mark - Method to Call Another Storyboard
- (UIStoryboard *)grabStoryboard {
    
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    return storyboard;
}
#pragma mark --------------------------------------------------------------------------------------------------
#pragma mark - UIBarButtonItem Actions
- (IBAction)logout:(id)sender {
    
    [SVProgressHUD showWithStatus:@"Logging out..." maskType:SVProgressHUDMaskTypeClear];
    [[QMServicesManager instance] logoutWithCompletion:^{
         [SVProgressHUD showSuccessWithStatus:@"Logged out!"];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"registerUser"];
         [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"useralreadyregistered"];
        // grab correct storyboard depending on screen height
        UIStoryboard *storyboard = [self grabStoryboard];
        // display storyboard
        UIViewController *viewController = [storyboard instantiateInitialViewController];
        [self presentViewController:viewController animated:NO completion:nil];
    }];
}
- (IBAction)addUserstoCreateChat:(id)sender {
    //**************Create AlertController************************
    //************************************************************
    UIAlertController *_alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    __weak __typeof(self)weakSelf = self;
    UIAlertAction *_actionNewChat = [UIAlertAction actionWithTitle:@"New Chat" style:UIAlertActionStyleDefault handler:^(UIAlertAction * __nonnull action) {
        
        __typeof(self) strongSelf = weakSelf;
        [strongSelf performSegueWithIdentifier:kGoToNewChatSegueIdentifier sender:nil];
        
        [_alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *_actionGroupChat = [UIAlertAction actionWithTitle:@"Group Chat" style:UIAlertActionStyleDefault handler:^(UIAlertAction * __nonnull action) {
        
        __typeof(self) strongSelf = weakSelf;
        [strongSelf performSegueWithIdentifier:kGoToGroupchatSegueIdentifier sender:nil];
        [_alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    UIAlertAction *_actionCancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * __nonnull action) {
        
        [_alertController dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [_alertController addAction:_actionNewChat];
    [_alertController addAction:_actionGroupChat];
    [_alertController addAction:_actionCancel];
    
    [self presentViewController:_alertController animated:YES completion:nil];

}



#pragma mark --------------------------------------------------------------------------------------------------
#pragma mark - Table view datasource/delegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dialogs.count;;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatuserscell" forIndexPath:indexPath];
    
    
    /**
     *  Cell UIImageView(Userimage)
     */
    UIImageView *userImage = (UIImageView *)[cell viewWithTag:101];
  //  userImage.layer.cornerRadius = userImage.frame.size.width/2.0;
  //  userImage.layer.borderColor = [UIColor darkGrayColor].CGColor;
    
    /**
     *  Cell UILable(UserName)
     */
    UILabel *lblUserName = (UILabel *)[cell viewWithTag:102];
    
    /**
     *  Cell UILable(LastMessage)
     */
    UILabel *lblLastMessage = (UILabel *)[cell viewWithTag:103];
    
    /**
     *  Cell UILable(UnreadCount)
     */
    UILabel *lblUnreadCount = (UILabel *)[cell viewWithTag:104];
    
    /**
     *  Cell UIView(UnreadCounterView)
     */
    UIImageView *viewUnreadCounter = (UIImageView *)[cell viewWithTag:105];
    viewUnreadCounter.layer.cornerRadius = viewUnreadCounter.frame.size.width/2.0;
    viewUnreadCounter.layer.borderColor = [UIColor whiteColor].CGColor;
    viewUnreadCounter.layer.borderWidth = 0.8;
    
    
     QBChatDialog *chatDialog = self.dialogs[indexPath.row];
    
    switch (chatDialog.type) {
        case QBChatDialogTypePrivate: {
            
            QBUUser *recipient = [qbUsersMemoryStorage userWithID:chatDialog.recipientID];
            lblUserName.text = recipient.login == nil ? (recipient.fullName == nil ? [NSString stringWithFormat:@"%lu", (unsigned long)recipient.ID] : recipient.fullName) : recipient.fullName;
            lblLastMessage.text = chatDialog.lastMessageText;
            userImage.image = [UIImage imageNamed:@"chatRoomIcon"];
            
        }
            break;
        case QBChatDialogTypeGroup: {
            
            lblUserName.text = chatDialog.name;
            lblLastMessage.text = chatDialog.lastMessageText;
            userImage.image = [UIImage imageNamed:@"GroupChatIcon"];
        }
            break;
        case QBChatDialogTypePublicGroup: {
            
            lblUserName.text = chatDialog.name;
            lblLastMessage.text = chatDialog.lastMessageText;
            userImage.image = [UIImage imageNamed:@"GroupChatIcon"];
        }
            break;
            
        default:
            break;
    }
    BOOL hasUnreadMessages = chatDialog.unreadMessagesCount > 0;
    viewUnreadCounter.hidden = !hasUnreadMessages;
    if (hasUnreadMessages) {
        NSString* unreadText = nil;
        if (chatDialog.unreadMessagesCount > 99) {
            unreadText = @"99+";
        } else {
            unreadText = [NSString stringWithFormat:@"%lu", (unsigned long)chatDialog.unreadMessagesCount];
        }
        lblUnreadCount.text = unreadText;
    } else {
        lblUnreadCount.text = nil;
    }
    
    
    return cell;
}

- (void)deleteDialogWithID:(NSString *)dialogID {
    __weak __typeof(self) weakSelf = self;
    // Deleting dialog from Quickblox and cache.
    [ServicesManager.instance.chatService deleteDialogWithID:dialogID
                                                  completion:^(QBResponse *response) {
                                                      if (response.success) {
                                                          __typeof(self) strongSelf = weakSelf;
                                                          [strongSelf.tableView reloadData];
                                                          [SVProgressHUD dismiss];
                                                      } else {
                                                          [SVProgressHUD showErrorWithStatus:@"Can not delete dialog"];
                                                          NSLog(@"can not delete dialog: %@", response.error);
                                                      }
                                                  }];
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    QBChatDialog *dialog = self.dialogs[indexPath.row];
    
    [self performSegueWithIdentifier:kGoToMessageControllerSegueIdentifier sender:dialog];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64.0f;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        QBChatDialog *chatDialog = self.dialogs[indexPath.row];
        
        // remove current user from occupants
        NSMutableArray *occupantsWithoutCurrentUser = [NSMutableArray array];
        for (NSNumber *identifier in chatDialog.occupantIDs) {
            if (![identifier isEqualToNumber:@(ServicesManager.instance.currentUser.ID)]) {
                [occupantsWithoutCurrentUser addObject:identifier];
            }
        }
        chatDialog.occupantIDs = [occupantsWithoutCurrentUser copy];
        
        
        [SVProgressHUD showWithStatus:@"Leaving dialog..." maskType:SVProgressHUDMaskTypeClear];
        
        if (chatDialog.type == QBChatDialogTypeGroup) {
            __weak __typeof(self) weakSelf = self;
            // Notifying user about updated dialog - user left it.
            [[ServicesManager instance].chatService notifyAboutUpdateDialog:chatDialog
                                                  occupantsCustomParameters:nil
                                                           notificationText:[NSString stringWithFormat:@"%@ has left dialog!", [ServicesManager instance].currentUser.login]
                                                                 completion:^(NSError *error) {
                                                                     NSAssert(error == nil, @"Problems while leaving dialog!");
                                                                     [weakSelf deleteDialogWithID:chatDialog.ID];
                                                                 }];
        } else {
            [self deleteDialogWithID:chatDialog.ID];
        }
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Leave";
}


#pragma mark --------------------------------------------------------------------------------------------------
#pragma mark Chat Service Delegate

- (void)chatService:(QMChatService *)chatService didAddChatDialogsToMemoryStorage:(NSArray *)chatDialogs {
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didAddChatDialogToMemoryStorage:(QBChatDialog *)chatDialog {
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didUpdateChatDialogInMemoryStorage:(QBChatDialog *)chatDialog {
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didReceiveNotificationMessage:(QBChatMessage *)message createDialog:(QBChatDialog *)dialog {
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didAddMessageToMemoryStorage:(QBChatMessage *)message forDialogID:(NSString *)dialogID {
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didAddMessagesToMemoryStorage:(NSArray *)messages forDialogID:(NSString *)dialogID {
    [self.tableView reloadData];
}

- (void)chatService:(QMChatService *)chatService didDeleteChatDialogWithIDFromMemoryStorage:(NSString *)chatDialogID {
    [self.tableView reloadData];
}

#pragma mark --------------------------------------------------------------------------------------------------
#pragma mark - QMChatConnectionDelegate

- (void)chatServiceChatDidConnect:(QMChatService *)chatService
{
    [SVProgressHUD showSuccessWithStatus:@"Chat connected!" maskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:@"Logging in to chat..." maskType:SVProgressHUDMaskTypeClear];
}

- (void)chatServiceChatDidReconnect:(QMChatService *)chatService
{
    [SVProgressHUD showSuccessWithStatus:@"Chat reconnected!" maskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD showWithStatus:@"Logging in to chat..." maskType:SVProgressHUDMaskTypeClear];
}

- (void)chatServiceChatDidAccidentallyDisconnect:(QMChatService *)chatService
{
    [SVProgressHUD showErrorWithStatus:@"Chat disconnected!"];
}

- (void)chatServiceChatDidLogin
{
    [SVProgressHUD showSuccessWithStatus:@"Logged in!"];
    
    if (self.shouldUpdateDialogsAfterLogIn) {
        
        self.shouldUpdateDialogsAfterLogIn = NO;
        [self loadDialogs];
    }
}

- (void)chatServiceChatDidNotLoginWithError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Did not login with error: %@", [error description]]];
}

- (void)chatServiceChatDidFailWithStreamError:(NSError *)error
{
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"Chat failed with error: %@", [error description]]];
}


#pragma mark --------------------------------------------------------------------------------------------------
#pragma mark - Navigation

//// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
       if ([segue.identifier isEqualToString:kGoToMessageControllerSegueIdentifier]) {
           ChatMessageVC    *chatViewController = segue.destinationViewController;
           chatViewController.hidesBottomBarWhenPushed = YES;
           chatViewController.dialog = sender;
       }
    
}


@end
