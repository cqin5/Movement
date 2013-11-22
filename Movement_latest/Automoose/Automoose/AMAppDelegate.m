//
//  AMAppDelegate.m
//  Automoose
//
//  Created by Srinivas on 12/1/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import "AMAppDelegate.h"
#import "AMAuthenticationViewController.h"
#import "AMNowCommonController.h"
#import "AMProfileCommonController.h"
#import "AMSearchController.h"
#import "AMPlaceViewController.h"
#import "AMAuthenticationViewController.h"
#import "Reachability.h"
#import "MyLogInViewController.h"
#import "MySignUpViewController.h"
#import "AMGlanceEventViewController.h"
#import "AMGlanceViewController.h"
#import "AMUtility.h"
#import "AMConstants.h"
#import "AMProfileCommonController.h"
#import "AMMorePageViewController.h"

#import "LeftController.h"
#import "RightController.h"
#import "AMProfileCommonController.h"
#import "AMTimelineEntity.h"
#import "AMEvent.h"
#import "AMEventObject.h"
#import "MFSideMenu.h"
#import "MBProgressHUD.h"

#import "AMSignUpController.h"
#import "AMLoginViewController.h"

#define MIXPANEL_TOKEN @"6ef730c9ee673fbc83badf109b8a2cbd"

@implementation AMAppDelegate
@synthesize navController;
@synthesize locationManager;
@synthesize timer;
@synthesize badgeNumber;
@synthesize locationTimer;
@synthesize isTabbarPresented;
@synthesize viewController1_navigation,viewController2_navigation,viewController3_navigation,viewController4_navigation,viewController5_navigation;
@synthesize viewController1,viewController2,viewController3,viewController4,viewController5;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//    NSLog(@"LO: %@",launchOptions);
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
    if(launchOptions)
    {
        dataFromNotification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    }
//    [self createDatabaseIfNeeded];
    isTabbarPresented = NO;
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    isTab1Opened = YES;
    [Parse setApplicationId:@"ABV6aEPNtSnEf2Ydog8S5akDT07JXoMGQrlTzbEW" clientKey:@"3TK0VvOKJBMxSdE8pEpIYTMBPEdYr1860TE5YzRc"];
//    [Parse setApplicationId:@"JYS63uT3OCgN3RN2brabaHxCoRn43usqBDyAeLXR" clientKey:@"AWhvehAn7OIT8vEpiM6iNRtAOYU3cqAWOyLjZI04"]; //Frank
//    [PFFacebookUtils initializeWithApplicationId:@"210838455745911"];
    [PFFacebookUtils initializeFacebook];
    
    if (application.applicationIconBadgeNumber != 0)
    {
        application.applicationIconBadgeNumber = 0;
    }
    
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [defaultACL setPublicWriteAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];

    authenticatoinView = [[AMAuthenticationViewController alloc]initWithNibName:@"AMAuthenticationViewController" bundle:nil];
    [authenticatoinView viewDidLoad];
    self.navController = [[UINavigationController alloc]init];
    self.navController.navigationBarHidden = YES;
    
    
    [self.window makeKeyAndVisible];
    pushNotificationPayload = launchOptions;
       if(![PFUser currentUser] )
    {
        [self presentLoginScreen];
    }
    else
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];

        [self presentTabBarController];
       [authenticatoinView retrieveDataofUserifAlreadyLoggedin];
        
   }
    
