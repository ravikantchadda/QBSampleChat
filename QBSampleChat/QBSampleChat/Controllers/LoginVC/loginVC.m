//
//  ViewController.m
//  QBSampleChat
//
//  Created by ravi kant on 9/22/15.
//  Copyright © 2015 Net Solutions. All rights reserved.
//

#import "LoginVC.h"

@interface LoginVC ()

@property (weak, nonatomic) IBOutlet UITextField *txtEmailAddress;

@end

@implementation LoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --------------------------------------------------------------------------------------------------
#pragma mark - UIButton Actions
- (IBAction)submit:(id)sender {
    
    //************Check space characters enetered in the textField**************
    //*****************************************************************************
    NSString *_strEmail= [_txtEmailAddress.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (_strEmail.length==0) {
        
        //**************Create AlertController************************
        //************************************************************
        UIAlertController *_alertController = [UIAlertController alertControllerWithTitle:@"Alert!" message:kAlertEnterEmail preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *_actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * __nonnull action) {
            
            [_alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [_alertController addAction:_actionOK];
        
        [self presentViewController:_alertController animated:YES completion:nil];
        return;
        
    }
    
    else if (_strEmail.length>0) {
        
        NSString *emailReg = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailReg];
        
        //*************Evaluate the emailID Correct or Not******************
        //*****************************************************************************
        if ([emailTest evaluateWithObject:_strEmail])
        {
            
        }
        else{
            
            UIAlertController *_alertController = [UIAlertController alertControllerWithTitle:@"Alert!" message:kAlertEmailVerification preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *_actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * __nonnull action) {
                
                [_alertController dismissViewControllerAnimated:YES completion:nil];
            }];
            [_alertController addAction:_actionOK];
            
            [self presentViewController:_alertController animated:YES completion:nil];
            
            return;
            
        }
        
    }
    
    
    [appDelegate() CheckInternetConnection];
    if([appDelegate() internetWorking] ==0)
    {
                
        // Create QuickBlox User entity
        QBUUser *user = [QBUUser user];
        user.email = _txtEmailAddress.text;
        user.password =  @"12345678";
        [SVProgressHUD showWithStatus:@"Logging in..." maskType:SVProgressHUDMaskTypeClear];
        // Logging in to Quickblox REST API and chat.
        [ServicesManager.instance logInWithUser:user completion:^(BOOL success, NSString *errorMessage) {
            if (success) {
               [SVProgressHUD showSuccessWithStatus:@"Logged in"];
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"registerUser"];
                [[NSUserDefaults standardUserDefaults]setObject:_txtEmailAddress.text forKey:@"email"];
                // grab correct storyboard depending on screen height
                UIStoryboard *storyboard = [self grabStoryboard];
                // display storyboard
                UITabBarController *tabbar = [storyboard instantiateInitialViewController];
                tabbar.selectedIndex = 0;
                [self presentViewController:tabbar animated:NO completion:nil];
            } else {
                [SVProgressHUD showErrorWithStatus:@"Can not login"];

            }
        }];

        
    }else{
    
        
        //**************Create AlertController************************
        //************************************************************
        UIAlertController *_alertController = [UIAlertController alertControllerWithTitle:@"Network Error" message:kAlertInternetCheck preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *_actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * __nonnull action) {
           
            [_alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [_alertController addAction:_actionOK];
        
        [self presentViewController:_alertController animated:YES completion:nil];
        
    }
 
}

#pragma mark --------------------------------------------------------------------------------------------------
#pragma mark - Method to Call Another Storyboard
- (UIStoryboard *)grabStoryboard {
    
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Tabbar" bundle:nil];
    
    return storyboard;
}

#pragma mark --------------------------------------------------------------------------------------------------
#pragma mark - UITextField Delegate Methods
- (void)textFieldDidBeginEditing:(UITextField *)textField{
    
    int difference = 0;
    if(kDeviceHeight == 480.0f){
        difference = 145;
        
        [UIView animateWithDuration:0.3 animations:^{
            self.view.frame =CGRectMake(0.0,-100, self.view.frame.size.width, self.view.frame.size.height);
            
        } completion:^(BOOL finished) {
        }];

        
        
    }
    else if(kDeviceHeight == 568.0f){
    }else if(kDeviceHeight == 667.0f){
    }else if(kDeviceHeight == 736.0f){
    }else {
        // If we detect an invalid resolution, don't show the intro
        NSLog(@"Detected unsupported resolution. Please add support for this resolution!");
    }
    
    
   
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
   
    
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    [UIView animateWithDuration:0.2 animations:^{
        self.view.frame =CGRectMake(0.0,0.0, self.view.frame.size.width, self.view.frame.size.height);
        
    } completion:^(BOOL finished) {
    }];

    return YES;
}
@end
