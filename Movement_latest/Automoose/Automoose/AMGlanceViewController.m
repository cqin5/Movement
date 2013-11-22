//
//  AMGlanceViewController.m
//  Automoose
//
//  Created by Srinivas on 21/12/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import "AMGlanceViewController.h"
#import "AMCreateEventController.h"
#import "AMUtility.h"
#import "AMEventCustomCell.h"
#import "MBProgressHUD.h"
#import "AMEventObject.h"
#import "AMConstants.h"

#import <QuartzCore/QuartzCore.h>
#import "AMAppDelegate.h"
#import "AMEvent.h"
#import "AMTimelineEntity.h"
#import "MFSideMenu.h"
#import "AMGlanceEventCell.h"
#import "AMEventImageViewer.h"
#import "AMDetailEventViewController.h"
#import "AMDetailEventViewController.h"
#import "ODRefreshControl.h"
#import "AMProfileViewer.h"
CGFloat const kRefreshViewHeight = 57;
@interface AMGlanceViewController ()
{
    MBProgressHUD *hud;
    UIView * headerView;
	UIView * topView;
	UILabel * topLabel;
	BOOL refreshing;
    UIActivityIndicatorView *activtyIndicator;
    NSMutableArray *peopleArray;
    PFImageView *eventImageview;
    ODRefreshControl *refreshControl;
    UIImageView *emptyTimeLineImageview;
}
@end

@interface AMGlanceViewController (Private)
- (void)refreshData;
@end
@implementation AMGlanceViewController
@synthesize delegate;
/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.title = NSLocalizedString(@"Glance", @"Glance");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fetchNewEventInvitation:) name:@"NewInvitationReceived" object:nil];
    }
    return self;
}
*/
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom the table
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(fetchNewEventInvitation:) name:@"NewInvitationReceived" object:nil];

        // The key of the PFObject to display in the label of the default cell style
        self.textKey = @"text";
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = NO;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = 20;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [AMUtility getColorwithRed:250 green:250 blue:250];
    self.tableView.backgroundColor = [AMUtility getColorwithRed:250 green:250 blue:250];
    [self setupMenuBarButtonItems];
    eventImageview = [[PFImageView alloc]init];
        eventImageview.exclusiveTouch = YES;
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [AMUtility getColorwithRed:253 green:253 blue:253];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadTableData) name:kReloadtableData object:nil];
    self.title = @"Timeline";
    [self.navigationItem setHidesBackButton:YES];
    

    NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:kEventsList];
    eventsArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    peopleArray = [[NSMutableArray alloc]init];
    refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(reloadTableData) forControlEvents:UIControlEventValueChanged];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

//    [self reloadTableData];

}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	[UIView animateWithDuration:duration animations:^{
		[headerView setFrame:CGRectMake(0, -kRefreshViewHeight, self.view.bounds.size.width, kRefreshViewHeight)];
		[topView setFrame:CGRectMake(0, -kRefreshViewHeight / 4, headerView.bounds.size.width, kRefreshViewHeight / 2)];
		[topLabel setFrame:topView.bounds];
		[[self.view viewWithTag:123] setFrame:CGRectMake(0, -self.view.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - kRefreshViewHeight)];
	}];
}

- (void)setupMenuBarButtonItems {
    switch (self.navigationController.sideMenu.menuState) {
        case MFSideMenuStateClosed:
            if([[self.navigationController.viewControllers objectAtIndex:0] isEqual:self]) {
                self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
            } else {
                self.navigationItem.leftBarButtonItem = [self backBarButtonItem];
            }
            self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
            break;
        case MFSideMenuStateLeftMenuOpen:
            self.navigationItem.leftBarButtonItem = [self leftMenuBarButtonItem];
            break;
        case MFSideMenuStateRightMenuOpen:
            self.navigationItem.rightBarButtonItem = [self rightMenuBarButtonItem];
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

- (UIBarButtonItem *)backBarButtonItem {
    return [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back-arrow"]
                                            style:UIBarButtonItemStyleBordered
                                           target:self
                                           action:@selector(backButtonPressed:)];
}

- (void)backButtonPressed:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)loadEventFromNotification:(NSString *)eventId
{
    
}
-(void)reloadTableData {
    [self loadObjects:0 clear:YES];

    /*
    PFQuery *query = [self queryForTable];
    [query findObjectsInBackgroundWithBlock:^(NSArray *newEvents,NSError *error){
        
        events = newEvents;
        [self.tableView reloadData];
        [refreshControl endRefreshing];
    }];
     */
}

#pragma mark - Parse call back methods for PFQueryTableViewController

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];
    NSLog(@"ERROR: %@",error);
    [self.objects enumerateObjectsUsingBlock:^(PFObject *object,NSUInteger index,BOOL *stop){
        NSArray *invitees = [object objectForKey:kInvitees];
        [invitees enumerateObjectsUsingBlock:^(PFUser *user, NSUInteger indx, BOOL *stop){
        [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object,NSError *error){}];
        }];
    }];
    events = self.objects;
    if(!events.count)
    {
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        if(!emptyTimeLineImageview)
        {
            CGFloat y;
            if(kIsIphone568)
                y=145;
            else
                y=105;
            
            emptyTimeLineImageview = [[UIImageView alloc]initWithFrame:CGRectMake(0, y, 320, 165)];
        }
        
        CGRect frame = emptyTimeLineImageview.frame;
        frame = self.tableView.frame;
        emptyTimeLineImageview.image = [UIImage imageNamed:@"emptytimeline.png"];

        if(![self.tableView.subviews containsObject:emptyTimeLineImageview] && emptyTimeLineImageview)
            [self.tableView addSubview:emptyTimeLineImageview];
    }
    else
    {
        if([self.tableView.subviews containsObject:emptyTimeLineImageview] && emptyTimeLineImageview)
            [emptyTimeLineImageview removeFromSuperview];
    }
    [self.tableView reloadData];
    [refreshControl endRefreshing];
  }