//    [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.1],
    [[UINavigationBar appearance]setBackgroundImage:[UIImage imageNamed:@"titlebar.png"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance]setShadowImage:[[UIImage alloc] init]];
    
    NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                               [UIColor colorWithRed:55.0/255.0 green:55.0/255.0 blue:55.0/255.0 alpha:1.0],UITextAttributeTextColor,
                                               [UIFont fontWithName:@"MyriadPro-Regular" size:24],UITextAttributeFont,
                                               [NSValue valueWithUIOffset:UIOffsetMake(0, 0)],
                                               UITextAttributeTextShadowOffset,
                                               nil];

    [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
    [[UIBarButtonItem appearance] setTintColor:[UIColor colorWithRed:250.0/255.5 green:250.0/255.5 blue:250.0/255.5 alpha:1.0] ];
    
    
    UIColor *buttonColor = [UIColor blackColor];

    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                buttonColor,UITextAttributeTextColor,
                                [UIFont fontWithName:@"HelveticaNeue-Light" size:13.5],UITextAttributeFont,
                                [NSValue valueWithUIOffset:UIOffsetMake(0, 0)],
                                UITextAttributeTextShadowOffset,
                                
                                nil];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:attributes forState:UIControlStateHighlighted];

    /*
    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
    NSArray *fontNames;
    NSInteger indFamily, indFont;
    for (indFamily=0; indFamily<[familyNames count]; ++indFamily)
    {
        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
        fontNames = [[NSArray alloc] initWithArray:
                     [UIFont fontNamesForFamilyName:
                      [familyNames objectAtIndex:indFamily]]];
        for (indFont=0; indFont<[fontNames count]; ++indFont)
        {
            NSLog(@"    Font name: %@", [fontNames objectAtIndex:indFont]);
        }
    }
    */
    
    return YES;
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    [PFPush storeDeviceToken:newDeviceToken]; // Send parse the device token
    if (application.applicationIconBadgeNumber != 0) {
        application.applicationIconBadgeNumber = 0;
    }
    
//    [[PFInstallation currentInstallation] addUniqueObject:@"" forKey:@"channels"];
    if ([PFUser currentUser]) {
        // Make sure they are subscribed to their private push channel
        NSString *privateChannelName = [[PFUser currentUser] objectForKey:@"channel"];
        if (privateChannelName && privateChannelName.length > 0) {
            [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:@"channels"];
            [[PFInstallation currentInstallation] saveEventually];
        }
    }
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    dataFromNotification = userInfo;
    if ( application.applicationState == UIApplicationStateActive )
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert" message:[[userInfo objectForKey:@"aps"]objectForKey:@"alert"] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"View", nil];
        [alertView show];
    }
    else
    {
        [self fetchEventWithDetails:userInfo];
    }
    
  
}
- (void)createDatabaseIfNeeded {
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"Database.sqlite"];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (!success)
	{
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Database.sqlite"];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
		if (!success) {
			NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		}
	}
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 1){
        [self fetchEventWithDetails:dataFromNotification];
    }
    
    dataFromNotification = nil;
}

-(void)fetchEventWithDetails:(NSDictionary *)userInfo{
    
    AMTimelineEntity *timeLineEntity = [[AMTimelineEntity alloc]init];
    timeLineEntity.eventId = [userInfo objectForKey:kEventId];
    timeLineEntity.activityCreatedDate = [userInfo objectForKey:kCreatedDate];
    timeLineEntity.ownership = @"Participant";
    timeLineEntity.attendanceType = @"Waiting";
    timeLineEntity.activityType2 = @"Created an event at";
    timeLineEntity.ownerObjectId = [userInfo objectForKey:kOwnerObjectId];
    if(!isTabbarPresented)
        [self presentTabBarController];
//    [_menuController setRootController:viewController2_navigation animated:YES];
    NSArray *controllers = [NSArray arrayWithObject:viewController2];
    sideMenu.navigationController.viewControllers = controllers;
    [sideMenu setMenuState:MFSideMenuStateClosed];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"NewInvitationReceived" object:userInfo];
}
- (void)handlePush:(NSDictionary *)launchOptions {
    // If the app was launched in response to a push notification, we'll handle the payload here
//    NSDictionary *remoteNotificationPayload = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
}
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
//    if([PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
//        [self performSelectorInBackground:@selector(performUpdationinBackground) withObject:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
-(void)performUpdationinBackground
{
//    [AMUtility fetchEvents];
//    [AMUtility fetchFriends];
}
/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

-(void)updateUserlocation
{
    [AMUtility saveUsersLocationtoServer];
}

