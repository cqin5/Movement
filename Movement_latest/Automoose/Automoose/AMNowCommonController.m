//
//  AMNowCommonController.m
//  Automoose
//
//  Created by Srinivas on 12/2/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import "AMNowCommonController.h"
#import "AMMapViewController.h"
#import "AMUtility.h"
#import "AMEventObject.h"
#import "AMConstants.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "AMGridView.h"
#import "AMProfileViewer.h"
#import "AMProfileViewerCusotmObject.h"
#import "MFSideMenu.h"
#import "AMAppDelegate.h"
#import "NowRingFiller.h"
#import "SSPieProgressView.h"
#define kArrive @"arrive"
#define kEnroute @"enroute"
#import "AMPlaceObject.h"
#import "AMPlaceViewController.h"
#import "AMEventImageViewer.h"
#import "AMCreateEventController.h"
#import "AMProfileViewer.h"
#import "AMPeopleViewer.h"
#define kTimerTime 300
@interface AMNowCommonController ()
{
    PFObject *defaultEvent;
    MBProgressHUD *hud;
    NSArray *peopleArray;
    NSMutableArray *enroutePeopleArray;
    NSMutableArray *arrivedPeopleArray;
    AMGridView *gridView;
    NSString *activeView;
    AMAppDelegate *appDelegate;
    UIButton *refreshButton;
    NSMutableArray *objectIdArray;
    SSPieProgressView *sspieProgress;
    
    UIView *detailBgView;
    
    
    UILabel *nameofTheEvent,*eventType,*placeName,*specifcsLabel,*startingTime,*endingTime,*descriptionLabel,*descriptionValue,*goingCount,*mayBeCount,*goingCellLabel,*mayBeCellLabel;
    UIButton *venueButton,*posterButton,*editButton;
    UIScrollView *goingScrollview,*mayBeScrollview;
    CGFloat heightofDescField;
    UIActivityIndicatorView *goingActivityIndicatorView,*mayBeActivityIndicatorView;
    
    UISegmentedControl *statusControl;
    UILabel *time,*timeLabel;
    NSTimer *timeLeftForEventTimer,*getDefaultEventTimer,*mapSetupTimer;
    CGFloat progress;
    int arrivedCount;
    int enrouteCount;
    BOOL mayBeFetched,goingFetched;
    UIImageView *noEventImageView;
    UIButton *noEventButton;
}
@end

@implementation AMNowCommonController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Now", @"Now");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [AMUtility getColorwithRed:250 green:250 blue:250];
    
    [self setupMenuBarButtonItems];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(notificationReceived) name:@"LoadDefaultNotification" object:nil];
    
    appDelegate = (AMAppDelegate *)[[UIApplication sharedApplication] delegate];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    [hud setDimBackground:YES];
    [hud setLabelText:@"Loading"];
    [self.view bringSubviewToFront:hud];
    [self getDefaultEventandLoad]; //Check for default event.If available load it, else show empty pie.
    [AMUtility fetchFollowing:^(NSError *error){ }]; //Fetch following and followers for caching.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
//    [self.navigationController.navigationBar addSubview:refreshButton];

}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [refreshButton removeFromSuperview];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)setupMenuBarButtonItems {
    switch (self.navigationController.sideMenu.menuState) {
        case MFSideMenuStateClosed:
            if([[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
                self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
            } else {
                self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
            }
//            self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
            self.navigationItem.rightBarButtonItems = [self rightBarButtonItems];

            break;
        case MFSideMenuStateLeftMenuOpen:
            self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
            break;
        case MFSideMenuStateRightMenuOpen:
//            self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
            self.navigationItem.rightBarButtonItems = [self rightBarButtonItems];
            break;
    }
}
- (UIBarButtonItem *)leftMenuBarButtonItem {
    UIButton *leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"left_menu-icon.png"] forState:UIControlStateNormal];
    [leftButton setImage:[UIImage imageNamed:@"left_menu-icon-t.png"] forState:UIControlStateHighlighted];
    [leftButton addTarget:self.navigationController.sideMenu action:@selector(toggleLeftSideMenu) forControlEvents:UIControlEventTouchUpInside];
    leftButton.frame = CGRectMake(0, 0, 40, 40);
    return [[UIBarButtonItem alloc]initWithCustomView:leftButton];
}

- (UIBarButtonItem *)rightMenuBarButtonItem {
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setImage:[UIImage imageNamed:@"right_menu-icon.png"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"right_menu-icon-t.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self.navigationController.sideMenu action:@selector(toggleRightSideMenu) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, 40, 40);
    return [[UIBarButtonItem alloc]initWithCustomView:rightButton];
}

-(NSArray *)rightBarButtonItems{
    UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton setImage:[UIImage imageNamed:@"right_menu-icon.png"] forState:UIControlStateNormal];
    [rightButton setImage:[UIImage imageNamed:@"right_menu-icon-t.png"] forState:UIControlStateHighlighted];
    [rightButton addTarget:self.navigationController.sideMenu action:@selector(toggleRightSideMenu) forControlEvents:UIControlEventTouchUpInside];
    rightButton.frame = CGRectMake(0, 0, 40, 40);
    
    UIButton *rightButton2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [rightButton2 setImage:[UIImage imageNamed:@"right_menu-icon.png"] forState:UIControlStateNormal];
    [rightButton2 setImage:[UIImage imageNamed:@"right_menu-icon-t.png"] forState:UIControlStateHighlighted];
//    [rightButton2 addTarget:self.navigationController.sideMenu action:@selector(toggleRightSideMenu) forControlEvents:UIControlEventTouchUpInside];
    rightButton2.frame = CGRectMake(0, 0, 40, 40);
//    [rightButton2 setTitle:@"Ref" forState:UIControlStateNormal];
    

    
    UIBarButtonItem *button1 = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
//    UIBarButtonItem *button2 = [[UIBarButtonItem alloc]initWithCustomView:rightButton2];
    UIBarButtonItem *button2 = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshButtonTapped)];
    return [NSArray arrayWithObjects:button1,button2,nil];
}

