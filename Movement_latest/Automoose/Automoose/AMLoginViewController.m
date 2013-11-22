//
//  AMLoginViewController.m
//  Automoose
//
//  Created by Srinivas on 05/07/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import "AMLoginViewController.h"
#import "TPKeyboardAvoidingScrollView.h"
#import <QuartzCore/QuartzCore.h>
#import "AMUtility.h"
#import "AMConstants.h"
#import "AMAppDelegate.h"
#import "AMSignUpController.h"
#import "UIImage+ResizeAdditions.h"
#import "MBProgressHUD.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>

@interface AMLoginViewController ()
{
    NSMutableData *_data;
    MBProgressHUD *progressHUD;
    BOOL friendsAutofollowed,image1Saved,image2Saved;
}
@end

@implementation AMLoginViewController

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
    [self.view addSubview:scrollview];
    
    if(isPhone568)
        [scrollview setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bgLogin-568h.png"]]];
    else
        [scrollview setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bgLogin.png"]]];
    
    username = [[UITextField alloc]init];
    password = [[UITextField alloc]init];
    password.secureTextEntry = YES;
    
    
    signUpButton = [UIButton buttonWithType:UIButtonTypeCustom];
    logInButton = [UIButton buttonWithType:UIButtonTypeCustom];
    facebookSignIn = [UIButton buttonWithType:UIButtonTypeCustom];

    [facebookSignIn setTitle:@"Sign in with Facebook" forState:UIControlStateNormal];
    //    [scrollview.fa cebookButton setTitle:@"" forState:UIControlStateHighlighted];
    
    [signUpButton setTitle:@"Sign up" forState:UIControlStateNormal];
    
    [logInButton setTitle:@"Sign in" forState:UIControlStateNormal];
    
   
    
    username.delegate = self;
    password.delegate = self;
    
    username.autocorrectionType = UITextAutocorrectionTypeNo;
    password.autocorrectionType = UITextAutocorrectionTypeNo;
    
    username.autocapitalizationType = UITextAutocapitalizationTypeNone;
    password.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    username.textColor = [AMUtility getColorwithRed:216 green:216 blue:216];
    password.textColor = [AMUtility getColorwithRed:216 green:216 blue:216];
    
    username.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    password.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    
    username.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    password.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    username.layer.cornerRadius = 5.0f;
    password.layer.cornerRadius = 5.0f;
    
    [logInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [facebookSignIn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [logInButton setTitleColor:[AMUtility getColorwithRed:67 green:67 blue:67] forState:UIControlStateHighlighted];
    [signUpButton setTitleColor:[AMUtility getColorwithRed:67 green:67 blue:67] forState:UIControlStateHighlighted];
    [facebookSignIn setTitleColor:[AMUtility getColorwithRed:67 green:67 blue:67] forState:UIControlStateHighlighted];
    
    [logInButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
    [signUpButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
    [facebookSignIn.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
    
    
    facebookSignIn.layer.cornerRadius = 5.0f;
    
    UILabel *logoText = [[UILabel alloc]initWithFrame:CGRectMake(55, 110, 247, 36)];
    logoText.text = @"Movement";
    logoText.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:50];
    logoText.backgroundColor = [UIColor clearColor];
    logoText.textColor = [UIColor whiteColor];
    [scrollview addSubview:logoText];
    if(!isPhone568)
        logoText.frame = CGRectMake(55, 80, 247, 36);
    
    logInButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    signUpButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    facebookSignIn.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];

    
    UIView *whiteView = [[UIView alloc]init];
    [whiteView setBackgroundColor:[UIColor whiteColor]];
    if(isPhone568)
    {
        [facebookSignIn setFrame:CGRectMake(37.0f, 180+130+45, 247.0f, 36.0f)];
        [logInButton setFrame:CGRectMake(123+1+37, 180+130, 123, 36.0f)];
        signUpButton.frame = CGRectMake(37,180+130, 123, 36);
        
        username.frame = CGRectMake(37, 180, 247, 36);
        password.frame = CGRectMake(37, 180+45, 247, 36);
        whiteView.frame = CGRectMake(37+123, 180+130, 1, 36);
    }
    else
    {
        [facebookSignIn setFrame:CGRectMake(37.0f, 150+130+45, 247.0f, 36.0f)];
        [logInButton setFrame:CGRectMake(123+1+37, 150+130, 123, 36.0f)];
        signUpButton.frame = CGRectMake(37,150+130, 123, 36);
        
        username.frame = CGRectMake(37, 150, 247, 36);
        password.frame = CGRectMake(37, 150+45, 247, 36);
        whiteView.frame = CGRectMake(37+123, 150+130, 1, 36);
    }
    [scrollview addSubview:whiteView];
    
    UIView *tempView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 36)];
    UIView *tempView2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 36)];
    tempView1.backgroundColor = [UIColor clearColor];
    tempView2.backgroundColor = [UIColor clearColor];
    
    username.textAlignment = NSTextAlignmentLeft;
    password.textAlignment = NSTextAlignmentLeft;
    
    username.leftView = tempView1;
    password.leftView = tempView2;
    
    username.leftViewMode = UITextFieldViewModeAlways;
    password.leftViewMode = UITextFieldViewModeAlways;
    
    [self setMaskforHighlightedBackground:signUpButton byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft];
    [self setMaskforHighlightedBackground:logInButton byRoundingCorners:UIRectCornerBottomRight | UIRectCornerTopRight];
    
    [scrollview addSubview:username];
    [scrollview addSubview:password];
    [scrollview addSubview:signUpButton];
    [scrollview addSubview:logInButton];
    [scrollview addSubview:facebookSignIn];
    
    username.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    password.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [username setPlaceholder:@"Username"];
    [password setPlaceholder:@"Password"];
    
    [logInButton addTarget:self action:@selector(signInButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [signUpButton addTarget:self action:@selector(singUpButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [facebookSignIn addTarget:self action:@selector(facebookSignInAction) forControlEvents:UIControlEventTouchUpInside];
    
    [logInButton addTarget:self action:@selector(setSelectedColorFor:) forControlEvents:UIControlEventTouchDown];
    [logInButton addTarget:self action:@selector(setUnSelectedColorFor:) forControlEvents:UIControlEventTouchDragExit];
    
    [signUpButton addTarget:self action:@selector(setSelectedColorFor:) forControlEvents:UIControlEventTouchDown];
    [signUpButton addTarget:self action:@selector(setUnSelectedColorFor:) forControlEvents:UIControlEventTouchDragExit];
    
    [facebookSignIn addTarget:self action:@selector(setSelectedColorFor:) forControlEvents:UIControlEventTouchDown];
    [facebookSignIn addTarget:self action:@selector(setUnSelectedColorFor:) forControlEvents:UIControlEventTouchDragExit];

    
    username.returnKeyType = UIReturnKeyNext;
    password.returnKeyType = UIReturnKeyGo;
    
//    [nine addTarget:self action:@selector(changeButtonBackGroundColor:) forControlEvents:UIControlEventTouchDown];
//    [nine addTarget:self action:@selector(resetButtonBackGroundColor:) forControlEvents:UIControlEventTouchUpInside];
    
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void) setMaskforHighlightedBackground:(UIView*)view byRoundingCorners:(UIRectCorner)corners
{
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    view.layer.mask = shape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)signInButtonAction{
    
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [logInButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    });
    
    if(!username.text.length || !password.text.length)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Both the fields are required" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        return;
    }
     [self.view endEditing:YES];
    
    progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [progressHUD setDimBackground:NO];
    [progressHUD setLabelText:@"Logging in"];
    

    [PFUser logInWithUsernameInBackground:username.text password:password.text block:^(PFUser *user, NSError *error){
        progressHUD.hidden = YES;
       if(user)
       {
           NSData *openInviteEventData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"defaultpublic" ofType:@"png"]];
           NSData *onlyInviteEventData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"defaultprivate" ofType:@"png"]];
           
           PFFile *openEvent = [PFFile fileWithData:openInviteEventData];
           PFFile *inviteOnlyEvent = [PFFile fileWithData:onlyInviteEventData];
           [openEvent saveInBackgroundWithBlock:^(BOOL succeded,NSError *erro){
                if(![[PFUser currentUser]objectForKey:kOpenEventImage])
                {
                    [[PFUser currentUser]setObject:openEvent forKey:kOpenEventImage];
                    [[PFUser currentUser]saveEventually];
                }

           }];

           [inviteOnlyEvent saveInBackgroundWithBlock:^(BOOL success, NSError *err){
               if(![[PFUser currentUser]objectForKey:kInviteOnlyEventImage ]){
                   [[PFUser currentUser]setObject:inviteOnlyEvent forKey:kInviteOnlyEventImage];
                   [[PFUser currentUser]saveEventually];
               }
           }];

           

           Mixpanel *mixpanel = [Mixpanel sharedInstance];
           
           [mixpanel track:kLoginTrack properties:@{
                 kUsername: [[PFUser currentUser]objectForKey:kUsername],
            }];
           NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", [user objectId]];
           [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
           [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:@"channels"];
           [[PFInstallation currentInstallation] saveInBackground];
           [user setObject:privateChannelName forKey:@"channel"];
           [user saveInBackground];
           PFFile *img = [[PFUser currentUser]objectForKey:kProfileImage];
           [img getDataInBackgroundWithBlock:^(NSData *data , NSError *error)
            {
                [[NSUserDefaults standardUserDefaults]setObject:data forKey:kProfileImage_small];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }];
            [AMUtility fetchFollowing:^(NSError *error){
           }];
           [self dismissViewControllerAnimated:YES completion:NULL];
           [(AMAppDelegate *)[[UIApplication sharedApplication]delegate] presentTabBarController];
           [AMUtility saveUsersLocationtoServer];
           [self loadUserProfileImages];
       }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Login Failed." message:@"Invalid Username and/or Password." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
            [alert show];
        }
    }];
    
}
-(void)singUpButtonAction{
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [signUpButton setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    });
     [self.view endEditing:YES];
    AMSignUpController *signUpController= [[AMSignUpController alloc]init];
    signUpController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentModalViewController:signUpController animated:YES];
}
-(void)facebookSignInAction{
    double delayInSeconds = 0.2;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [facebookSignIn setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
    });
     [self.view endEditing:YES];
    
    NSArray *permissionsArray =  [NSArray arrayWithObjects:@"publish_actions",nil];
    progressHUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [progressHUD setDimBackground:YES];
    [progressHUD setLabelText:@"Logging in"];
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user , NSError *error){
        if(error && !user){
            progressHUD.hidden = YES;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.localizedDescription delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alert show];
            return ;
        }
        else if(user.isNew){
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

            
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    [self facebookRequestDidLoad:result];
                } else {
                    [self facebookRequestDidFailWithError:error];
                }
            }];
            
            NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", [user objectId]];
            [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
            [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:@"channels"];
            [[PFInstallation currentInstallation] saveInBackground];
            [user setObject:privateChannelName forKey:@"channel"];
            [user saveEventually];
            [progressHUD setLabelText:@"Building your profile"];
           
            [AMUtility saveUsersLocationtoServer];
        }
        else{
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            
            [mixpanel track:KFacebookSignUp properties:@{
                  kUsername: [[PFUser currentUser]objectForKey:kUsername],
             }];
            progressHUD.hidden = YES;
            PFFile *img = [user objectForKey:kProfileImage];
            if(img)
            {
            [img getDataInBackgroundWithBlock:^(NSData *data , NSError *error)
             {
                 [[NSUserDefaults standardUserDefaults]setObject:data forKey:kProfileImage_small];
                 [[NSUserDefaults standardUserDefaults]synchronize];
                 [(AMAppDelegate *)[[UIApplication sharedApplication]delegate] presentTabBarController];
                 [AMUtility saveUsersLocationtoServer];
             }];
            }
            else
            {
                NSData *imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"person_icon" ofType:@"png"]];
                [[NSUserDefaults standardUserDefaults]setObject:imageData forKey:kProfileImage_small];
                [[NSUserDefaults standardUserDefaults]synchronize];
                [(AMAppDelegate *)[[UIApplication sharedApplication]delegate] presentTabBarController];
                [AMUtility saveUsersLocationtoServer];
            }
            [self loadUserProfileImages];
        }
    }];
}