-(void)presentLoginScreen
{
    /*
    MyLogInViewController *logInViewController = [[MyLogInViewController alloc] init];
    [logInViewController setDelegate:authenticatoinView];
    [logInViewController setFacebookPermissions:[NSArray arrayWithObjects:@"friends_about_me", nil]];
    [logInViewController setFields:PFLogInFieldsUsernameAndPassword  | PFLogInFieldsFacebook | PFLogInFieldsSignUpButton | PFLogInFieldsLogInButton ];
    
    MySignUpViewController *signUpViewController = [[MySignUpViewController alloc] init];
    [signUpViewController setDelegate:authenticatoinView];
    [signUpViewController setFields:PFSignUpFieldsDefault ];
    [logInViewController setSignUpController:signUpViewController];
    [authenticatoinView presentViewController:logInViewController animated:NO completion:nil];
*/
    AMLoginViewController *login = [[AMLoginViewController alloc]init];
//    AMSignUpController *signUp = [[AMSignUpController alloc]init];
    isTabbarPresented = NO;
    self.window.rootViewController = login;
}

-(void)presentTabBarController
{
    isTabbarPresented = YES;
    NSLog(@"Before");
    [[PFUser currentUser]refreshInBackgroundWithTarget:nil selector:nil];
    NSLog(@"After");
    [AMUtility initLocationManager];
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert |UIRemoteNotificationTypeSound];
     viewController1 = [[AMNowCommonController alloc] initWithNibName:@"AMNowCommonController" bundle:nil];
    viewController2 = [[AMGlanceViewController alloc] init];
    viewController3 = [[AMSearchController alloc]initWithNibName:@"AMSearchController" bundle:nil];
    viewController4 = [[AMMorePageViewController alloc]init];
    viewController5 = [[AMProfileCommonController alloc]init];
    
    viewController1_navigation = [[UINavigationController alloc]initWithRootViewController:viewController1];
    viewController2_navigation = [[UINavigationController alloc]initWithRootViewController:viewController2];
    viewController3_navigation = [[UINavigationController alloc]initWithRootViewController:viewController3];
    viewController4_navigation = [[UINavigationController alloc]initWithRootViewController:viewController4];
    viewController5_navigation = [[UINavigationController alloc]initWithRootViewController:viewController5];
    
    LeftController *leftController = [[LeftController alloc] init];
    RightController *rightController = [[RightController alloc]init];

    UINavigationController *leftNaviController = [[UINavigationController alloc]initWithRootViewController:leftController];
    
    sideMenu = [MFSideMenu menuWithNavigationController:viewController1_navigation
                                            leftSideMenuController:leftController
                                            rightSideMenuController:rightController];
    leftController.sideMenu = sideMenu;
    rightController.sideMenu = sideMenu;

    self.window.rootViewController = sideMenu.navigationController;
//    if([[NSUserDefaults standardUserDefaults]objectForKey:kAllowLocationTracking])
//    {
//        locationTimer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(updateUserlocation) userInfo:nil repeats:YES];
//        [locationTimer fire];
//    }
    
    [self setInvitationBadgeNumber];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(![userDefaults objectForKey:kIsAppRunningFirstTime])
    {
        [userDefaults setBool:NO forKey:kIsAppRunningFirstTime];
        [userDefaults setBool:YES forKey:kAllowAutoUpdate];
        [userDefaults setBool:YES forKey:kAllowLocationTracking];
        [userDefaults setBool:NO forKey:kDefaultEventSaved];
        [userDefaults synchronize];
    }

    if(dataFromNotification){
        [self fetchEventWithDetails:dataFromNotification];
    }
    
}