- (UIBarButtonItem *)backBarButtonItem {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow"]
                                            style:UIBarButtonItemStyleBordered
                                           target:self
                                           action:@selector(backButtonPressed:)];
}

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)LogoutTapped
{
    arrivedPeopleArray = nil;
    defaultEvent = nil;
    enroutePeopleArray = nil;
    appDelegate = nil;
    mapViewController = nil;
}
-(void)setRequiredUI
{
    [notesButton.layer setCornerRadius:5];
    [notesButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [notesButton.layer setBorderWidth:1];
    
    [detailsButton.layer setCornerRadius:5];
    [detailsButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [detailsButton.layer setBorderWidth:1];
    
    [timeButton.layer setCornerRadius:5];
    [timeButton.layer setBorderColor:[UIColor blackColor].CGColor];
    [timeButton.layer setBorderWidth:1];
}
/*
-(void)notificationReceived
{
//    if([appDelegate.timer isValid])
        [appDelegate.timer invalidate];
//    if([appDelegate.locationTimer isValid])
        [appDelegate.locationTimer invalidate];
    [self cancelButtonTapped];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    [hud setDimBackground:YES];
    [hud setLabelText:@"Loading"];
    [self.view bringSubviewToFront:hud];
    [self loadDefaultView];
}
*/
-(void)refreshButtonTapped{
    [self getDefaultEventandLoad];
}
/*
-(void)loadDefaultView{
//    if([appDelegate.timer isValid])
        [appDelegate.timer invalidate];
    [appDelegate.timer invalidate];
    if( [[NSUserDefaults standardUserDefaults]boolForKey:kDefaultEventSaved])
    {
        NSString *objectId = [[NSUserDefaults standardUserDefaults]objectForKey:kDefaultEvent];
        PFQuery *query = [PFQuery queryWithClassName:kEventActivity];
        [query whereKey:kToUser equalTo:[PFUser currentUser]];
        [query whereKey:kObjectId equalTo:objectId];
        [query whereKey:kEventActivityType equalTo:kCreated];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
         {
             if(!error && object)
             {
                 defaultEvent = object;
                 appDelegate.timer = [NSTimer scheduledTimerWithTimeInterval:kTimerTime target:self selector:@selector(setUpDetailsofDefaultEvent) userInfo:nil repeats:YES];
                 [appDelegate.timer fire];
              
             }
             else
             {
                 hud.hidden = YES;
                 if(!overlayView)
                 {
                     overlayView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
                     [overlayView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
                 }
                 [overlayView removeFromSuperview];
                 [self.view addSubview:overlayView];
                 [self.view bringSubviewToFront:overlayView];

             }
         }];
        
    }
    else
    {
        PFQuery *query = [PFQuery queryWithClassName:kEventActivity];
        [query whereKey:kToUser equalTo:[PFUser currentUser]];
        [query whereKey:kEventActivityType equalTo:kCreated];
        [query orderByDescending:@"createdAt"];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error)
         {
             if(!error && object)
             {
                 defaultEvent = object;
       
                 appDelegate.timer = [NSTimer scheduledTimerWithTimeInterval:kTimerTime target:self selector:@selector(setUpDetailsofDefaultEvent) userInfo:nil repeats:YES];
                 [appDelegate.timer fire];
             }
             else
             {
                 hud.hidden = YES;
                 if(!overlayView)
                 {
                     overlayView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
                     [overlayView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
                 }
                 [overlayView removeFromSuperview];
                 [self.view addSubview:overlayView];
                 [self.view bringSubviewToFront:overlayView];

             }
         }];
    }
}

-(void)setUpDetailsofDefaultEvent{
    
    if(!defaultEvent)
    {
        [self loadDefaultView];
        return;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
    NSDate *now = [NSDate date];
    NSString *endTime = [defaultEvent objectForKey:kEndingTime];
    if(endTime && ([now compare:[dateFormatter dateFromString:endTime]]  != NSOrderedAscending)) {
//        if([appDelegate.timer isValid])
            [appDelegate.timer invalidate];
//        if([appDelegate.locationTimer isValid])
            [appDelegate.locationTimer invalidate];
        nameoftheEventLabel.text = @"Event tracking has ended.";
        nameoftheEventLabel.numberOfLines = 0;
        locationofEventLabel.text = @"";
        hud.hidden = YES;
        if(!overlayView)
        {
            overlayView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
            [overlayView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
        }
        [overlayView removeFromSuperview];
        [self.view addSubview:overlayView];
        [self.view bringSubviewToFront:overlayView];
        return;
    }
    
    
    if(defaultEvent && defaultEvent != nil && defaultEvent != NULL)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
        NSDate *startingTime1 = [dateFormatter dateFromString:[defaultEvent objectForKey:kStartingTime]];
        NSDate *endingTime1 = [dateFormatter dateFromString:[defaultEvent objectForKey:kEndingTime]];
        NSDate *now = [NSDate date];
        
        NSTimeInterval timeInterval = [now timeIntervalSinceDate:startingTime1];
        int time1 = abs(timeInterval);
        BOOL eventTimeFlag = NO;
        if([startingTime1 compare:now] == NSOrderedAscending && [endingTime1 compare:now] == NSOrderedDescending){
            eventTimeFlag = YES;
        }
        if(!(time1 <= 1800) && !eventTimeFlag)
        {
            NSLog(@"Came");
            nameoftheEventLabel.text = @"Event tracking will begin 30min before the event";
            [nameoftheEventLabel setMinimumScaleFactor:10];
            nameoftheEventLabel.numberOfLines = 0;
            locationofEventLabel.text = @"";
            hud.hidden = YES;
            if(!overlayView)
            {
                overlayView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
                [overlayView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
            }
            [overlayView removeFromSuperview];
            [self.view addSubview:overlayView];
            [self.view bringSubviewToFront:overlayView];
            return;
        }
        [overlayView removeFromSuperview];
    }
    
    
    if([[NSUserDefaults standardUserDefaults]objectForKey:kAllowLocationTracking])
    {
        appDelegate.locationTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerTime target:self selector:@selector(updateUserlocation) userInfo:nil repeats:YES];
        [appDelegate.locationTimer fire];
    }
    
    nameoftheEventLabel.text = [defaultEvent objectForKey:kNameofEvent];;
    NSMutableString *locationString  = [[NSMutableString alloc]initWithString:[[defaultEvent objectForKey:kPlaceDetails ] objectForKey:kName]];
    [locationString appendFormat:@",%@",[[[defaultEvent objectForKey:kPlaceDetails]objectForKey:kLocation] objectForKey:KPlace]];
    locationofEventLabel.text = locationString;
    typeofEvent.text = [defaultEvent objectForKey:kTypeofEvent];
    goingPeopleList.text = @"me and 10 other people are coming";
    notes.text = [defaultEvent objectForKey:kNotes];
    startingTime.text = [defaultEvent objectForKey:kStartingTime];
    endingTime.text = [defaultEvent objectForKey:kEndingTime];
    NSArray *invitees = [defaultEvent objectForKey:kInvitees];
    [invitees enumerateObjectsUsingBlock:^(PFUser *user, NSUInteger index, BOOL *stop){
        [user fetchIfNeeded];
    }];
    
    PFQuery *query = [PFQuery queryWithClassName:@"LocationData"];
    [query whereKey:kFromUser containedIn:invitees];
    [query findObjectsInBackgroundWithBlock:^(NSArray *inviteesArray,NSError *error){
        NSMutableArray *dataArray = [[NSMutableArray alloc]init];
        
        if(!error&&inviteesArray.count)
        {
            for(int i=0;i<invitees.count;i++){
                PFObject *object = [inviteesArray objectAtIndex:i];
                [invitees enumerateObjectsUsingBlock:^(PFUser *user, NSUInteger index, BOOL *stop){
                    if([[user objectId ] isEqualToString:[[object objectForKey:kFromUser] objectId]])
                    {
                        NSDictionary *friend = [NSDictionary dictionaryWithObjectsAndKeys:[user objectForKey:kName], nil];
                        NSDictionary *dict  = [[NSDictionary alloc]initWithObjectsAndKeys:friend,kFriends,[object objectForKey:kLocation],kLocation,kInviteeType,kType, nil];
                        [dataArray addObject:dict];
                        stop = YES;
                    }
                }];
                
            }
            
            if([[defaultEvent objectForKey:kFromUser] isEqual:[PFUser currentUser]])
            {
                NSDictionary *selfDetails = [[NSDictionary alloc]initWithObjectsAndKeys:[[PFUser currentUser]objectForKey:kDisplayName],kDisplayName,[[PFUser currentUser]objectForKey:kChannel],kChannel,[[PFUser currentUser]objectId],kObjectId,[[NSUserDefaults standardUserDefaults]objectForKey:kProfileImage_small],kProfileImage ,[[PFUser currentUser]objectForKey:kFacebookId],kFacebookId, nil];
                NSDictionary *dict  = [[NSDictionary alloc]initWithObjectsAndKeys:selfDetails,kFriends,[AMUtility getUserLocation],kLocation,kInviteeType,kType, nil];
                [dataArray addObject:dict];
            }
            
            float eventLatitude = [[[[defaultEvent objectForKey:kPlaceDetails] objectForKey:kLocation]objectForKey:kLatitude]floatValue ];
            float eventLongitude = [[[[defaultEvent objectForKey:kPlaceDetails] objectForKey:kLocation]objectForKey:kLongitude]floatValue ];
            
            NSDictionary *location = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithFloat:eventLatitude],kLatitude,[NSNumber numberWithFloat:eventLongitude],kLongitude, nil];
            
            NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
            [dictionary setObject:[[defaultEvent objectForKey:kPlaceDetails ] objectForKey:kName] forKey:kName];
            [dictionary setObject:kPlaceType forKey:kType];
            [dictionary setObject:location forKey:kLocation];
            [dataArray addObject:dictionary];
            enrouteCoutLabel.text = @"0";
            arrivedCountLabel.text = @"0";
            [enroutePeopleArray removeAllObjects];
            [arrivedPeopleArray removeAllObjects];
            peopleArray = [NSArray arrayWithArray:dataArray];
            [mapViewController setMapViewtoPointEventLocation:dataArray];
            [hud setHidden:YES];
        }
        else
        {
            [hud setHidden:YES];
        }

        
    }];
}
*/

/*
-(void)updateMapView
{
    [self performSelector:@selector( loadtheDefaultEvent)];
}
 */

/*
-(void)loadtheDefaultEvent
{
    if([[NSUserDefaults standardUserDefaults]boolForKey:kDefaultEventSaved])
    {
        defaultEvent = [AMUtility loadCustomObjectWithKey:kDefaultEvent];
    }
    else
    {
        NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:kEventsList];
        if(data)
        {
            NSArray *events = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            if(events.count){
                AMEventObject *eventObject = [events objectAtIndex:0];
                if(eventObject)
                    defaultEvent = eventObject;
            }
        }
    }

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
    NSDate *now = [NSDate date];
    NSString *endTime = defaultEvent.endingTime;
    if(endTime && ([now compare:[dateFormatter dateFromString:endTime]]  != NSOrderedAscending)) {
        [appDelegate.timer invalidate];
        [appDelegate.locationTimer invalidate];
        nameoftheEventLabel.text = @"Event tracking has ended.";
        nameoftheEventLabel.numberOfLines = 0;
        locationofEventLabel.text = @"";
        hud.hidden = YES;
        if(!overlayView)
        {
            overlayView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
            [overlayView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
        }
        [overlayView removeFromSuperview];
        [self.view addSubview:overlayView];
        [self.view bringSubviewToFront:overlayView];
        return;
    }
    
    
    if(defaultEvent && defaultEvent != nil && defaultEvent != NULL)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
        NSDate *startingTime = [dateFormatter dateFromString:defaultEvent.startingTime];
        NSDate *endingTime = [dateFormatter dateFromString:defaultEvent.endingTime];
        NSDate *now = [NSDate date];
        
        NSTimeInterval timeInterval = [now timeIntervalSinceDate:startingTime];
        int time = abs(timeInterval);
        BOOL eventTimeFlag = NO;
        if([startingTime compare:now] == NSOrderedAscending && [endingTime compare:now] == NSOrderedDescending){
            eventTimeFlag = YES;
        }
        if(!(time <= 1800) && !eventTimeFlag)
        {
            NSLog(@"Came");
            nameoftheEventLabel.text = @"Event tracking will begin 30min before the event";
            [nameoftheEventLabel setMinimumScaleFactor:10];
            nameoftheEventLabel.numberOfLines = 0;
            locationofEventLabel.text = @"";
            hud.hidden = YES;
            if(!overlayView)
            {
                overlayView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
                [overlayView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
            }
            [overlayView removeFromSuperview];
            [self.view addSubview:overlayView];
            [self.view bringSubviewToFront:overlayView];
            return;
        }
         [overlayView removeFromSuperview];
    }
    
    if(defaultEvent && defaultEvent != nil && defaultEvent != NULL)
    {
        
        if([[NSUserDefaults standardUserDefaults]objectForKey:kAllowLocationTracking])
        {
           appDelegate.locationTimer = [NSTimer scheduledTimerWithTimeInterval:300 target:self selector:@selector(updateUserlocation) userInfo:nil repeats:YES];
            [appDelegate.locationTimer fire];
        }
        
        nameoftheEventLabel.text = defaultEvent.nameoftheEvent;
        NSMutableString *locationString  = [[NSMutableString alloc]initWithString:[defaultEvent.placeofEvent objectForKey:kNameofthePlace]];
        [locationString appendFormat:@",%@",[defaultEvent.placeofEvent objectForKey:kAddress]];
        locationofEventLabel.text = locationString;
        typeofEvent.text = defaultEvent.typeofEvent;
        goingPeopleList.text = @"me and 10 other people are coming";
        notes.text = defaultEvent.notes;
        startingTime.text = defaultEvent.startingTime;
        endingTime.text = defaultEvent.endingTime;
        
        if(!objectIdArray)
            objectIdArray = [[NSMutableArray alloc]init];
        [objectIdArray removeAllObjects];
        for(int i=0;i<defaultEvent.invitees.count;i++)
        {
            [objectIdArray addObject:[[defaultEvent.invitees objectAtIndex:i]objectForKey:kObjectId]];
        }
        [objectIdArray addObject:defaultEvent.ownerObjectId];
        PFQuery *query = [PFQuery queryWithClassName:@"LocationData"];
        [query whereKey:kFromUser containedIn:objectIdArray];
        [query findObjectsInBackgroundWithBlock:^(NSArray *inviteesArray,NSError *error)
         {
             NSMutableArray *dataArray = [[NSMutableArray alloc]init];
             
             if(!error&&inviteesArray.count)
             {
                 NSArray *friendsArray = [[NSUserDefaults standardUserDefaults]objectForKey:kFollowing];
                 for(int i=0;i<inviteesArray.count;i++){
                     PFObject *object = [inviteesArray objectAtIndex:i];
                     for(int j=0;j<friendsArray.count;j++) {
                         NSDictionary *friend = [friendsArray objectAtIndex:j];
                         if([[friend objectForKey:kObjectId] isEqualToString:[object objectForKey:kFromUser]]){
                             NSDictionary *dict  = [[NSDictionary alloc]initWithObjectsAndKeys:friend,kFriends,[object objectForKey:kLocation],kLocation,kInviteeType,kType, nil];
                             [dataArray addObject:dict];
                             break;
                         }
                     }
                 }

                 if([defaultEvent.ownerObjectId isEqualToString:[[PFUser currentUser]objectId]] || [objectIdArray containsObject:[[PFUser currentUser]objectId]])
                 {
                     NSDictionary *selfDetails = [[NSDictionary alloc]initWithObjectsAndKeys:[[PFUser currentUser]objectForKey:kDisplayName],kDisplayName,[[PFUser currentUser]objectForKey:kChannel],kChannel,[[PFUser currentUser]objectId],kObjectId,[[NSUserDefaults standardUserDefaults]objectForKey:kProfileImage_small],kProfileImage ,[[PFUser currentUser]objectForKey:kFacebookId],kFacebookId, nil];
                     NSDictionary *dict  = [[NSDictionary alloc]initWithObjectsAndKeys:selfDetails,kFriends,[AMUtility getUserLocation],kLocation,kInviteeType,kType, nil];
                     [dataArray addObject:dict];
                 }
                 
                 float eventLatitude = [[defaultEvent.placeofEvent objectForKey:kLatitude]floatValue];
                 float eventLongitude = [[defaultEvent.placeofEvent objectForKey:kLongitude]floatValue];
                 
                 NSDictionary *location = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithFloat:eventLatitude],kLatitude,[NSNumber numberWithFloat:eventLongitude],kLongitude, nil];
                 
                 NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
                 [dictionary setObject:[defaultEvent.placeofEvent objectForKey:kNameofthePlace] forKey:kName];
                 [dictionary setObject:kPlaceType forKey:kType];
                 [dictionary setObject:location forKey:kLocation];
                 [dataArray addObject:dictionary];
                 enrouteCoutLabel.text = @"0";
                 arrivedCountLabel.text = @"0";
                 [enroutePeopleArray removeAllObjects];
                 [arrivedPeopleArray removeAllObjects];
                 peopleArray = [NSArray arrayWithArray:dataArray];
                 [mapViewController setMapViewtoPointEventLocation:dataArray];
                 [hud setHidden:YES];
             }
                 
            else
            {
                [hud setHidden:YES];
            }
         }];
    }
    else
    {
        if(!overlayView)
        {
            overlayView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
            [overlayView setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.5]];
        }
        [overlayView removeFromSuperview];
        [self.view addSubview:overlayView];
        [self.view bringSubviewToFront:overlayView];
        hud.hidden = YES;
        return;
    }
    [eventDetailsTable reloadData];
}
*/

-(void)updateUserlocation
{
    [AMUtility saveUsersLocationtoServer];
}
-(void)inviteeStatusFromEventLocation:(NSInteger )indexofUser withStatus:(NSString *)status
{
    [arrivedPeopleArray removeAllObjects];
    [enroutePeopleArray removeAllObjects];
    if(!arrivedPeopleArray)
        arrivedPeopleArray = [[NSMutableArray alloc]init];
    if(!enroutePeopleArray)
        enroutePeopleArray = [[NSMutableArray alloc]init];
    
    NSDictionary *dict = [peopleArray objectAtIndex:indexofUser];
    AMProfileViewerCusotmObject *obj = [[AMProfileViewerCusotmObject alloc]init];
    obj.nameofProfile = [[dict objectForKey:kFriends]objectForKey:kDisplayName];
    obj.objectId =[[dict objectForKey:kFriends]objectForKey:kObjectId];
    obj.profileImageData = [[dict objectForKey:kFriends]objectForKey:kProfileImage];
    obj.facebookID = [[dict objectForKey:kFriends]objectForKey:kFacebookId];
    
    if([status isEqualToString:kArrived]){
        [arrivedPeopleArray addObject:obj];
        arrivedCountLabel.text = [NSString stringWithFormat:@"%d",arrivedPeopleArray.count];
    }
    else
    {
        [enroutePeopleArray addObject:obj];
        enrouteCoutLabel.text = [NSString stringWithFormat:@"%d",enroutePeopleArray.count];
    }
//    arrivedPeopleArray.count/peopleArray.count
//    sspieProgress.progress = 0.6;
}
-(IBAction)arrivedButtonTapped:(id)sender
{
    NSLog(@"Arrived Tapped");
    
    if(arrivedPeopleArray.count)
    {
        refreshButton.hidden = YES;
        if(gridView){
            for(UIView *view in [gridView subviews])
            {
                [view removeFromSuperview];
            }
            gridView = nil;
        }
        gridView = [[AMGridView alloc]initWithFrame:CGRectMake(0, kScreenHeight, 320, kScreenHeight - 90 - 44 - 15) andWithPeopleData:arrivedPeopleArray];
        gridView.gridViewDelegate = self;
        self.title = @"Arrived";
        activeView = kArrive;
        eventDetailsTable.frame = CGRectMake(0, kScreenHeight, 320, kScreenHeight - 230-44);
        topView.frame = CGRectMake(0, -400, 320, 150);

//        [mapViewController.view removeFromSuperview];
//        [notesView removeFromSuperview];
//        if(![self.view.subviews containsObject:notesView])
//            [notesView removeFromSuperview];
        [eventNameView setHidden:YES];
        [self.view addSubview:gridView];
        
        NSTimeInterval animationDuration = 0.5;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        eventDetailsTable.frame = CGRectMake(0, kScreenHeight, 320, kScreenHeight - 230-44);
        topView.frame = CGRectMake(0, -400, 320, 150);
        gridView.frame = CGRectMake(0, 0, 320, kScreenHeight-44-15);
        [self.view addSubview:cancelButton];
        [UIView commitAnimations];
        arrivedButton.enabled = NO;
    }
}
-(IBAction)enrouteButtonTapped:(id)sender
{
    NSLog(@"Enroute Tapped:");
    if(enroutePeopleArray.count)
    {
        refreshButton.hidden = YES;
        if(gridView){
            for(UIView *view in [gridView subviews])
            {
                [view removeFromSuperview];
            }
            gridView = nil;
        }
        self.title = @"Enroute";
      

//        [mapViewController.view removeFromSuperview];
//        if(![self.view.subviews containsObject:notesView])
//        [notesView removeFromSuperview];
        [eventNameView setHidden:YES];
        [participantCountView setHidden:YES];
        gridView = [[AMGridView alloc]initWithFrame:CGRectMake(0, kScreenHeight, 320, kScreenHeight  -44 -15) andWithPeopleData:enroutePeopleArray];
        gridView.gridViewDelegate = self;
        activeView = kEnroute;
        [self.view addSubview:gridView];
        
        NSTimeInterval animationDuration = 0.5;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        eventDetailsTable.frame = CGRectMake(0, kScreenHeight, 320, kScreenHeight - 230-44);
        topView.frame = CGRectMake(0, -400, 320, 150);
        gridView.frame = CGRectMake(0, 0, 320, kScreenHeight-44-15);
        [self.view addSubview:cancelButton];
        [UIView commitAnimations];
        enrouteButton.enabled = NO;
    }
}

-(IBAction)notesButtonTapped:(id)sender
{
//    if(![self.view.subviews containsObject:gridView])
    {
        if(gridView)
        {
            [gridView removeFromSuperview];
            gridView = nil;
        }
    }
    notesView.text = [defaultEvent objectForKey:kNotes]?[defaultEvent objectForKey:kNotes]:@"";
    [eventNameView setHidden:YES];
    [mapViewController.view removeFromSuperview];
    [self.view addSubview:notesView];
    [self.view addSubview:cancelButton];
}

-(IBAction)detailsButtonTapped:(id)sender
{
   
}

-(IBAction)timeButtonTapped:(id)sender
{
   
}

-(void)showMapView
{
    if(![participantCountView isHidden])
    {
        [participantCountView setHidden:YES];
        [eventNameView setHidden:YES];
    }
   
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:animationDuration];
    [UIView animateWithDuration:0.4 animations:^(void){
        topView.frame = CGRectMake(0, -140, 320, 165);
    } completion:^(BOOL finished){
        
//        [UIView animateWithDuration:0.1 animations:^(void){
//            topView.frame = CGRectMake(0, -350, 320, 150);
//        }];
        sspieProgress.hidden = YES;
        [cancelButton setHidden:NO];
        [topView bringSubviewToFront:cancelButton];
    }];
    
    [UIView animateWithDuration:0.3 animations:^(void){
        eventDetailsTable.frame = CGRectMake(0, kScreenHeight, 320, kScreenHeight - 230-44);

    } completion:^(BOOL finished){
        [cancelButton setHidden:NO];
    }];
   
  
//    [UIView commitAnimations];

   
}

-(void)cancelButtonTapped
{
    refreshButton.hidden = NO;
    self.title = @"Now";
//    [cancelButton removeFromSuperview];
//    if(![self.view.subviews containsObject:notesView])
//        [notesView removeFromSuperview];
//    if(![self.view.subviews containsObject:mapViewController.view])
//        [self.view addSubview:mapViewController.view];
    if([self.view.subviews containsObject:gridView])
    {
        [gridView removeFromSuperview];
        gridView = nil;
    }
    enrouteButton.enabled = YES;
    arrivedButton.enabled = YES;
    if([participantCountView isHidden])
        [participantCountView setHidden:NO];
    if([eventNameView isHidden])
        [eventNameView setHidden:NO];
//    [self.view bringSubviewToFront:participantCountView];
//    [self.view bringSubviewToFront:eventNameView];
    NSTimeInterval animationDuration = 0.5;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
//    [cancelButton removeFromSuperview];
    cancelButton.hidden = YES;
    sspieProgress.hidden = NO;
    eventDetailsTable.frame = CGRectMake(0, 230, 320, kScreenHeight - 230-44);
    topView.frame = CGRectMake(0, 0, 320, 165);
    [UIView commitAnimations];
    activeView = @"";
}

-(void)tappedonGridCellWithIndex:(int )index
{
    refreshButton.hidden = YES;
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    [hud setDimBackground:YES];
    [hud setLabelText:@"Loading"];
    AMProfileViewer *profileViewer = [[AMProfileViewer alloc]init];
    
    AMProfileViewerCusotmObject *obj;
    if([activeView isEqualToString:kEnroute])
         obj = [enroutePeopleArray objectAtIndex:index];
    else
        obj = [arrivedPeopleArray objectAtIndex:index];
    
    for(int i=0;i<peopleArray.count;i++){
        NSDictionary *data = [peopleArray objectAtIndex:i];
        NSDictionary *personData = [data objectForKey:kFriends];
        if([[personData objectForKey:kObjectId] isEqualToString:obj.objectId]){
//            obj = [AMUtility fetchTimelineofUserwithData:personData];
            [AMUtility fetchTimelineofUserwithData:personData block:^(BOOL success,NSError *error,AMProfileViewerCusotmObject *object)
             {
                 [self.navigationController pushViewController:profileViewer animated:YES];
                 profileViewer.dataArray = object.eventTimelineArray;
                 profileViewer.imageview.image = [UIImage imageWithData:object.profileImageData];
                 profileViewer.name.text = object.nameofProfile;
                 profileViewer.followingCount.text = object.followingCount;
                 profileViewer.followersCount.text = object.follwersCount;
                 profileViewer.eventsCount.text = object.eventsCount;
                 profileViewer.facebookID = object.facebookID;
                 [hud setHidden:YES];
             }];
                        break;
        }
    }
}
-(UILabel *)getUIlabelwithRegularFont
{
    UILabel *returnLabel = [[UILabel alloc]init];
    returnLabel.backgroundColor = [UIColor clearColor];
    returnLabel.textColor = [AMUtility getColorwithRed:27 green:27 blue:27];
    returnLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15];
    return returnLabel;
}