- (void)objectsWillLoad {
    [super objectsWillLoad];
    [AMUtility fetchFollowing:^(NSError *error){
        
    }];

    /*
    [peopleArray removeAllObjects];
    NSArray *followers = [[NSUserDefaults standardUserDefaults]objectForKey:kFollowers];
    NSArray *following = [[NSUserDefaults standardUserDefaults]objectForKey:kFollowing];
    [followers enumerateObjectsUsingBlock:^(NSDictionary *dict,NSUInteger index,BOOL *stop){
        [peopleArray addObject:dict];
    }];
    [following enumerateObjectsUsingBlock:^(NSDictionary *dict,NSUInteger index,BOOL *stop){
        [peopleArray addObject:dict];
    }];
     */
}


//Here query for the table has to be passed.
- (PFQuery *)queryForTable {

    PFQuery *eventsFromCurrentUser = [PFQuery queryWithClassName:@"EventActivity"];
    [eventsFromCurrentUser whereKey:@"fromUser" equalTo:[PFUser currentUser]];
    [eventsFromCurrentUser whereKey:kEventActivityType containedIn:[NSArray arrayWithObjects:@"Created",@"Updated",@"Attended", nil]];
    [eventsFromCurrentUser whereKey:kOwnership equalTo:kOwner];
    
    //Following list
    NSArray *followingArray = [[NSUserDefaults standardUserDefaults]objectForKey:kFollowing];
    NSMutableArray *objectIdArray  = [[NSMutableArray alloc]init];
    for (int i=0; i<followingArray.count; i++) {
        NSDictionary *dict = [followingArray objectAtIndex:i];
        [objectIdArray addObject:[dict objectForKey:kObjectId] ];
    }
    
    //Following list and i am participant
    
    PFQuery *followingList = [PFUser query];
    [followingList whereKey:kObjectId containedIn:objectIdArray];

    
    PFQuery *followingListandSelfParticipantQuery  = [PFQuery queryWithClassName:@"EventActivity"];
    [followingListandSelfParticipantQuery whereKey:kFromUser matchesQuery:followingList];
    [followingListandSelfParticipantQuery whereKey:kToUser equalTo:[PFUser currentUser]];
    [followingListandSelfParticipantQuery whereKey:kEventActivityType containedIn:[NSArray arrayWithObjects:@"Created",@"Updated",@"Attended", nil]];
    
    
       //Follwing events query 
    PFQuery *eventsFromFollwoing = [PFQuery queryWithClassName:@"EventActivity"];
    [eventsFromFollwoing whereKey:kFromUser matchesQuery:followingList];
    [eventsFromFollwoing whereKey:kEventActivityType containedIn:[NSArray arrayWithObjects:@"Created",@"Updated",@"Attended", nil]];
    [eventsFromFollwoing whereKey:kOwnership equalTo:kOwner];
    [eventsFromFollwoing whereKey:kParent doesNotMatchKey:kParent inQuery:followingListandSelfParticipantQuery];


  //Follower list
    
    NSArray *followerArray = [[NSUserDefaults standardUserDefaults]objectForKey:kFollowers];
    NSMutableArray *objectIdArray2 = [[NSMutableArray alloc]init];
    for (int i=0; i<followerArray.count; i++) {
        NSDictionary *dict = [followerArray objectAtIndex:i];
        if(![objectIdArray containsObject:[dict objectForKey:kObjectId]])
            [objectIdArray2 addObject:[dict objectForKey:kObjectId]];
    }
    
    PFQuery *followerList =[PFUser query];
    [followerList whereKey:kObjectId containedIn:objectIdArray2];
    
    PFQuery *eventsFromFollowers = [PFQuery queryWithClassName:@"EventActivity"];
    [eventsFromFollowers whereKey:kFromUser matchesQuery:followerList];
    [eventsFromFollowers whereKey:kToUser equalTo:[PFUser currentUser]];

    PFQuery *query = [PFQuery orQueryWithSubqueries:@[ eventsFromCurrentUser, eventsFromFollwoing,eventsFromFollowers,followingListandSelfParticipantQuery ]];
    [query orderByDescending:@"updatedAt"];
    [query includeKey:@"fromUser"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    if ([self.objects count] == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    
    [query orderByDescending:@"createdAt"];
    
    return query;
}

// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the first key in the object.

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (scrollView.contentSize.height - scrollView.contentOffset.y < (self.view.bounds.size.height)) {
        if (![self isLoading]) {
            NSLog(@"pulling next page");
            [self loadNextPage];
        }
    }
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == events.count)
        return 50;
    return kScreenheight - 44-20;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return events.count ;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    
    
    static NSString *CellIdentifier = @"Cell";
    AMGlanceEventCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[AMGlanceEventCell alloc]initWithFrame:CGRectZero];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    PFObject *event = [events objectAtIndex:indexPath.row];
    cell.eventNameLabel.text =[event objectForKey:kNameofEvent];
    
    NSString *actionString ;
    if([[event objectForKey:kEventActivityType] isEqualToString:@"Created"])
        actionString = @"created an event";
    else if ([[event objectForKey:kEventActivityType] isEqualToString:kGoing])
        actionString = @"is going to";
    else if ([[event objectForKey:kEventActivityType] isEqualToString:kAttended])
        actionString = @"attended an event";
    else if([[event objectForKey:kEventActivityType] isEqualToString:kUpdated])
    {
        if([[event objectForKey:kAttendanceType] isEqualToString:kAttended])
            actionString = @"attended an event";
        else
            actionString = @"updated an event";
    }
    cell.actionLabel.text = actionString;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
    NSDate *startDate = [dateFormatter dateFromString:[event objectForKey:kCreatedDate]];
    [dateFormatter setDateFormat:@"EEEE, d MMM yyyy"];
    
    NSDate *now = [NSDate date];
    NSTimeInterval timeInterval = [now timeIntervalSinceDate:startDate];
    NSLog(@"%f",timeInterval);
    
    if(timeInterval < 300)
        cell.eventTimeLabel.text = @"Just now";
    else if (timeInterval>=300 && timeInterval<3600)
        cell.eventTimeLabel.text = [NSString stringWithFormat:@"%.f minutes ago",timeInterval/60];
    else if (timeInterval>=3600 && timeInterval<24*60*60)
        cell.eventTimeLabel.text = [NSString stringWithFormat:@"%.f hours ago",timeInterval/3600];
    else
    {
        NSMutableString *finalTime = [[NSMutableString alloc]initWithString:[dateFormatter stringFromDate:startDate]];
        [finalTime appendString:@" at "];
        [dateFormatter setDateFormat:@"HH:mm"];
        [finalTime appendString:[dateFormatter stringFromDate:startDate]];
        cell.eventTimeLabel.text =finalTime;
    }
    
    PFUser *user = [event objectForKey:kFromUser];
    cell.userImageview.file = [user objectForKey:kProfileImage];
    [cell.userImageview loadInBackground];
    