-(void)logout
{
    hud = [MBProgressHUD showHUDAddedTo:self.window animated:NO];
    [hud setDimBackground:YES];
    [hud setLabelText:@"Please wait"];
    
    NSString *privateChannelName = [[PFUser currentUser] objectForKey:@"channel"];
    [[PFInstallation currentInstallation]save];
    [[PFInstallation currentInstallation]saveEventually:^(BOOL status, NSError *err){
        if(status) {
            [[PFInstallation currentInstallation]removeObject:privateChannelName forKey:@"channels"];
            [[PFInstallation currentInstallation]saveEventually:^(BOOL success,NSError *error){
                hud.hidden = YES;
                if(success)
                {
                    [PFQuery clearAllCachedResults];
                    [timer invalidate];
                    [locationTimer invalidate];
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    [defaults removeObjectForKey:kDefaultEvent];
                    [defaults removeObjectForKey:kDefaultEventSaved];
                    [defaults removeObjectForKey:kFriends];
                    [defaults removeObjectForKey:kFollowing];
                    [defaults removeObjectForKey:kFollowers];
                    [defaults removeObjectForKey:kFriendTimeLineList];
                    [defaults removeObjectForKey:kCreatedDate];
                    [defaults removeObjectForKey:kEventId];
                    [defaults removeObjectForKey:kEventsList];
                    [defaults removeObjectForKey:kBadgeNumber];
                    [defaults removeObjectForKey:kProfileImage_small];
                    [defaults removeObjectForKey:kBadgeNumber];
                    [defaults removeObjectForKey:kIsAppRunningFirstTime];
                    [defaults removeObjectForKey:kFollowersCount];
                    [defaults removeObjectForKey:kFollowingCount];
                    [defaults removeObjectForKey:kTimeline];
                    [defaults removeObjectForKey:kCoreEventData];
                    [defaults removeObjectForKey:kLastSyncdDate];
                    [defaults removeObjectForKey:kLocationObjectId];
                    [defaults removeObjectForKey:kProfileImage_Big];
                    [PFUser logOut];
                    
                    [[(AMAppDelegate *)[[UIApplication sharedApplication]delegate] navController] popToRootViewControllerAnimated:NO];
                    isTabbarPresented = NO;
                    [(AMAppDelegate *)[[UIApplication sharedApplication]delegate] presentLoginScreen];
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [alertView show];
                }
            }];
        }
        else
        {
            hud.hidden = YES;
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert!" message:err.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alertView show];
        }
    }];
}

-(void)setInvitationBadgeNumber
{
    NSNumber *number = [[NSUserDefaults standardUserDefaults]objectForKey:kBadgeNumber];
    badgeNumber = [number intValue];
    if(badgeNumber)
        [[[[[self tabBarController] tabBar] items] objectAtIndex:3] setBadgeValue:[NSString stringWithFormat:@"%d",badgeNumber]];
    else
        [[[[[self tabBarController] tabBar] items] objectAtIndex:3] setBadgeValue:nil];
    
}
-(void)scheduleLocationUpdate
{
    [locationTimer invalidate];
    locationTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(updateUserlocation) userInfo:nil repeats:YES];
}

// Facebook oauth callback
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [PFFacebookUtils handleOpenURL:url];
}

//-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
//{
//    if(viewController == [tabBarController.viewControllers objectAtIndex:0] && isTab1Opened)
//    {
//        return NO;
//    }
//    else
//        if(viewController == [tabBarController.viewControllers objectAtIndex:1] && isTab2Opened)
//        {
//            return NO;
//        }
//        else
//            if(viewController == [tabBarController.viewControllers objectAtIndex:2] && isTab3Opened)
//            {
//                return NO;
//            }
//            else
//                if(viewController == [tabBarController.viewControllers objectAtIndex:2] && isTab4Opened)
//                {
//                    return NO;
//                }
//    return YES;
//}
//
//- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
//{
//    if([tabBarController selectedIndex]== 0 && !isTab1Opened)
//    {
//        isTab1Opened = YES;
//        isTab2Opened = NO;
//        isTab3Opened = NO;
//        isTab4Opened = NO;
//    }
//    else
//        if([tabBarController selectedIndex]== 1 && !isTab2Opened)
//    {
//        isTab1Opened = NO;
//        isTab2Opened = YES;
//        isTab3Opened = NO;
//        isTab4Opened = NO;
//    }
//        else
//            if([tabBarController selectedIndex]== 2 && !isTab3Opened)
//            {
//                isTab1Opened = NO;
//                isTab2Opened = NO;
//                isTab3Opened = YES;
//                isTab4Opened = NO;
//            }
//            else
//                if([tabBarController selectedIndex]== 3 && !isTab4Opened)
//                {
//                    isTab1Opened = NO;
//                    isTab2Opened = NO;
//                    isTab3Opened = NO;
//                    isTab4Opened = YES;
//                }
//}


@end