-(UILabel *)getUIlabelwithRegularFontwithBlackColor
{
    UILabel *returnLabel = [[UILabel alloc]init];
    returnLabel.backgroundColor = [UIColor clearColor];
    returnLabel.textColor = [AMUtility getColorwithRed:27 green:27 blue:27];
    returnLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    return returnLabel;
}
-(UILabel *)getUIlabelwithRegularFontwithSize20
{
    UILabel *returnLabel = [[UILabel alloc]init];
    returnLabel.backgroundColor = [UIColor clearColor];
    returnLabel.textColor = [AMUtility getColorwithRed:27 green:27 blue:27];
    returnLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
    return returnLabel;
}


-(UILabel *)getUILabelwithBoldFont {
    UILabel *returnLabel = [[UILabel alloc]init];
    returnLabel.backgroundColor = [UIColor clearColor];
    returnLabel.textColor = [UIColor darkGrayColor];
    returnLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:15];
    return returnLabel;
}


#pragma mark new methods
-(void)getDefaultEventandLoad{
//    if([mapSetupTimer isValid])
        [mapSetupTimer invalidate];
//    if([timeLeftForEventTimer isValid])
        [timeLeftForEventTimer invalidate];
//    if([getDefaultEventTimer isValid])
        [getDefaultEventTimer invalidate];
    PFQuery *query  = [self queryForDefaultEvent]; //Retrieve default event
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object,NSError *err){
        if(!err)
        {
            defaultEvent = object;
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
            NSDate *now = [NSDate date];
            NSDate *startingTime1 = [dateFormatter dateFromString:[defaultEvent objectForKey:kStartingTime]];
            NSDate *endingTime1 = [dateFormatter dateFromString:[defaultEvent objectForKey:kEndingTime]];
            NSString *endTime = [defaultEvent objectForKey:kEndingTime];
            
            NSTimeInterval timeInterval = [now timeIntervalSinceDate:startingTime1];
            int timeVal = abs(timeInterval);
            BOOL eventTimeFlag = NO;
            if([startingTime1 compare:now] == NSOrderedAscending && [endingTime1 compare:now] == NSOrderedDescending){
                eventTimeFlag = YES;
            }
//            if([getDefaultEventTimer isValid])
                [getDefaultEventTimer invalidate];
            [getDefaultEventTimer invalidate];
            if(endTime && ([now compare:[dateFormatter dateFromString:endTime]]  != NSOrderedAscending)) { //Checking received event's end time. 
                
                [self showNoEventAlert];
                NSLog(@"No event to track");
                getDefaultEventTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerTime target:self selector:@selector(getDefaultEventandLoad) userInfo:nil repeats:YES];
                [getDefaultEventTimer fire];
            }
            else if(!(timeVal <= 7200) && !eventTimeFlag) // Checking time remaining to start the event.
            {
                [self showNoEventAlert];
                NSLog(@"Event tracking will begin 2 hours before the event");
                getDefaultEventTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerTime target:self selector:@selector(getDefaultEventandLoad) userInfo:nil repeats:YES];
//                [getDefaultEventTimer fire];
            }
            else
            {
                //Load required views: top view-pie chart and lables, botton view - table view
                
                if([self.view.subviews containsObject:noEventButton])
                    [noEventButton removeFromSuperview];
                if([self.view.subviews containsObject:noEventImageView])
                    [noEventImageView removeFromSuperview];
//                if([getDefaultEventTimer isValid])
                    [getDefaultEventTimer invalidate];
                [self getGoingPeopleData];
                [self getMayBePeopleData];
                [self setUpView];
                [eventDetailsTable reloadData];
                
                //Set up timers to check for remaining time to start the event and reload mapview with attendees locatoin periodically.
                timeLeftForEventTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerTime target:self selector:@selector(updateTimeLeftForEvent) userInfo:nil repeats:YES];
                [timeLeftForEventTimer fire];
                
                mapSetupTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerTime target:self selector:@selector(setUpMapView) userInfo:nil repeats:YES];
                [mapSetupTimer fire];
            }
            
            hud.hidden = YES;
        }
        else
        {
            hud.hidden = YES;

            [self showNoEventAlert];//Method to show no event(empty pie) on the screen.
            NSLog(@"No events to show");
        }
    }];
}

