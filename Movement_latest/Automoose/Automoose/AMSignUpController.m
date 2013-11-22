//
//  AMSignUpController.m
//  Automoose
//
//  Created by Srinivas on 05/07/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import "AMSignUpController.h"
#import "AMConstants.h"
#import "AMUtility.h"
#import <QuartzCore/QuartzCore.h>
#import "TPKeyboardAvoidingScrollView.h"
#import "AMAppDelegate.h"
#import "MBProgressHUD.h"
@interface AMSignUpController ()
{
    MBProgressHUD *progressHUD;
}
@end

@implementation AMSignUpController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    TPKeyboardAvoidingScrollView *scrollview = [[TPKeyboardAvoidingScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, kScreenHeight)];
    if(isPhone568)
        [scrollview setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bgLogin-568h.png"]]];
    else
        [scrollview setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bgLogin.png"]]];
    [self.view addSubview:scrollview];
    
    singUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    username = [[UITextField alloc]init];
    password = [[UITextField alloc]init];
    email = [[UITextField alloc]init];
    
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    
    [singUpButton setTitle:@"Finish and sign in" forState:UIControlStateNormal];
    [singUpButton setTitle:@"" forState:UIControlStateHighlighted];

    username.textColor = [AMUtility getColorwithRed:216 green:216 blue:216];
    password.textColor = [AMUtility getColorwithRed:216 green:216 blue:216];
    email.textColor = [AMUtility getColorwithRed:216 green:216 blue:216];
    
    username.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    password.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    email.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    
    username.returnKeyType = UIReturnKeyNext;
    email.returnKeyType =  UIReturnKeyNext;
    password.returnKeyType =UIReturnKeyJoin ;
    
    username.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    password.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    email.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    
    username.layer.cornerRadius = 5.0f;
    password.layer.cornerRadius = 5.0f;
    email.layer.cornerRadius = 5.0f;

    UILabel *logoText = [[UILabel alloc]initWithFrame:CGRectMake(55, 70, 247, 36)];
    logoText.text = @"Movement";
    logoText.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:50];
    logoText.backgroundColor = [UIColor clearColor];
    logoText.textColor = [UIColor whiteColor];
    [scrollview addSubview:logoText];
    if(!isPhone568)
        logoText.frame = CGRectMake(55, 30, 247, 36);
    
    UILabel *singUpText = [[UILabel alloc]initWithFrame:CGRectMake(55,120, 210, 36)];
    singUpText.text = @"Sign up";
    singUpText.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:30];
    singUpText.backgroundColor = [UIColor clearColor];
    singUpText.textColor = [UIColor whiteColor];
    singUpText.textAlignment = NSTextAlignmentCenter;
    [scrollview addSubview:singUpText];
    if(!isPhone568)
        singUpText.frame = CGRectMake(55, 80, 210, 36);
    
    singUpButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    cancelButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    
    [singUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [singUpButton setTitleColor:[AMUtility getColorwithRed:67 green:67 blue:67] forState:UIControlStateHighlighted];
    [cancelButton setTitleColor:[AMUtility getColorwithRed:67 green:67 blue:67] forState:UIControlStateHighlighted];
    
    
    [singUpButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
    [cancelButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
    
    singUpButton.layer.cornerRadius = 5.0f;
    cancelButton.layer.cornerRadius = 5.0f;
    
    username.placeholder = @"Name";
    email.placeholder = @"Email Address";
    password.placeholder = @"Password";
    if(isPhone568)
    {
        [cancelButton setFrame:CGRectMake(37, 352+45, 247.0f, 36.0f)];
        [singUpButton setFrame:CGRectMake(37, 352, 247.0f, 36.0f)];
        float yOffset = 0.0f;
        [username setFrame:CGRectMake(37,100+80.0f,247,36)];
        yOffset += 45;
        [email setFrame:CGRectMake(37,100+80.0f+yOffset,247,36)];
        yOffset += 45;
        [password setFrame:CGRectMake(37,100+80.0f+yOffset,247,36)];
    }
    else
    {
        [cancelButton setFrame:CGRectMake(37, 322+45, 247.0f, 36.0f)];
        [singUpButton setFrame:CGRectMake(37, 322, 247.0f, 36.0f)];
        float yOffset = 0.0f;
        [username setFrame:CGRectMake(37,70+80.0f,247,36)];
        yOffset += 45;
        [email setFrame:CGRectMake(37,70+80.0f+yOffset,247,36)];
        yOffset += 45;
        [password setFrame:CGRectMake(37,70+80.0f+yOffset,247,36)];
    }
    
    
    UIView *tempView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 36)];
    UIView *tempView2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 36)];
    UIView *tempView3 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 36)];
    
    username.leftView = tempView1;
    username.leftViewMode = UITextFieldViewModeAlways;
    
    password.leftView = tempView2;
    password.leftViewMode = UITextFieldViewModeAlways;
    
    email.leftView = tempView3;
    email.leftViewMode = UITextFieldViewModeAlways;
    username.textAlignment = NSTextAlignmentLeft;
    email.textAlignment = NSTextAlignmentLeft;
    password.textAlignment = NSTextAlignmentLeft;
    
    [scrollview addSubview:username];
    [scrollview addSubview:password];
    [scrollview addSubview:email];
    [scrollview addSubview:singUpButton];
    [scrollview addSubview:cancelButton];
    
    username.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    password.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    email.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    
    [singUpButton addTarget:self action:@selector(signUpButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    [singUpButton addTarget:self action:@selector(setSelectedColorFor:) forControlEvents:UIControlEventTouchDown];
    [singUpButton addTarget:self action:@selector(setUnSelectedColorFor:) forControlEvents:UIControlEventTouchDragExit];
    
    [cancelButton addTarget:self action:@selector(setSelectedColorFor:) forControlEvents:UIControlEventTouchDown];
    [cancelButton addTarget:self action:@selector(setUnSelectedColorFor:) forControlEvents:UIControlEventTouchDragExit];
    
    username.delegate = self;
    password.delegate = self;
    email.delegate = self;
    
    username.returnKeyType = UIReturnKeyNext;
    email.returnKeyType = UIReturnKeyNext;
    password.returnKeyType = UIReturnKeyJoin;
    
    username.autocapitalizationType = UITextAutocapitalizationTypeNone;
    password.autocapitalizationType = UITextAutocapitalizationTypeNone;
    email.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    username.autocorrectionType = UITextAutocorrectionTypeNo;
    password.autocorrectionType = UITextAutocorrectionTypeNo;
    email.autocorrectionType = UITextAutocorrectionTypeNo;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)signUpButtonAction{
    
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [singUpButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
    });
    if(!username.text.length || !password.text.length || !email.text.length)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"All the fields are required" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
   }
    if(![self NSStringIsValidEmail:email.text]){
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Enter valid email id" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    [self.view endEditing:YES];
    
    progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [progressHUD setDimBackground:YES];
    [progressHUD setLabelText:@"Signing up..Please wait"];
    
    PFUser *user = [PFUser user];
    user.username = username.text;
    user.password = password.text;
    user.email = email.text;
    [user signUpInBackgroundWithBlock:^(BOOL succeed, NSError *error){
        [progressHUD setHidden:YES];
        if(error && !succeed)
        {
            NSString *errorString = [[error userInfo] objectForKey:@"error"];

            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:errorString delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
        else
        {
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            
            [mixpanel track:kSingUpTrack properties:@{
                  kUsername: [[PFUser currentUser]objectForKey:kUsername],
            }];
            NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", [user objectId]];
            [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
            [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:@"channels"];
            [[PFInstallation currentInstallation] saveEventually];
            [[PFUser currentUser] setObject:privateChannelName forKey:@"channel"];
            [[PFUser currentUser] setObject:[[PFUser currentUser] objectForKey:@"username"] forKey:kDisplayName];
            [[PFUser currentUser] setObject:[[[PFUser currentUser] objectForKey:kUsername] lowercaseString] forKey:kLowerCaseDisplayName];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"MMM dd, yyyy"];
            NSDate *now = [NSDate date];
            NSString *createdString= [dateFormatter stringFromDate:now];
            [[PFUser currentUser] setObject:createdString forKey:kAccountCreatedDate];
            
            [[PFUser currentUser] save];
            
            NSData *imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"person_icon" ofType:@"png"]];
            NSData *imageDataBig = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"person_big" ofType:@"png"]];
            [[NSUserDefaults standardUserDefaults]setObject:imageData forKey:kProfileImage_small];
            [[NSUserDefaults standardUserDefaults]setObject:imageDataBig forKey:kProfileImage_Big];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            NSData *openInviteEventData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"defaultpublic" ofType:@"png"]];
            NSData *onlyInviteEventData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"defaultprivate" ofType:@"png"]];
            
            PFFile *openEvent = [PFFile fileWithData:openInviteEventData];
            PFFile *inviteOnlyEvent = [PFFile fileWithData:onlyInviteEventData];
            
            [openEvent saveInBackgroundWithBlock:^(BOOL succeded,NSError *erro){
                [[PFUser currentUser]setObject:openEvent forKey:kOpenEventImage];
                [[PFUser currentUser]saveEventually];
            }];
            
            [inviteOnlyEvent saveInBackgroundWithBlock:^(BOOL success, NSError *err){
                [[PFUser currentUser]setObject:inviteOnlyEvent forKey:kInviteOnlyEventImage];
                [[PFUser currentUser]saveEventually];
            }];
            
            PFFile *image = [PFFile fileWithData:imageData];
            PFFile *large_image = [PFFile fileWithData:imageDataBig];
            
            [image saveInBackgroundWithBlock:^(BOOL succeed,NSError *error)
             {
                 [[PFUser currentUser] setObject:image forKey:kProfileImage];
                 [[PFUser currentUser] saveInBackground];
             }];
            
            [large_image saveInBackgroundWithBlock:^(BOOL succeed , NSError *error)
             {
                 [[PFUser currentUser] setObject:large_image forKey:kProfileImage_Big];
                 [[PFUser currentUser] saveInBackground];
             }];
            [AMUtility saveUsersLocationtoServer];
            [(AMAppDelegate *)[[UIApplication sharedApplication]delegate  ] presentTabBarController];
        }
    }];
}
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = YES;
    NSString *stricterFilterString = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSString *laxString = @".+@.+\\.[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}
-(void)cancelButtonAction{
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [cancelButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
    });
     [self.view endEditing:YES];
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == username)
       [email becomeFirstResponder];
    else if (textField == email)
        [password becomeFirstResponder];
    else
    {
        [self.view endEditing:YES];
        [self signUpButtonAction];
    }
    return YES;
}

-(void)setSelectedColorFor:(UIButton *)sender
{
    sender.backgroundColor = [AMUtility getColorwithRed:244 green:244 blue:244];
}
-(void)setUnSelectedColorFor:(UIButton *)sender{
    sender.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
}

@end