-(void)loadUserProfileImages{
    PFFile *image  = [[PFUser currentUser]objectForKey:kProfileImage_Big];
    [image getDataInBackgroundWithBlock:^(NSData *data1 ,NSError *error){
        [[NSUserDefaults standardUserDefaults]setObject:data1 forKey:kProfileImage_Big];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }];
    
    PFFile *small_image = [[PFUser currentUser]objectForKey:kProfileImage_small];
    [small_image getDataInBackgroundWithBlock:^(NSData *data2, NSError *error){
        [[NSUserDefaults standardUserDefaults]setObject:data2 forKey:kProfileImage_small];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }];
}


#pragma mark - PF_FBRequestDelegate
- (void)request:(FBRequest *)request didLoad:(id)result {
    // This method is called twice - once for the user's /me profile, and a second time when obtaining their friends. We will try and handle both scenarios in a single method.
    
    NSArray *data = [result objectForKey:@"data"];
    
    if (data) {
        if (![[PFUser currentUser] objectForKey:@"userAlreadyAutoFollowedFacebookFriends"])
        {
            NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:data.count];
            for (NSDictionary *friendData in data) {
                [facebookIds addObject:[friendData objectForKey:@"id"]];
            }
//            [self.hud setLabelText:@"Following Friends"];
            
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"MMM dd, yyyy"];
            NSDate *now = [NSDate date];
            NSString *createdString= [dateFormatter stringFromDate:now];
            [[PFUser currentUser] setObject:createdString forKey:kAccountCreatedDate];
//            [[PFUser currentUser]saveInBackground];
            
            [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"userAlreadyAutoFollowedFacebookFriends"];
            NSError *error = nil;
            
            // find common Facebook friends already using Anypic
            PFQuery *facebookFriendsQuery   = [PFUser query];
            [facebookFriendsQuery whereKey:@"facebookId" containedIn:facebookIds];
            
            NSArray *automooseFriends = [facebookFriendsQuery findObjects:&error];
            
            if (!error) {
                [automooseFriends enumerateObjectsUsingBlock:^(PFUser *newFriend, NSUInteger idx, BOOL *stop) {
                    PFObject *joinActivity = [PFObject objectWithClassName:@"Activity"];
                    [joinActivity setObject:[PFUser currentUser] forKey:@"fromUser"];
                    [joinActivity setObject:newFriend forKey:@"toUser"];
                    [joinActivity setObject:@"joined" forKey:@"type"];
                    
//                    PFACL *joinACL = [PFACL ACL];
//                    [joinACL setPublicWriteAccess:YES];
//                    joinActivity.ACL = joinACL;
                    [AMUtility followUserInBackground:newFriend block:^(BOOL succeeded, NSError *error) { }];
                }];
            }
        }
        
        [[PFUser currentUser]saveInBackgroundWithBlock:^(BOOL succeded, NSError *error){
            [self loadProfileImage];
            Mixpanel *mixpanel = [Mixpanel sharedInstance];
            
            [mixpanel track:kFacebookSignIn properties:@{
                  kUsername: [[PFUser currentUser]objectForKey:kUsername],
             }];
        }];
        friendsAutofollowed = YES;
        [self showTabBarController];
    } else {

        NSString *facebookId = [result objectForKey:@"id"];
        NSString *facebookName = [result objectForKey:@"name"];
        if (facebookName && facebookName != 0) {
            [[PFUser currentUser] setObject:facebookName forKey:@"displayName"];
            [[PFUser currentUser] setObject:[facebookName lowercaseString] forKey:kLowerCaseDisplayName];
        }
        else
        {
            [[PFUser currentUser] setObject:@"Someone" forKey:@"displayName"];
            [[PFUser currentUser] setObject:[@"Someone" lowercaseString] forKey:kLowerCaseDisplayName];
        }
        
        if (facebookId && facebookId != 0) {
            [[PFUser currentUser] setObject:facebookId forKey:@"facebookId"];
        }
        

        FBRequest *request = [FBRequest requestForMyFriends];
//        [request setDelegate:self];
        [request startWithCompletionHandler:nil];
        
    }
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Facebook error: %@", error);
    
    if ([PFUser currentUser]) {
        if ([[[[[[[error userInfo] objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectAtIndex:0] objectForKey:@"body"] objectForKey:@"error"] objectForKey:@"type"]
             isEqualToString: @"OAuthException"]) {
            NSLog(@"The facebook token was invalidated");
            [(AMAppDelegate *)[[UIApplication sharedApplication]delegate] logout];
        }
    }
}