-(PFQuery *)queryForDefaultEvent{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
    NSDate *now = [NSDate date];
    
    PFQuery *query = [PFQuery queryWithClassName:kEventActivity];
    [query whereKey:kToUser equalTo:[PFUser currentUser]];
    [query whereKey:kAttendanceType containedIn:[NSArray arrayWithObjects:kGoing,kMaybe, nil]];
    [query orderByAscending:kStartingTime];
    [query whereKey:kEndingTime greaterThan:[dateFormatter stringFromDate:now]];
    return query;
}

-(void)setUpView{
    [self clearScreen];
    
    
    topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 165)];
    topView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"upperglass.png"]];
    
    sspieProgress = [[SSPieProgressView alloc]initWithFrame:CGRectMake(38, 0, 155, 155)];
    sspieProgress.progress = 0.8;
    [topView addSubview:sspieProgress];
    
    enrouteCoutLabel=   [self getUIlabelwithRegularFontwithSize20];
    enrouteCoutLabel.textAlignment = NSTextAlignmentRight;
    enrouteCoutLabel.frame = CGRectMake(229, 30, 50, 30);
    enrouteCoutLabel.text = @"0";

    arrivedCountLabel = [self getUIlabelwithRegularFontwithSize20];
    arrivedCountLabel.textAlignment = NSTextAlignmentRight;
    arrivedCountLabel.frame = CGRectMake(220, 93, 49, 20);
    arrivedCountLabel.text = @"0";

    UILabel *enrouteLabel = [self getUIlabelwithRegularFontwithBlackColor];
    UILabel *arrivedLabel = [self getUIlabelwithRegularFontwithBlackColor];
    
    enrouteLabel.frame = CGRectMake(280, 20, 50, 45);
    enrouteLabel.text = @"en route";
    enrouteLabel.numberOfLines = 0;
    
    arrivedLabel.frame = CGRectMake(270, 80, 65, 45);
    arrivedLabel.text=@"arrived";
    
    enrouteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    enrouteButton.frame = CGRectMake(264, 63, 50, 45);
    [topView insertSubview:enrouteButton aboveSubview:enrouteCoutLabel];
    [enrouteButton addTarget:self action:@selector(enrouteButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    arrivedButton = [UIButton buttonWithType:UIButtonTypeCustom];
    arrivedButton.frame = CGRectMake(57, 96, 50, 50);
    [topView insertSubview:arrivedButton aboveSubview:arrivedCountLabel];
    [topView bringSubviewToFront:arrivedButton];
    [arrivedButton addTarget:self action:@selector(arrivedButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    NowRingFiller *nowFillerRing = [[NowRingFiller alloc]initWithFrame:CGRectMake(30, 30, 95, 95)];
    nowFillerRing.backgroundColor = [UIColor clearColor];
    [sspieProgress addSubview: nowFillerRing];
    
    time = [self getUIlabelwithRegularFontwithBlackColor];
    timeLabel = [self getUIlabelwithRegularFontwithBlackColor];
    
    time.font =   [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:38];
    timeLabel.font =   [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    
    time.frame = CGRectMake(38, 50, 80, 40);
    timeLabel.frame = CGRectMake(47, 78, 60, 36);
    
    timeLabel.textAlignment = NSTextAlignmentCenter;
    time.textAlignment = NSTextAlignmentCenter;
    
    [sspieProgress addSubview:timeLabel];
    [sspieProgress addSubview:time];
    
    time.text =@"45";
    timeLabel.text= @"mins";

    [topView addSubview:enrouteLabel];
    [topView insertSubview:arrivedLabel aboveSubview:sspieProgress];
    [topView addSubview:enrouteCoutLabel];
    [topView insertSubview:arrivedCountLabel aboveSubview:sspieProgress];
    
    
    nameoftheEventLabel = [self getUILabelwithBoldFont];
    locationofEventLabel = [self getUIlabelwithRegularFont];
    addressLabel = [self getUIlabelwithRegularFont];
    typeofEvent = [self getUIlabelwithRegularFont];
    goingPeopleList = [self getUIlabelwithRegularFont];
    startingTime = [self getUIlabelwithRegularFont];
    endingTime = [self getUIlabelwithRegularFont];
    notes = [[UITextView alloc]init];
    notes.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15];
    notes.textColor = [UIColor lightGrayColor];
    notes.editable = NO;
    notes.backgroundColor = [UIColor clearColor];
    
    detailBgView = [[UIView alloc]init];
    detailBgView.frame  =CGRectMake(0, 230, 320, kScreenHeight - 230-44);
    detailBgView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"glasslower.png"]];
    
    eventDetailsTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 210, 320, kScreenHeight - 230-44) style:UITableViewStylePlain];
    eventDetailsTable.delegate = self;
    eventDetailsTable.dataSource = self;
    eventDetailsTable.backgroundColor = [UIColor clearColor];

    UIImageView *bgView = [[UIImageView alloc]initWithImage:[[UIImage imageNamed:@"glasslower.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(00, 0, 10, 10)]];

    eventDetailsTable.backgroundView = bgView;
    
    arrivedPeopleArray = [[NSMutableArray alloc]init];
    enroutePeopleArray = [[NSMutableArray alloc]init];
    
    refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
    refreshButton.frame = CGRectMake(320-100-20, 5, 60, 34);
    
    [refreshButton addTarget:self action:@selector(setUpDetailsofDefaultEvent) forControlEvents:UIControlEventTouchUpInside];
    
    CGSize viewSize = [[UIScreen mainScreen] bounds].size;
    
    mapViewController = [[AMMapViewController alloc]init];
    mapViewController.view.frame = CGRectMake(0, 0, 320, viewSize.height);
    mapViewController.delegate = self;
    [self.view addSubview:mapViewController.view];
    [self.view insertSubview:topView aboveSubview:mapViewController.view];
    [self.view insertSubview:eventDetailsTable aboveSubview:mapViewController.view];
//    [detailBgView addSubview:eventDetailsTable];
    
    cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelButton.frame = CGRectMake((kScreenWidth/2) - 14.5 , 0, 40, 40);
    [cancelButton setImage:[UIImage imageNamed:@"drag.png"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    cancelButton.frame = CGRectMake(95, 139, 44, 44);
    [topView addSubview:cancelButton];
    cancelButton.hidden = YES;
    
    notesView = [[UITextView alloc]initWithFrame:CGRectMake(10, 10, 300, 250)];
    [notesView.layer setCornerRadius:5.0f];
    [notesView.layer setBorderColor:[UIColor blackColor].CGColor];
    [notesView.layer setBorderWidth:1.0f];
    [notesView setEditable:NO];
    
    participantCountView.frame = CGRectMake(0, viewSize.height - 155, 321, 90);
    eventNameView.frame = CGRectMake(0, viewSize.height - 86-155, 335, 86);
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    [hud setDimBackground:YES];
    [hud setLabelText:@"Loading"];
    [self setRequiredUI];
    
    eventDetailsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    nameofTheEvent = [self getLabel];
    eventType = [self getLabel];
    placeName = [self getLabel];
    specifcsLabel = [self getLabel];
    startingTime = [self getLabel];
    endingTime = [self getLabel];
    descriptionLabel = [self getLabel];
    descriptionValue = [self getLabel];
    goingCount = [self getLabel];
    mayBeCount = [self getLabel];
    goingCellLabel = [self getLabel];
    mayBeCellLabel = [self getLabel];
    
    venueButton = [self getButton];
    posterButton = [self getButton];
    editButton = [self getButton];
    [venueButton setTitle:@"Venue" forState:UIControlStateNormal];
    [posterButton setTitle:@"Poster" forState:UIControlStateNormal];
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    
    [venueButton addTarget:self action:@selector(venueButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [posterButton addTarget:self action:@selector(posterButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [editButton addTarget:self action:@selector(editButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    NSArray *itemArray = [NSArray arrayWithObjects: @"Going", @"May be", @"Not going", nil];
    statusControl = [[UISegmentedControl alloc]initWithItems:itemArray];
    statusControl.frame = CGRectMake(10, 5, 290, 30);
    statusControl.segmentedControlStyle =  UISegmentedControlStyleBar;
    statusControl.selectedSegmentIndex = 0;
    [statusControl addTarget:self action:@selector(statusControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIImage *unselectedBackgroundImage = [[UIImage imageNamed:@"unselectedBg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [statusControl setBackgroundImage:unselectedBackgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    UIImage *selectedBackgroundImage = [[UIImage imageNamed:@"selectedBg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [statusControl setBackgroundImage:selectedBackgroundImage forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    UIColor *buttonColor = [UIColor blackColor];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                buttonColor,UITextAttributeTextColor,
                                [UIFont fontWithName:@"HelveticaNeue-Light" size:13],UITextAttributeFont,
                                nil];
    
    [statusControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    UIImage *divider1 = [[UIImage imageNamed:@"right_selected_divider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [statusControl setDividerImage:divider1 forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    UIImage *divider2 = [[UIImage imageNamed:@"left_selected_divider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [statusControl setDividerImage:divider2 forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [statusControl setDividerImage:[UIImage imageNamed:@"unselectedDividerBg.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    eventType.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12.5];
    eventType.textColor = [AMUtility getColorwithRed:106 green:106 blue:106];
    
    nameofTheEvent.numberOfLines = 0;
    nameofTheEvent.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    nameofTheEvent.textColor = [UIColor blackColor];
    
    placeName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    placeName.textColor = [UIColor blackColor];
    
    specifcsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    specifcsLabel.textColor = [UIColor blackColor];
    
    startingTime.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    startingTime.textColor = [UIColor blackColor];
    
    endingTime.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    endingTime.textColor = [UIColor blackColor];
    
    descriptionValue.font = [UIFont fontWithName:@"MyriadPro-Regular" size:14];
    descriptionLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12.5];
    descriptionLabel.textColor = [UIColor blackColor];
    descriptionValue.textColor = [UIColor blackColor];
    descriptionValue.numberOfLines = 5;
    descriptionLabel.textColor = [AMUtility getColorwithRed:106 green:106 blue:106];
    
    goingCount.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12.5];
    goingCount.textColor = [AMUtility getColorwithRed:106 green:106 blue:106];
    
    mayBeCount.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12.5];
    mayBeCount.textColor = [AMUtility getColorwithRed:106 green:106 blue:106];
    
    goingCellLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:20];
    goingCellLabel.numberOfLines = 0;
    
    descriptionLabel.text=@"Description";
    goingCount.text=@"Going (0)";
    mayBeCount.text =@"MayBe (0)";
    if(defaultEvent)
        self.title = [defaultEvent objectForKey:kNameofEvent];
    goingActivityIndicatorView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(130, 35, 30, 30)];
    goingActivityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    goingActivityIndicatorView.hidesWhenStopped = YES;
    
    mayBeActivityIndicatorView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(130, 50, 30, 30)];
    mayBeActivityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    mayBeActivityIndicatorView.hidesWhenStopped = YES;
    
    goingScrollview = [[UIScrollView alloc]init];
    goingScrollview.scrollEnabled = NO;
    
    mayBeScrollview = [[UIScrollView alloc]init];
    mayBeScrollview.scrollEnabled = NO;
    
    [goingActivityIndicatorView startAnimating];
    [mayBeActivityIndicatorView startAnimating];
    
    if(defaultEvent)
    {
        BOOL isParticipant = [[[defaultEvent objectForKey:kToUser] objectId] isEqualToString:[[PFUser currentUser] objectId]];
        if(isParticipant)
        {
            if([[defaultEvent objectForKey:kAttendanceType] isEqualToString:kGoing])
                [statusControl setSelectedSegmentIndex:0];
            else if ([[defaultEvent objectForKey:kAttendanceType] isEqualToString:kMaybe])
                [statusControl setSelectedSegmentIndex:1];
            else if ([[defaultEvent objectForKey:kAttendanceType] isEqualToString:kNotGoing])
                [statusControl setSelectedSegmentIndex:2];
            else
                [statusControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
        }
       
    }
   [topView bringSubviewToFront:cancelButton];
    
}

-(UIButton *)getButton{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button.layer setBorderWidth:0.5];
    UIColor *buttonColor = [AMUtility getColorwithRed:154 green:154 blue:154];
    [button.layer setBorderColor:buttonColor.CGColor];
    [button setBackgroundColor:[AMUtility getColorwithRed:249 green:249 blue:249]];
    [button.layer setCornerRadius:6];
    [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
    [button setTitleColor:[AMUtility getColorwithRed:67 green:67 blue:67] forState:UIControlStateNormal];
    [button setTitleColor:[AMUtility getColorwithRed:246 green:246 blue:246] forState:UIControlStateHighlighted];
    [button setShowsTouchWhenHighlighted:YES];
    return button;
}
-(UILabel *)getLabel{
    UILabel *label = [[UILabel alloc]init];
    label.backgroundColor = [UIColor clearColor];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:15.0]];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [AMUtility getColorwithRed:94 green:94 blue:94];
    return label;
}

#pragma mark table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if(defaultEvent)
        return 1;
    return 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(defaultEvent)
    {
        NSString * description = [defaultEvent objectForKey:kNotes];
        BOOL isParticipant = [[[defaultEvent objectForKey:kToUser] objectId] isEqualToString:[[PFUser currentUser] objectId]];
        
        if(!description.length)
        {
            UIFont *font = [UIFont fontWithName:@"MyriadPro-Regular" size:14];
            CGSize maxSize = CGSizeMake(300, 999);
            CGSize newSize = [description sizeWithFont:font constrainedToSize:maxSize lineBreakMode:UIViewAutoresizingFlexibleHeight];
            heightofDescField = newSize.height;
            if(isParticipant)
                return 7;
            return 6;
        }
        if(isParticipant)
            return 8;
        return 7;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isParticipant = [[[defaultEvent objectForKey:kToUser] objectId] isEqualToString:[[PFUser currentUser] objectId]];
    NSString * description = [defaultEvent objectForKey:kNotes];
    UIFont *font = [UIFont fontWithName:@"MyriadPro-Regular" size:14];
    CGSize maxSize = CGSizeMake(300, 999);
    CGSize newSize = [description sizeWithFont:font constrainedToSize:maxSize lineBreakMode:UIViewAutoresizingFlexibleHeight];
    heightofDescField = newSize.height;
    if(description.length)
    {
        switch (indexPath.row) {
            case 0:
                return 70;
                break;
            case 1:
                return 44;
            case 2:
                return 44;
            case 3:
                return 50;
            case 4:
                if(isParticipant)
                    return 44;
                return 49+heightofDescField;
            case 5:
                if(isParticipant)
                    return 49+heightofDescField;
                return 100;
            case 6:
                if(isParticipant)
                    return 100;
                return 120;
            case 7:
                return 120;
            default:
                break;
        }
    }
    else
    {
        switch (indexPath.row) {
            case 0:
                return 70;
                break;
            case 1:
                return 44;
            case 2:
                return 44;
            case 3:
                return 50;
                //            case 4:
                //                return 130;
            case 4:
                if(isParticipant)
                    return 44;
                return 100;
            case 5:
                if(isParticipant)
                    return 100;
                return 120;
            case 6:
                return 120;
            default:
                break;
        }
        
    }
    return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
    UIImageView *placeIcon, *timeIcon,*lineView1,*lineView2,*lineView3;
    UIButton *moreNotesButton,*moreGoingButton, *moreMayBeButton;
    if(cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        placeIcon =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"location.png"]];
        timeIcon =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"clock.png"]];
        
        moreNotesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreNotesButton setBackgroundImage:[UIImage imageNamed:@"morebutton.png"] forState:UIControlStateNormal];
        [moreNotesButton setBackgroundImage:[UIImage imageNamed:@"morebutton-t.png"] forState:UIControlStateHighlighted];
        
        moreGoingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreGoingButton setBackgroundImage:[UIImage imageNamed:@"morebutton.png"] forState:UIControlStateNormal];
        [moreGoingButton setBackgroundImage:[UIImage imageNamed:@"morebutton-t.png"] forState:UIControlStateHighlighted];
        [moreGoingButton addTarget:self action:@selector(moreGoingButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        moreMayBeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreMayBeButton setBackgroundImage:[UIImage imageNamed:@"morebutton.png"] forState:UIControlStateNormal];
        [moreMayBeButton setBackgroundImage:[UIImage imageNamed:@"morebutton-t.png"] forState:UIControlStateHighlighted];
        [moreMayBeButton addTarget:self action:@selector(moreMayBeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        lineView1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"horizontal.png"]];
        lineView2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"horizontal.png"]];
        lineView3 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"horizontal.png"]];
    }
    [cell.contentView.subviews enumerateObjectsUsingBlock:^(UIView *view,NSUInteger integer,BOOL *stop){
        [view removeFromSuperview];
    }];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CGRect frame = cell.contentView.frame;
    eventType.frame = CGRectMake(10, 5, 200, 20);
    nameofTheEvent.frame = CGRectMake(10, 20, frame.size.width, 50);
    
    placeIcon.frame = CGRectMake(10, 8, 15, 15);
    placeName.frame = CGRectMake(30, 5, frame.size.width - 30, 20);
    specifcsLabel.frame = CGRectMake(30, 25, frame.size.width - 30, 20);
    
    timeIcon.frame = CGRectMake(10, 8, 15, 15);
    startingTime.frame = CGRectMake(30, 5, frame.size.width - 30, 20);
    endingTime.frame = CGRectMake(30, 25, frame.size.width - 30, 20);
    
    UIFont *font = [UIFont fontWithName:@"MyriadPro-Regular" size:14];
    CGSize maxSize = CGSizeMake(300, 999);
    CGSize newSize = [[defaultEvent objectForKey:kNotes] sizeWithFont:font constrainedToSize:maxSize lineBreakMode:UIViewAutoresizingFlexibleHeight];
    heightofDescField = newSize.height;
    
    descriptionLabel.frame = CGRectMake(10, 5, 100, 16);
    descriptionValue.frame = CGRectMake(10, 25, 300, heightofDescField);
    moreNotesButton.frame = CGRectMake(270, 13+heightofDescField, 45, 35);
    lineView2.frame = CGRectMake(10, moreNotesButton.frame.origin.y+29, 300, 1);
    
    venueButton.frame = CGRectMake(10, 7, 90, 30);
    posterButton.frame = CGRectMake(10+100, 7, 90, 30);
    editButton.frame = CGRectMake(10+100+100, 7, 90, 30);
    lineView1.frame = CGRectMake(10, 45, 300, 1);
    
    lineView3.frame = CGRectMake(10, 45, 300, 1);
    
    goingCount.frame = CGRectMake(10, 5, 100, 20);
    moreGoingButton.frame = CGRectMake(270, 80, 45, 35);
    
    mayBeCount.frame = CGRectMake(10, 5, 100, 20);
    moreMayBeButton.frame = CGRectMake(270, 80, 40, 35);
    
    if([[defaultEvent objectForKey:kTypeofEvent] isEqualToString:@"Open"])
        eventType.text =@"An open event";
    else
        eventType.text =@"An invite-only event";
    nameofTheEvent.text = [defaultEvent objectForKey:kNameofEvent];
    placeName.text = [[defaultEvent objectForKey:kPlaceDetails] objectForKey:kName];
    startingTime.text = [defaultEvent objectForKey:kStartingTime];
    endingTime.text = [defaultEvent objectForKey:kEndingTime];
    descriptionValue.text = [defaultEvent objectForKey:kNotes];
    specifcsLabel.text = [defaultEvent objectForKey:kSpecifics];
    
    goingCellLabel.frame = CGRectMake(10, 30, frame.size.width, 50);
    mayBeCellLabel.frame = CGRectMake(10, 30, frame.size.width, 50);
    
    goingScrollview.frame = CGRectMake(10, goingCount.frame.origin.y+20, 300, 55);
    mayBeScrollview.frame= CGRectMake(10, goingCount.frame.origin.y+20, 300, 55);
    
    BOOL isParticipant = [[[defaultEvent objectForKey:kToUser] objectId] isEqualToString:[[PFUser currentUser] objectId]];
    
    NSString * description = [defaultEvent objectForKey:kNotes];
    
    switch (indexPath.row) {
        case 0:
            [cell.contentView addSubview:eventType];
            [cell.contentView addSubview:nameofTheEvent];
            break;
        case 1:
            [cell.contentView addSubview:placeIcon];
            [cell.contentView addSubview:placeName];
            [cell.contentView addSubview:specifcsLabel];
            break;
        case 2:
            [cell.contentView addSubview:timeIcon];
            [cell.contentView addSubview:startingTime];
            [cell.contentView addSubview:endingTime];
            break;
        case 3:
            if([[[defaultEvent objectForKey:kFromUser] objectId] isEqualToString:[[PFUser currentUser]objectId]])
                [cell.contentView addSubview:editButton];
            [cell.contentView addSubview:posterButton];
            [cell.contentView addSubview:venueButton];
            [cell.contentView addSubview:lineView1];
            break;
        case 4:
            if(isParticipant)
            {
                [cell.contentView addSubview:statusControl];
                [cell.contentView addSubview:lineView3];
            }
            else
            {
                if(description.length)
                {
                    [cell.contentView addSubview:descriptionLabel];
                    [cell.contentView addSubview:descriptionValue];
                    [cell.contentView addSubview:moreNotesButton];
                    [cell.contentView addSubview:lineView2];
                }
                else
                {
                    [cell.contentView addSubview:goingCellLabel];
                    [cell.contentView addSubview:goingCount];
                    [cell.contentView addSubview:goingScrollview];
                    [cell.contentView addSubview:moreGoingButton];
                    [cell.contentView addSubview:goingActivityIndicatorView];
                }
            }
            
            
            break;
        case 5:
            if(isParticipant)
            {
                if(description.length)
                {
                    [cell.contentView addSubview:descriptionLabel];
                    [cell.contentView addSubview:descriptionValue];
                    [cell.contentView addSubview:moreNotesButton];
                    [cell.contentView addSubview:lineView2];
                }
                else
                {
                    [cell.contentView addSubview:goingCellLabel];
                    [cell.contentView addSubview:goingCount];
                    [cell.contentView addSubview:goingScrollview];
                    [cell.contentView addSubview:moreGoingButton];
                    [cell.contentView addSubview:goingActivityIndicatorView];
                }
            }
            else
            {
                if(description.length)
                {
                    [cell.contentView addSubview:goingCellLabel];
                    [cell.contentView addSubview:goingCount];
                    [cell.contentView addSubview:goingScrollview];
                    [cell.contentView addSubview:moreGoingButton];
                    [cell.contentView addSubview:goingActivityIndicatorView];
                }
                else
                {
                    [cell.contentView addSubview:mayBeCellLabel];
                    [cell.contentView addSubview:mayBeCount];
                    [cell.contentView addSubview:mayBeScrollview];
                    [cell.contentView addSubview:moreMayBeButton];
                    [cell.contentView addSubview:mayBeActivityIndicatorView];
                }
            }
            
            break;
        case 6:
            if(isParticipant)
            {
                if(description.length)
                {
                    [cell.contentView addSubview:goingCellLabel];
                    [cell.contentView addSubview:goingCount];
                    [cell.contentView addSubview:goingScrollview];
                    [cell.contentView addSubview:moreGoingButton];
                    [cell.contentView addSubview:goingActivityIndicatorView];
                }
                else
                {
                    [cell.contentView addSubview:mayBeCellLabel];
                    [cell.contentView addSubview:mayBeCount];
                    [cell.contentView addSubview:mayBeScrollview];
                    [cell.contentView addSubview:moreMayBeButton];
                    [cell.contentView addSubview:mayBeActivityIndicatorView];
                }
            }
            else
            {
                [cell.contentView addSubview:mayBeCellLabel];
                [cell.contentView addSubview:mayBeCount];
                [cell.contentView addSubview:mayBeScrollview];
                [cell.contentView addSubview:moreMayBeButton];
                [cell.contentView addSubview:mayBeActivityIndicatorView];
            }
            break;
        case 7:
            [cell.contentView addSubview:mayBeCellLabel];
            [cell.contentView addSubview:mayBeCount];
            [cell.contentView addSubview:mayBeScrollview];
            [cell.contentView addSubview:moreMayBeButton];
            [cell.contentView addSubview:mayBeActivityIndicatorView];
            break;
        default:
            break;
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark button methods
//Fetch selected location details of the event and show the same in AMPlaceViewController
-(void)venueButtonAction{
    AMPlaceViewController *placeViewController = [[AMPlaceViewController alloc]init];
    NSDictionary *placeData = [defaultEvent objectForKey:kPlaceDetails];
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    [hud setDimBackground:NO];
    [hud setLabelText:@"Loading..."];
    PFFile *placeFile = [placeData objectForKey:kImage];
    [placeFile getDataInBackgroundWithBlock:^(NSData *data,NSError *error){
        [MBProgressHUD hideHUDForView:self.view  animated:YES];
        if(!error)
        {
            AMPlaceObject *placeObject = [[AMPlaceObject alloc]init];
            placeObject.nameofPlace = [placeData objectForKey:kName];
            placeObject.placeIcon = [UIImage imageWithData:data];
            placeObject.latitude = [[[placeData objectForKey:kLocation] objectForKey:kLatitude] floatValue];
            placeObject.longitude = [[[placeData objectForKey:kLocation] objectForKey:kLongitude] floatValue];
            placeObject.rating = [placeData objectForKey:kRating];
            placeObject.iconUrl = [placeData objectForKey:kIconUrl];
            placeObject.isImageDownloaded = 1;
            placeObject.address = [placeData objectForKey:kAddress];
            placeObject.phoneNumber = [placeData objectForKey:kDisplay_phone];
            placeObject.mobileUrl = [placeData objectForKey:kMobile_url];
            placeObject.categories = [placeData objectForKey:kCategories];
            
            placeViewController.placeObj = placeObject;
            UINavigationController *naviContrlr  = [[UINavigationController alloc]initWithRootViewController:placeViewController];
            naviContrlr.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentModalViewController:naviContrlr animated:YES];
        }
    }];
}
//Get details of people attending the event. 
-(void)getGoingPeopleData{
    if(!goingPeopleData)
        goingPeopleData  = [[NSMutableArray alloc]init];
    [goingPeopleData removeAllObjects];
    NSArray *conditions = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",kUpdated],[NSString stringWithFormat:@"%@",kAttended], nil];
    
    PFQuery *query  = [PFQuery queryWithClassName:kEventActivity];
    [query whereKey:kParent equalTo:[defaultEvent objectForKey:kParent]];
    [query whereKey:kAttendanceType equalTo:kGoing];
    [query orderByAscending:kUpdatedAt];
    [query whereKey:kEventActivityType notContainedIn:conditions];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects,NSError *error){
        if(!objects.count)
        {
            goingCellLabel.text = @"No people are going for now. :(";
            [goingScrollview removeFromSuperview];
            [goingActivityIndicatorView stopAnimating];
            goingFetched = YES;
            [self setPeopleAttendanceStatus];
        }
        else
        {
            goingCount.text = [NSString stringWithFormat:@"Going(%d)",objects.count];
        }
        [objects enumerateObjectsUsingBlock:^(PFObject *object,NSUInteger index,BOOL *stop){
            PFUser *user = [object objectForKey:kToUser];
            PFImageView *imageview = [[PFImageView alloc]initWithFrame:CGRectMake(5*(index+1)+(55*index), 5, 55,55)];
            [user fetchIfNeededInBackgroundWithBlock:^(PFObject *obj,NSError *error){
                imageview.file = [obj objectForKey:kProfileImage];
                imageview.image = [UIImage imageNamed:@"person_icon.png"];
                [goingScrollview addSubview:imageview];
                [imageview loadInBackground];
                [goingActivityIndicatorView stopAnimating];
                [goingPeopleData addObject:user];
                goingFetched = YES;
                [self setPeopleAttendanceStatus];
            }];
        }];
    }];
}

//Get details who may attend the event. 
-(void)getMayBePeopleData{
    if(!mayBePeopleData)
        mayBePeopleData = [[NSMutableArray alloc]init];
    [mayBePeopleData removeAllObjects];
    PFQuery *query  = [PFQuery queryWithClassName:kEventActivity];
    [query whereKey:kParent equalTo:[defaultEvent objectForKey:kParent]];
    [query whereKey:kAttendanceType equalTo:kMaybe];
    [query orderByAscending:kUpdatedAt];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects,NSError *error){
        
        if(!objects.count)
        {
//            mayBeCellLabel.text = @"No people are going for now. :(";
            mayBeFetched = YES;
            [self setPeopleAttendanceStatus];
            
        }
        else
        {
            mayBeCount.text = [NSString stringWithFormat:@"MayBe(%d)",objects.count];
        }
        [objects enumerateObjectsUsingBlock:^(PFObject *object,NSUInteger index,BOOL *stop){
            PFUser *user = [object objectForKey:kToUser];
            PFImageView *imageview = [[PFImageView alloc]initWithFrame:CGRectMake(5*(index+1)+(55*index), 5, 55,55)];
            [user fetchIfNeededInBackgroundWithBlock:^(PFObject *obj,NSError *error){
                imageview.file = [obj objectForKey:kProfileImage];
                imageview.image = [UIImage imageNamed:@"person_icon.png"];
                [mayBeScrollview addSubview:imageview];
                [imageview loadInBackground];
                [mayBeActivityIndicatorView stopAnimating];
                [mayBePeopleData addObject:user];
            }];
            
        }];
    }];
}
//Method to show the selected poster. 
-(void)posterButtonAction{
    AMEventImageViewer *controller = [[AMEventImageViewer alloc]init];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    if([defaultEvent objectForKey:kPosterImage])
    {
        [controller loadFileinBackground: [defaultEvent objectForKey:kPosterImage]];
    }
    else if([[defaultEvent objectForKey:kTypeofEvent] isEqualToString:@"Open"])
    {
        UIImage *posterImage = [UIImage imageNamed:@"defaultpublic.png"];
        if(kIsIphone568)
            posterImage = [UIImage imageNamed:@"defaultpublic-568h.png"];
        [controller loadImage:posterImage];
    }
    else
    {
        UIImage *posterImage = [UIImage imageNamed:@"defaultprivate.png"];
        if (kIsIphone568) {
            posterImage = [UIImage imageNamed:@"defaultprivate-568h.png"];
        }
        [controller loadImage:posterImage];
        
    }
}
//Method to edit the event. Open AMCreateEventController with the event data. 
-(void)editButtonAction{
    AMCreateEventController *controller = [[AMCreateEventController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller updateDetailstoEditforEvent:defaultEvent];
    controller.navigationItem.hidesBackButton = NO;
}


-(void)statusControlValueChanged:(UISegmentedControl *)control{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    [hud setDimBackground:NO];
    [hud setLabelText:@"Updating.."];
    NSString *statusControlString;
    if(control.selectedSegmentIndex == 0)
        statusControlString= kGoing;
    else if (control.selectedSegmentIndex == 1)
        statusControlString = kMaybe;
    else if (control.selectedSegmentIndex == 2)
        statusControlString = kNotGoing;
    [defaultEvent setObject:statusControlString forKey:kAttendanceType];
    [defaultEvent saveInBackgroundWithBlock:^(BOOL succeded,NSError *error){
        
        if(!succeded)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
        else
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:kReloadtableData object:nil];
        }
        hud.hidden = YES;
    }];
}

