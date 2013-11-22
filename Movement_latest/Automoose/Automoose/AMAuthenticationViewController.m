//
//  AMAuthenticationViewController.m
//  Automoose
//
//  Created by Srinivas on 12/2/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import "AMAuthenticationViewController.h"
#import "MyLogInViewController.h"
#import "MySignUpViewController.h"
#import "AMAppDelegate.h"
#import "MBProgressHUD.h"
#import "AMConstants.h"
#import "AMUtility.h"
#import "UIImage+ResizeAdditions.h"

@interface AMAuthenticationViewController ()
{
    NSMutableData *_data;
}
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSTimer *autoFollowTimer;
@end

@implementation AMAuthenticationViewController
@synthesize hud,autoFollowTimer;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        if(isPhone568)
            [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bgLogin-568h.jpg"]]];
        else
            [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bgLogin.jpg"]]];
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    isParseLogin = NO;
//    if([PFUser currentUser])
//    {
//        NSLog(@"Logged in");
//    }
//    else
//    {
//        NSLog(@"Not logged in");
//    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)retrieveDataofUserifAlreadyLoggedin
{
    [self performSelectorInBackground:@selector(performAction) withObject:nil];
}
-(void)performAction {

    if([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {
        FBRequest *request = [FBRequest requestForGraphPath:@"me/?fields=name,email"];
//        [request setDelegate:self];
        [request startWithCompletionHandler:NULL];
    }
//    else
//    {
//        PFFile *
//    }
    
}


#pragma mark - NSURLConnectionDataDelegate

-(void)loadProfileImage{
    if (![[PFUser currentUser] objectForKey:@"userAlreadyAutoFollowedFacebookFriends"])
    {
        NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=320&height=230", [[PFUser currentUser] objectForKey:kFacebookId]]];
        NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f]; // Facebook profile picture cache policy: Expires in 2 weeks
        [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
    }
    else
    {
//        NSLog(@"%@",[PFUser currentUser]);
        PFFile *image  = [[PFUser currentUser]objectForKey:kProfileImage_Big];
        [image getDataInBackgroundWithBlock:^(NSData *data1 ,NSError *error){
            [[NSUserDefaults standardUserDefaults]setObject:data1 forKey:kProfileImage_Big];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }];
    }
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
    }];
    [largeImageFile saveInBackgroundWithBlock:^(BOOL success,NSError *error) {
         [[PFUser currentUser]setObject:largeImageFile forKey:kProfileImage_Big];
         [[PFUser currentUser]saveEventually];
    }];
    
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
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
            [self.hud setLabelText:@"Following Friends"];
           
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"MMM dd, yyyy"];
            NSDate *now = [NSDate date];
            NSString *createdString= [dateFormatter stringFromDate:now];
            [[PFUser currentUser] setObject:createdString forKey:kAccountCreatedDate];
            [[PFUser currentUser]saveInBackground];
            
            [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"userAlreadyAutoFollowedFacebookFriends"];
            NSError *error = nil;
            
            // find common Facebook friends already using Anypic
            PFQuery *facebookFriendsQuery = [PFUser query];
            [facebookFriendsQuery whereKey:@"facebookId" containedIn:facebookIds];
            
            NSArray *automooseFriends = [facebookFriendsQuery findObjects:&error];
            
            if (!error) {
                [automooseFriends enumerateObjectsUsingBlock:^(PFUser *newFriend, NSUInteger idx, BOOL *stop) {
                    PFObject *joinActivity = [PFObject objectWithClassName:@"Activity"];
                    [joinActivity setObject:[PFUser currentUser] forKey:@"fromUser"];
                    [joinActivity setObject:newFriend forKey:@"toUser"];
                    [joinActivity setObject:@"joined" forKey:@"type"];
                    
                    PFACL *joinACL = [PFACL ACL];
                    [joinACL setPublicReadAccess:YES];
                    joinActivity.ACL = joinACL;
                    [AMUtility followUserInBackground:newFriend block:^(BOOL succeeded, NSError *error) { }];
                }];
            }
        }
        
        [[PFUser currentUser] saveInBackground];
        AMAppDelegate *appDelegate = (AMAppDelegate *)[UIApplication sharedApplication].delegate;
        if(!appDelegate.isTabbarPresented)
            [(AMAppDelegate *)[[UIApplication sharedApplication]delegate] presentTabBarController];
        
    } else {
        [self.hud setLabelText:@"Creating Profile"];
        NSString *facebookId = [result objectForKey:@"id"];
        NSString *facebookName = [result objectForKey:@"name"];
//        NSString *urlString = [[[result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];

        if (facebookName && facebookName != 0) {
            [[PFUser currentUser] setObject:facebookName forKey:@"displayName"];
            [[PFUser currentUser] setObject:[facebookName lowercaseString] forKey:kLowerCaseDisplayName];
        }
        
        if (facebookId && facebookId != 0) {
            [[PFUser currentUser] setObject:facebookId forKey:@"facebookId"];
        }
        
        [self loadProfileImage];
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


#pragma mark - PFLogInViewControllerDelegate

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    if (username && password && username.length && password.length) {
        isParseLogin = YES;
        return YES;
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Make sure you fill out all of the information!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
    return NO;
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
  
    if(!isParseLogin)
    {
//        if ([AMUtility userHasValidFacebookData:[PFUser currentUser]])
        {
            FBRequest *request = [FBRequest requestForGraphPath:@"me/?fields=name,picture,email"];
//            [request setDelegate:self];
            [request startWithCompletionHandler:NULL];
        }
    }
    else
    {
        [self loadUserProfileImages];
        /*
        NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"person_big" ofType:@"png" ]];
        [[NSUserDefaults standardUserDefaults]setObject:data forKey:kProfileImage_Big];
        [[NSUserDefaults standardUserDefaults]synchronize];
         */
        
    }
    if (user) {
        NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", [user objectId]];
        [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
        [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:@"channels"];
        [[PFInstallation currentInstallation] saveEventually];
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
        isParseLogin = NO;
        [self dismissViewControllerAnimated:YES completion:NULL];
        [(AMAppDelegate *)[[UIApplication sharedApplication]delegate] presentTabBarController];
    }
    [AMUtility saveUsersLocationtoServer];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - PFSignUpViewControllerDelegate

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    for (id key in info) {
        if(![(NSString *)key isEqualToString:@"additional"])
        {
            NSString *field = [info objectForKey:key];
            if (!field || field.length == 0) {
                informationComplete = NO;
                break;
            }
        }
    }
    
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Missing Information" message:@"Make sure you fill out all of the information!" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil] show];
    }
    
    PFUser *newUser = [PFUser user];

    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self dismissViewControllerAnimated:YES completion:NULL];
    if (user) {
        NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", [user objectId]];
        [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
        [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:@"channels"];
        [[PFInstallation currentInstallation] saveEventually];
        [user setObject:privateChannelName forKey:@"channel"];
        [user setObject:[user objectForKey:@"username"] forKey:kDisplayName];
        [user setObject:[[user objectForKey:kUsername] lowercaseString] forKey:kLowerCaseDisplayName];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MMM dd, yyyy"];
        NSDate *now = [NSDate date];
        NSString *createdString= [dateFormatter stringFromDate:now];
        [user setObject:createdString forKey:kAccountCreatedDate];
        
        [user save];

        NSData *imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"person_icon" ofType:@"png"]];
        NSData *imageDataBig = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"person_big" ofType:@"png"]];
        [[NSUserDefaults standardUserDefaults]setObject:imageData forKey:kProfileImage_small];
        [[NSUserDefaults standardUserDefaults]setObject:imageDataBig forKey:kProfileImage_Big];
        [[NSUserDefaults standardUserDefaults]synchronize];
        PFFile *image = [PFFile fileWithData:imageData];
        PFFile *large_image = [PFFile fileWithData:imageDataBig];
        
        [image saveInBackgroundWithBlock:^(BOOL succeed,NSError *error)
          {
              [user setObject:image forKey:kProfileImage];
              [user saveInBackground];
          }];
        
        [large_image saveInBackgroundWithBlock:^(BOOL succeed , NSError *error)
         {
             [user setObject:large_image forKey:kProfileImage_Big];
             [user saveInBackground];
         }];
        [AMUtility saveUsersLocationtoServer];
        [(AMAppDelegate *)[[UIApplication sharedApplication]delegate] presentTabBarController];
    }
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up...");
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}


@end