#pragma mark load profile image

-(void)loadProfileImage{
    
    NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=320&height=230", [[PFUser currentUser] objectForKey:kFacebookId]]];
    NSLog(@"%@",profilePictureURL);
    NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f]; // Facebook profile picture cache policy: Expires in 2 weeks
       NSURLConnection *theConnection = [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
    if(!theConnection)
        NSLog(@"Connection Failed");
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    
    UIImage *image = [UIImage imageWithData:_data];
    
    UIImage *mediumImage = [image thumbnailImage:105 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    
    UIImage *largeImage = [image resizedImage:CGSizeMake(320, 230) interpolationQuality:kCGInterpolationHigh];
    [[NSUserDefaults standardUserDefaults]setObject:UIImagePNGRepresentation(mediumImage) forKey:kProfileImage_small];
    
    [[NSUserDefaults standardUserDefaults]setObject:UIImagePNGRepresentation(largeImage) forKey:kProfileImage_Big];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    
    PFFile *imageFile = [PFFile fileWithData:UIImagePNGRepresentation(mediumImage)];
    PFFile *largeImageFile = [PFFile fileWithData:UIImagePNGRepresentation(largeImage)];
    [imageFile saveInBackgroundWithBlock:^(BOOL succeed,NSError *error){
        [[PFUser currentUser]setObject:imageFile forKey:@"profileImage"];
        
        [[PFUser currentUser]saveEventually];
        image1Saved = YES;
        [self showTabBarController];
    }];
    [largeImageFile saveInBackgroundWithBlock:^(BOOL success,NSError *error) {
        [[PFUser currentUser]setObject:largeImageFile forKey:kProfileImage_Big];
        [[PFUser currentUser]saveEventually];
        image2Saved = YES;
        [self showTabBarController];
    }];
}
-(void)showTabBarController{
    if(image1Saved && image2Saved && friendsAutofollowed)
    {
        AMAppDelegate *appDelegate = (AMAppDelegate *)[UIApplication sharedApplication].delegate;
        progressHUD.hidden  = YES;
        if(!appDelegate.isTabbarPresented)
            [(AMAppDelegate *)[[UIApplication sharedApplication]delegate] presentTabBarController];
    }
    
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    progressHUD.hidden = YES;
    [AMUtility showAlertwithTitle:@"Error" andMessage:error.localizedDescription];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(textField == username){
        [password becomeFirstResponder];
    }
    else
    {
        [self.view endEditing:YES];
        [self signInButtonAction];
    }
        
    return YES;
}


-(void)setSelectedColorFor:(UIButton *)sender
{
    sender.backgroundColor = [AMUtility getColorwithRed:244 green:244 blue:244];
}
-(void)setUnSelectedColorFor:(UIButton *)sender{
    sender.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
}


- (void)facebookRequestDidLoad:(id)result {
    // This method is called twice - once for the user's /me profile, and a second time when obtaining their friends. We will try and handle both scenarios in a single method.
    
    NSArray *data = [result objectForKey:@"data"];
     if (data) {
         if (![[PFUser currentUser] objectForKey:@"userAlreadyAutoFollowedFacebookFriends"])
         {
             NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:data.count];
             for (NSDictionary *friendData in data) {
                 [facebookIds addObject:[friendData objectForKey:@"id"]];
             }
             //            [self.hud setLabelText:@"Following Friends"];
             
             
             NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
             [dateFormatter setDateFormat:@"MMM dd, yyyy"];
             NSDate *now = [NSDate date];
             NSString *createdString= [dateFormatter stringFromDate:now];
             [[PFUser currentUser] setObject:createdString forKey:kAccountCreatedDate];
             //            [[PFUser currentUser]saveInBackground];
             
             [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"userAlreadyAutoFollowedFacebookFriends"];
             NSError *error = nil;
             
             // find common Facebook friends already using Anypic
             PFQuery *facebookFriendsQuery   = [PFUser query];
             [facebookFriendsQuery whereKey:@"facebookId" containedIn:facebookIds];
             
             NSArray *automooseFriends = [facebookFriendsQuery findObjects:&error];
             
             if (!error) {
                 [automooseFriends enumerateObjectsUsingBlock:^(PFUser *newFriend, NSUInteger idx, BOOL *stop) {
                     PFObject *joinActivity = [PFObject objectWithClassName:@"Activity"];
                     [joinActivity setObject:[PFUser currentUser] forKey:@"fromUser"];
                     [joinActivity setObject:newFriend forKey:@"toUser"];
                     [joinActivity setObject:@"joined" forKey:@"type"];
                     
                     //                    PFACL *joinACL = [PFACL ACL];
                     //                    [joinACL setPublicWriteAccess:YES];
                     //                    joinActivity.ACL = joinACL;
                     [AMUtility followUserInBackground:newFriend block:^(BOOL succeeded, NSError *error) { }];
                 }];
             }
         }
         [[PFUser currentUser]saveInBackgroundWithBlock:^(BOOL succeded, NSError *error){
             [self loadProfileImage];
             Mixpanel *mixpanel = [Mixpanel sharedInstance];
             
             [mixpanel track:kFacebookSignIn properties:@{
                   kUsername: [[PFUser currentUser]objectForKey:kUsername],
              }];
         }];
         friendsAutofollowed = YES;
         [self showTabBarController];
     }
     else {
        NSString *facebookId = [result objectForKey:@"id"];
        NSString *facebookName = [result objectForKey:@"name"];
        if (facebookName && facebookName != 0) {
            [[PFUser currentUser] setObject:facebookName forKey:@"displayName"];
            [[PFUser currentUser] setObject:[facebookName lowercaseString] forKey:kLowerCaseDisplayName];
        }
        else
        {
            [[PFUser currentUser] setObject:@"Someone" forKey:@"displayName"];
            [[PFUser currentUser] setObject:[@"Someone" lowercaseString] forKey:kLowerCaseDisplayName];
        }
        
        if (facebookId && facebookId != 0) {
            [[PFUser currentUser] setObject:facebookId forKey:@"facebookId"];
        }
        
        
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [self facebookRequestDidLoad:result];
            } else {
                [self facebookRequestDidFailWithError:error];
            }
        }];
    }
}

- (void)facebookRequestDidFailWithError:(NSError *)error {
    NSLog(@"Facebook error: %@", error);
    
    if ([PFUser currentUser]) {
        if ([[error userInfo][@"error"][@"type"] isEqualToString:@"OAuthException"]) {
            NSLog(@"The Facebook token was invalidated. Logging out.");
            AMAppDelegate *appDelegate = (AMAppDelegate *) [UIApplication sharedApplication].delegate;
            [appDelegate logout];
        }
    }
}

@end