-(void)updateTableDatawithEvent:(PFObject *)event
{
    [eventDetailsTable reloadData];
}

//Open people going to the event in AMPeopleViewer
-(void)moreGoingButtonAction{
    AMPeopleViewer *peopleViewer = [[AMPeopleViewer alloc]init];
    peopleViewer.peopleArray = [NSArray arrayWithArray:goingPeopleData];
    [self.navigationController pushViewController:peopleViewer animated:YES];
    
}

//Open people who may go to the event in AMPeopleViewer
-(void)moreMayBeButtonAction{
    AMPeopleViewer *peopleViewer = [[AMPeopleViewer alloc]init];
    peopleViewer.peopleArray = [NSArray arrayWithArray:mayBePeopleData];
    [self.navigationController pushViewController:peopleViewer animated:YES];
}

//Timer call back to update time left in the pie.
-(void)updateTimeLeftForEvent{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
    NSDate *now = [NSDate date];
    NSDate *startingTime1 = [dateFormatter dateFromString:[defaultEvent objectForKey:kStartingTime]];

    NSDateComponents *components;
    NSInteger minutes;
    
    components = [[NSCalendar currentCalendar] components: NSMinuteCalendarUnit
                                                 fromDate: now toDate: startingTime1 options: 0];
    minutes = [components minute];


    if(minutes<=0)
    {
//        if([timeLeftForEventTimer isValid])
            [timeLeftForEventTimer invalidate];
        time.text =@"0";
        sspieProgress.progress = 1;
    }
    else
    {
        time.text = [NSString stringWithFormat:@"%d",minutes];
        
        CGFloat nummertaror = minutes;
        CGFloat val = nummertaror/120.0;
//        NSLog(@"%f",val);
        sspieProgress.progress = 1-val;
    }
}
-(void)checkForDefaultEvent{
    [self getDefaultEventandLoad];
}

