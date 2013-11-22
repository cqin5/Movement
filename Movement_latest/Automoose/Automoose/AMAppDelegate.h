//
//  AMAppDelegate.h
//  Automoose
//
//  Created by Srinivas on 12/1/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"
@class MFSideMenu;
@class DDMenuController;
@class AMAuthenticationViewController;
@interface AMAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate,CLLocationManagerDelegate,UIAlertViewDelegate>

{
    AMAuthenticationViewController *authenticatoinView;
    UINavigationController *viewController1_navigation;
    UINavigationController *viewController2_navigation;
    UINavigationController *viewController3_navigation;
    UINavigationController *viewController4_navigation;
    UINavigationController *viewController5_navigation;
    
    BOOL isTab1Opened;
    BOOL isTab2Opened;
    BOOL isTab3Opened;
    BOOL isTab4Opened;
    NSDictionary *pushNotificationPayload;
    NSTimer *locationTimer;
    MBProgressHUD *hud;
    MFSideMenu *sideMenu;
    NSDictionary *dataFromNotification;
}

@property(nonatomic,strong)    UIViewController *viewController1;
@property(nonatomic,strong)    UIViewController *viewController2;
@property(nonatomic,strong)    UIViewController *viewController3;
@property(nonatomic,strong)    UIViewController *viewController4;
@property(nonatomic,strong)    UIViewController *viewController5;

@property(nonatomic,strong)UINavigationController *viewController1_navigation;
@property(nonatomic,strong)UINavigationController *viewController2_navigation;
@property(nonatomic,strong)UINavigationController *viewController3_navigation;
@property(nonatomic,strong)UINavigationController *viewController4_navigation;
@property(nonatomic,strong)UINavigationController *viewController5_navigation;

@property (strong, nonatomic) DDMenuController *menuController;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (nonatomic, readonly) int networkStatus;
@property (nonatomic, strong) UINavigationController *navController;
@property(nonatomic,strong)CLLocationManager *locationManager;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,assign)int badgeNumber;
@property(nonatomic,strong)NSTimer *locationTimer;;
@property(nonatomic,assign)BOOL isTabbarPresented;
-(void)presentLoginScreen;
-(void)presentTabBarController;
-(void)logout;
-(void)setInvitationBadgeNumber;
-(void)scheduleLocationUpdate;
@end
