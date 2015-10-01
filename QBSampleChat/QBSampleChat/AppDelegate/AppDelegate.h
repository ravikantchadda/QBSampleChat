//
//  AppDelegate.h
//  QBSampleChat
//
//  Created by ravi kant on 9/22/15.
//  Copyright © 2015 Net Solutions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
@class Reachability;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;


//******Core Data objects*********
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

//******Internet Reachibility************
@property (nonatomic, retain) Reachability                              *internetReach;
@property (nonatomic, retain) Reachability                              *wifiReach;
@property int                                                           internetWorking;

//**********Internet Check Methods***********
- (void) updateInterfaceWithReachability: (Reachability*)curReach;
- (void)CheckInternetConnection;

//**********Create Activity indicator with alert*************
-(void)loadActivityAlert;
-(void)dismissActivityAlert;

//**********Methods to handle CoreData***************
- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;


@end

//************Create global Appdelagate Variable to Access the AppDelegate methods and variables****************
AppDelegate *appDelegate(void);