//Method to setup view retrieved co-ordinated from event data. 
-(void)setUpMapView{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
    
    NSString *endTime = [defaultEvent objectForKey:kEndingTime];
    NSDate *now = [NSDate date];
    if(endTime && ([now compare:[dateFormatter dateFromString:endTime]]  != NSOrderedAscending)) {
//        if([timeLeftForEventTimer isValid])
            [timeLeftForEventTimer invalidate];
//        if([mapSetupTimer isValid])
            [mapSetupTimer invalidate];
        [self showNoEventAlert];
        NSLog(@"No event to track");
        getDefaultEventTimer = [NSTimer scheduledTimerWithTimeInterval:kTimerTime target:self selector:@selector(getDefaultEventandLoad) userInfo:nil repeats:YES];
        [getDefaultEventTimer fire];
        return;
    }

    
    NSMutableArray *invitees = [NSMutableArray arrayWithArray:[defaultEvent objectForKey:kInvitees]];
    if([[[defaultEvent objectForKey:kFromUser] objectId] isEqualToString:[[PFUser currentUser] objectId]])
    {
        [invitees addObject:[PFUser currentUser]];
    }
    else
    {
        [invitees addObject:[defaultEvent objectForKey:kFromUser]];
    }
    
    PFQuery *goingPeopleQuery  = [PFQuery queryWithClassName:kEventActivity];
    [goingPeopleQuery whereKey:kParent equalTo:[defaultEvent objectForKey:kParent]];
    [goingPeopleQuery whereKey:kToUser containedIn:invitees];
    [goingPeopleQuery whereKey:kAttendanceType notEqualTo:kNotGoing];
    
    
    PFQuery *locationQuery  = [PFQuery queryWithClassName:@"LocationData"];
    [locationQuery whereKey:kFromUser matchesKey:kToUser inQuery:goingPeopleQuery];
  
    [locationQuery findObjectsInBackgroundWithTarget:self selector:@selector(objectsReceivedForMapview:error:)];
}


