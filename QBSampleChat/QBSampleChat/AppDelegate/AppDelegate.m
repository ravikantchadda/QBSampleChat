//
//  AppDelegate.m
//  QBSampleChat
//
//  Created by ravi kant on 9/22/15.
//  Copyright © 2015 Net Solutions. All rights reserved.
//

#import "AppDelegate.h"
#import "Reachability.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    /* 
     *********Set QuickBlox credentials**************
     ************************************************
     */
    [QBApplication sharedApplication].applicationId = 28611;
    [QBConnection registerServiceKey:@"9afja92M-LQUsJs"];
    [QBConnection registerServiceSecret:@"REfBEVVwCgMp4ng"];
    [QBSettings setAccountKey:@"bxPrANkDGRQVp2iofgPT"];
    
    // Enables Quickblox REST API calls debug console output
    [QBSettings setLogLevel:QBLogLevelDebug];
    
    // Enables detailed XMPP logging in console output
    [QBSettings enableXMPPLogging];
    
    self.window.backgroundColor = [UIColor whiteColor];
    BOOL alreadyLogedIn = [[NSUserDefaults standardUserDefaults]boolForKey:@"registerUser"];
    
    NSString *strStoryBoard = alreadyLogedIn ? @"Tabbar" : @"Main";
    
    if ([strStoryBoard isEqualToString:@"Tabbar"]) {
        
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"useralreadyregistered"];

        // grab correct storyboard depending on screen height
        UIStoryboard *storyboard = [self grabStoryboard:strStoryBoard];
        // display storyboard
        UIViewController *controller = [storyboard instantiateInitialViewController];
        self.window.rootViewController = controller;
        
    }
    else{
    
        // grab correct storyboard depending on screen height
        UIStoryboard *storyboard = [self grabStoryboard:strStoryBoard];
        // display storyboard
        UIViewController *controller = [storyboard instantiateInitialViewController];
        self.window.rootViewController = controller;
    
    }
    
    
    
    
    
   
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    // Logout from chat
    //
    [ServicesManager.instance.chatService logoutChat];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    // Login to QuickBlox Chat
    //
    [ServicesManager.instance.chatService logIn:nil];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark --------------------------------------------------------------------------------------------------
#pragma mark - Method to Call Another Storyboard
- (UIStoryboard *)grabStoryboard:(NSString*)storyBoard {
    
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:storyBoard bundle:nil];
    
    return storyboard;
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.netsolution.SampleCoreData.QBSampleChat" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"QBSampleChat" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"QBSampleChat.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark-------------------------------------------------------------------
#pragma mark- Check Internet Connection using reachability methods

- (void) updateInterfaceWithReachability: (Reachability*) curReach
{
    if(curReach == self.internetReach)
    {
        NSLog(@"Internet");
        NetworkStatus netStatus = [curReach currentReachabilityStatus];
        switch (netStatus)
        {
            case NotReachable:
            {
                self.internetWorking = -1;
                NSLog(@"Internet NOT WORKING");
                break;
            }
            case ReachableViaWiFi:
            {
                self.internetWorking = 0;
                break;
            }
            case ReachableViaWWAN:
            {
                self.internetWorking = 0;
                break;
                
            }
        }
    }
}

-(void)CheckInternetConnection
{
    self.internetReach = [Reachability reachabilityForInternetConnection];
    [self.internetReach reachableOnWWAN];
    [self updateInterfaceWithReachability: self.internetReach];
}


#pragma mark-------------------------------------------------------------------
#pragma mark- loadActivityAlert methods
-(void)loadActivityAlert{
   [GMDCircleLoader setOnView:self.window withTitle:@"Loading..." animated:YES];
    
}
-(void)dismissActivityAlert{
    [GMDCircleLoader hideFromView:self.window animated:YES];

}


@end
AppDelegate *appDelegate(void){

    return (AppDelegate*)[UIApplication sharedApplication].delegate;

}