//    cell.moreButton.tag = indexPath.row;
   
    if([event objectForKey:kPosterImage])
    {
        UIActivityIndicatorView *activitIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        CGPoint point  = cell.eventImageview.center;
        activitIndicatorView.frame = CGRectMake(point.x-15, point.y-50, 30, 30);
        [activitIndicatorView startAnimating];
        [cell.eventImageview addSubview:activitIndicatorView];
        
        cell.eventImageview.file = [event objectForKey:kPosterImage];
        [cell.eventImageview loadInBackground:^(UIImage *image,NSError *err){
            [activitIndicatorView removeFromSuperview];
        }];
    }
    else if([[event objectForKey:kTypeofEvent] isEqualToString:@"Open"])
    {   if(kIsIphone568)
        cell.eventImageview.image = [UIImage imageNamed:@"defaultpublic-568h.png"];
    else
        cell.eventImageview.image = [UIImage imageNamed:@"defaultpublic.png"];
    }
    else
    {   if(kIsIphone568)
        cell.eventImageview.image = [UIImage imageNamed:@"defaultprivate-568h.png"];
    else
        cell.eventImageview.image = [UIImage imageNamed:@"defaultprivate.png"];
    }
    
    cell.eventImageButton.tag = indexPath.row;
    [cell.eventImageButton addTarget:self action:@selector(eventImageButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    cell.userProfileButton.tag = indexPath.row;
    cell.eventDetailsButton.tag = indexPath.row;
    [cell.eventDetailsButton addTarget:self action:@selector(moreButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [cell.userProfileButton addTarget:self action:@selector(userProfileButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
    if(indexPath.row >= events.count)
        return;
}

//Method to show the event in detail.
-(void)moreButtonAction:(UIButton *)sender{
    int index = sender.tag;
    AMDetailEventViewController *eventViewerViewController = [[AMDetailEventViewController alloc]init];
    eventViewerViewController.eventData = [events objectAtIndex:index];
    [self.navigationController pushViewController:eventViewerViewController animated:YES];
}

//Method to open user profile when tapped on user image
-(void)userProfileButtonAction:(UIButton *)sender{
    int index = sender.tag;
    AMProfileViewer *profileViewer = [[AMProfileViewer alloc]init];
    [self.navigationController pushViewController:profileViewer animated:YES];
    PFObject *event = [events objectAtIndex:index];
    PFUser *user1 = [event objectForKey:kFromUser];
    [profileViewer showDetailsofUser:user1];
}

//Method to show the event poster
-(void)eventImageButtonAction:(UIButton *)sender{
    AMEventImageViewer *controller = [[AMEventImageViewer alloc]init];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
//    [controller loadImage:[UIImage imageNamed:@"defaultpublic.png"]];
     PFObject *event = [events objectAtIndex:sender.tag];
    if([event objectForKey:kPosterImage])
    {
//        cell.eventImageview.file = [event objectForKey:kPosterImage];
//        [cell.eventImageview loadInBackground];
        [controller loadFileinBackground:[event objectForKey:kPosterImage]];
    }
    else if([[event objectForKey:kTypeofEvent] isEqualToString:@"Open"])
    {
        if(kIsIphone568)
            [controller loadImage: [UIImage imageNamed:@"defaultpublic-568h.png"]];
        else
            [controller loadImage: [UIImage imageNamed:@"defaultpublic.png"]];
    }
    else
    {
        if(kIsIphone568)
            [controller loadImage: [UIImage imageNamed:@"defaultprivate-568h.png"]];
        else
            [controller loadImage: [UIImage imageNamed:@"defaultprivate.png"]];
    }
    

    /*
    [self.view addSubview:eventImageview];
    eventImageview.frame = CGRectMake(kScreenWidth/2, kScreenHeight/2, 0, 0);
    eventImageview.image = [UIImage imageNamed:@"defaultpublic.png"];
    [UIView animateWithDuration:0.5 animations:^(void){
        eventImageview.frame = CGRectMake(0, 0, 320, kScreenHeight-44-20);
    }
    completion:^(BOOL finished){
        UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        doneButton.frame = CGRectMake(250, 20, 50, 40);
        [doneButton setTitle:@"Done" forState:UIControlStateNormal];
        [eventImageview addSubview:doneButton];
        [doneButton addTarget:self action:@selector(removeEventImage) forControlEvents:UIControlEventTouchUpInside];
    }];
     */
}

/*
-(void)removeEventImage{
    [UIView animateWithDuration:0.5 animations:^(void){
        eventImageview.frame = CGRectMake(kScreenWidth/2, kScreenHeight/2, 0, 0);
    }completion:^(BOOL finished){
        [eventImageview removeFromSuperview];
    }];
}
 */


//NSNotifcation call back method. Called when new invitation is received via notification.
-(void)fetchNewEventInvitation:(NSNotification *)notification {
    
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    [hud setDimBackground:YES];
    [hud setLabelText:@"Loading"];
    [self.view bringSubviewToFront:hud];
    
    NSDictionary *dict = [notification object];
    PFQuery *query = [PFQuery queryWithClassName:kEventActivity];
    [query whereKey:kParent equalTo:[dict objectForKey:kEventId]];
    [query whereKey:kToUser equalTo:[PFUser currentUser]];
    [query whereKey:kEventActivityType equalTo:kCreated];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *event, NSError *error) {
        hud.hidden = YES;
        if(!error)
        {
            /* //Modifications
            AMEventViewerController *eventViewerViewController = [[AMEventViewerController alloc]init];
            eventViewerViewController.event = event;
            [self.navigationController pushViewController:eventViewerViewController animated:YES];
             */
            
            AMDetailEventViewController *eventViewerViewController = [[AMDetailEventViewController alloc]init];
            eventViewerViewController.eventData = event;
            [self.navigationController pushViewController:eventViewerViewController animated:YES];
        }
        else
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
        
    }];
}

@end