//Location details query call back. Here received location details are parsed in required format and sent to mapview controller.

-(void)objectsReceivedForMapview:(NSArray *)objects error:(NSError *)error
{
    if(objects.count)
    {
        arrivedCount = 0;
        enrouteCount = 0;
        NSMutableArray *dataArray  = [[ NSMutableArray alloc]init];
        [AMUtility saveUsersLocationtoServer];
        float eventLatitude = [[[[defaultEvent objectForKey:kPlaceDetails] objectForKey:kLocation]objectForKey:kLatitude]floatValue ];
        float eventLongitude = [[[[defaultEvent objectForKey:kPlaceDetails] objectForKey:kLocation]objectForKey:kLongitude]floatValue ];
        
        NSDictionary *location = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithFloat:eventLatitude],kLatitude,[NSNumber numberWithFloat:eventLongitude],kLongitude, nil];
        
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc]init];
        [dictionary setObject:[[defaultEvent objectForKey:kPlaceDetails ] objectForKey:kName] forKey:kName];
        [dictionary setObject:kPlaceType forKey:kType];
        [dictionary setObject:location forKey:kLocation];
        [dataArray addObject:dictionary];
        
        
        CGFloat latitude = [[[dictionary objectForKey:kLocation]objectForKey:kLatitude]floatValue];
        CGFloat longitude = [[[dictionary objectForKey:kLocation]objectForKey:kLongitude]floatValue];
        
        CLLocation *locA = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        
        for (int i=0; i<objects.count; i++) {
            PFObject *obj = [objects objectAtIndex:i];
            NSDictionary *dict  = [[NSDictionary alloc]initWithObjectsAndKeys:[obj objectForKey:kFromUser ],kFriends,[obj objectForKey:kLocation],kLocation,kInviteeType,kType, nil];
            
            latitude = [[[dict objectForKey:kLocation]objectForKey:kLatitude]floatValue];
            longitude = [[[dict objectForKey:kLocation]objectForKey:kLongitude]floatValue];
            CLLocation *locB = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            
             CLLocationDistance distance = [locA distanceFromLocation:locB];
            NSLog(@"%f",distance);
            
            if(distance>=1000) //Here we check distance between user's location and event location. If distance is less than 1000m, then a new time line entry -"Attended an event" will be created for this user and same will be posted to facebook too.
            {
                [dataArray addObject:dict];
                enrouteCount ++;
            }
            else
            {
                arrivedCount++;
                if([[[obj objectForKey:kFromUser] objectId] isEqualToString:[[PFUser currentUser] objectId]])
                {
                    PFQuery *query  = [PFQuery queryWithClassName:kEventActivity];
                    [query whereKey:kParent equalTo:[defaultEvent objectForKey:kParent]];
                    [query whereKey:kAttendanceType equalTo:kAttended];
                    [query whereKey:kToUser equalTo:[PFUser currentUser]];
                    [query getFirstObjectInBackgroundWithBlock:^(PFObject *savedObj,NSError *error){
                       if(error && !savedObj)
                       {
                           NSDate *todaysDate = [NSDate date];
                           NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                           [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
                           NSString *dateString = [dateFormatter stringFromDate:todaysDate];
                           
                           PFObject *newActivity = [[PFObject alloc]initWithClassName:kEventActivity];
                           [newActivity setObject:[defaultEvent objectForKey:kNameofEvent] forKey:kNameofEvent];
                           [newActivity setObject:[defaultEvent objectForKey:kInvitees] forKey:kInvitees];
                           [newActivity setObject:[defaultEvent objectForKey:kStartingTime] forKey:kStartingTime];
                           [newActivity setObject:[defaultEvent objectForKey:kEndingTime ] forKey:kEndingTime];
                           [newActivity setObject:[defaultEvent objectForKey:kTypeofEvent] forKey:kTypeofEvent];
                           [newActivity setObject:[defaultEvent objectForKey:kNotes] forKey:kNotes];
                           [newActivity setObject:[defaultEvent objectForKey:kPlaceDetails] forKey:kPlaceDetails];
                           if([defaultEvent objectForKey:kPosterImage])
                            [newActivity setObject:[defaultEvent objectForKey:kPosterImage] forKey:kPosterImage];
                           [newActivity setObject:[defaultEvent objectForKey:kSpecifics] forKey:kSpecifics];
                           [newActivity setObject:[defaultEvent objectForKey:kParent] forKey:kParent];
                           
                           [newActivity setObject:kAttended forKey:kAttendanceType];
                           [newActivity setObject:[defaultEvent objectForKey:kFromUser] forKey:kFromUser];
                           [newActivity setObject:kAttended forKey:kEventActivityType];
                           [newActivity setObject:[PFUser currentUser] forKey:kToUser];
                           [newActivity setObject:[defaultEvent objectForKey:kOwnership] forKey:kOwnership];
                           [newActivity setObject:dateString forKey:kCreatedDate];
                           [newActivity saveInBackgroundWithBlock:^(BOOL success, NSError *error){
                               [AMUtility postAttendedEventToFacebook:newActivity]; //Post event activity to facebook.
                           }];
                       }
                    }];
                }
            }
        }
        enrouteCoutLabel.text = [NSString stringWithFormat:@"%d",enrouteCount];
        arrivedCountLabel.text = [NSString stringWithFormat:@"%d",arrivedCount];
        [mapViewController setMapViewtoPointEventLocation:dataArray];
    }
}


