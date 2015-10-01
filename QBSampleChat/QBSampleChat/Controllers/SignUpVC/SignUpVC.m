//
//  SignUpVC.m
//  QBSampleChat
//
//  Created by ravi kant on 9/23/15.
//  Copyright © 2015 Net Solutions. All rights reserved.
//

#import "SignUpVC.h"

@interface SignUpVC ()
@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtEmailAddress;

@end

@implementation SignUpVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --------------------------------------------------------------------------------------------------
#pragma mark - UIButton Actions
- (IBAction)action_SignUp:(id)sender {
    
    //************Check space characters enetered in the textField**************
    //*****************************************************************************
    NSString *_strName= [_txtName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *_strEmail= [_txtEmailAddress.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if (_strName.length==0) {
        
        //**************Create AlertController************************
        //************************************************************
        UIAlertController *_alertController = [UIAlertController alertControllerWithTitle:@"Alert!" message:kAlertEnterName preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *_actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * __nonnull action) {
            
            [_alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [_alertController addAction:_actionOK];
        
        [self presentViewController:_alertController animated:YES completion:nil];
        return;
        
    }
    else if (_strName.length<4){
        
        //**************Create AlertController************************
        //************************************************************
        UIAlertController *_alertController = [UIAlertController alertControllerWithTitle:@"Alert!" message:kAlertNameLength preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *_actionOK = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * __nonnull action) {
            
            [_alertController dismissViewControllerAnimated:YES completion:nil];
        }];
        [_alertController addAction:_actionOK];
        
        [self presentViewController:_alertController animated:YES completion:nil];
        return;
        
    }
    else if (_strEmail.length==0) {
        
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
        NSMutableArray *tagsArray = [NSMutableArray array];
        [tagsArray addObjectsFromArray:[NSArray arrayWithObjects:@"dev", nil]];
        
        // Create QuickBlox User entity
        QBUUser *user = [QBUUser user];
        user.email = _txtEmailAddress.text;
        user.login =_txtEmailAddress.text;
        user.fullName = _txtName.text;
        user.tags = tagsArray;
        user.password =  @"12345678";
        [SVProgressHUD showWithStatus:@"Signing Up..." maskType:SVProgressHUDMaskTypeClear];
        
        [ServicesManager.instance SignUPWithUser:user completion:^(BOOL success, NSString *errorMessage) {
            if (success) {
                [SVProgressHUD showSuccessWithStatus:@"Singed Up"];
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"registerUser"];
                // grab correct storyboard depending on screen height
                UIStoryboard *storyboard = [self grabStoryboard];
                // display storyboard
                UITabBarController *tabbar = [storyboard instantiateInitialViewController];
                tabbar.selectedIndex = 0;
                [self presentViewController:tabbar animated:YES completion:nil];
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

#pragma mark- ---------------------------------------------------------------
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


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