-(void)setPeopleAttendanceStatus{
    if(mayBeFetched && goingFetched && !mayBePeopleData.count && !goingPeopleData.count){
        mayBeCellLabel.text = @"No people are going for now. :(";
        [mayBeScrollview removeFromSuperview];
        [mayBeActivityIndicatorView stopAnimating];
    }
    else if(mayBeFetched && goingFetched && !mayBePeopleData.count && goingPeopleData.count)
    {
        [mayBeScrollview removeFromSuperview];
        [mayBeActivityIndicatorView stopAnimating];
        mayBeCellLabel.text = @"Everybody is going";
    }
}

-(void)showNoEventAlert{
    
    [self clearScreen];
    
    if(!noEventImageView)
     noEventImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320,246)];
    noEventImageView.image = [UIImage imageNamed:@"emptypie.png"];

    if(![self.view.subviews containsObject:noEventImageView])
        [self.view addSubview:noEventImageView];
    if(!noEventButton)
        noEventButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [noEventButton setBackgroundImage:[UIImage imageNamed:@"popup.png"] forState:UIControlStateNormal];
    [noEventButton setBackgroundImage:[UIImage imageNamed:@"popup-t.png"] forState:UIControlStateHighlighted];
    noEventButton.frame = CGRectMake(78, ((kScreenHeight-64)/2)-98, 164, 164);
    [noEventButton addTarget:self action:@selector(removenoEventButton) forControlEvents:UIControlEventTouchUpInside];
    if(![self.view.subviews containsObject:noEventButton])
    {
        [self.view addSubview:noEventButton];
        [self.view bringSubviewToFront:noEventButton];
    }
}


-(void)removenoEventButton{
    if([self.view.subviews containsObject:noEventButton])
    {
        [UIView animateWithDuration:0.30f animations:^(void){ noEventButton.alpha = 0; } completion:^(BOOL finished){ [noEventButton removeFromSuperview]; }];
    }
}
-(void)clearScreen{
    self.title = @"Now";
    for(UIView *view in sspieProgress.subviews)
    {
        [view removeFromSuperview];
    }
    
    for(UIView *view in topView.subviews )
    {
        [view removeFromSuperview];
    }
    
    [topView removeFromSuperview];
    [eventDetailsTable removeFromSuperview];
    [mapViewController.view removeFromSuperview];
    eventDetailsTable = nil;
    mapViewController = nil;
    topView = nil;
    enrouteCoutLabel = nil;
    arrivedCountLabel = nil;
    enrouteButton = nil;
    arrivedButton = nil;
    hud.hidden = YES;
}


@end
