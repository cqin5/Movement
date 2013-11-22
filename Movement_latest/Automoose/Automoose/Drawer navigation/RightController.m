//
//  RightController.m
//  DDMenuController
//
//  Created by Devin Doty on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RightController.h"
#import "AMRightViewCustomCell.h"
#import "AMConstants.h"
#import "AMEventObject.h"

#import "MFSideMenu.h"
#import "AMUtility.h"
#import "AMDetailEventViewController.h"
#import "ODRefreshControl.h"
CGFloat const kRefreshViewHeight2 = 50;
@interface RightController ()
{
    EventType eventTypeSelected;
    ODRefreshControl *refreshControl;
    MBProgressHUD *hud;
}
@end

@implementation RightController

@synthesize table,sideMenu;

- (id)init {
    
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(reloadTableData) name:@"ReloadRightViewData" object:nil];
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}


#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!table) {
        allEventsArray = [[NSMutableArray alloc]init];
        CGSize viewSize = [[UIScreen mainScreen] bounds].size;
        CGRect frame = self.view.bounds;
        frame.origin.x = 0;
        frame.size.width = 320;
        frame.origin.y = 46;
        frame.size.height = viewSize.height-80;
        
        if(isPhone568)
            [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-568h.png"]]];
        else
            [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
        
        UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tableView.delegate = (id<UITableViewDelegate>)self;
        tableView.dataSource = (id<UITableViewDataSource>)self;
        tableView.backgroundView = nil;
        tableView.backgroundColor = [UIColor clearColor];
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:tableView];
        self.table = tableView;

        
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0,270,46)];
        imgView.image = [UIImage imageNamed:@"eventlist.png"];
//        [self.view addSubview:imgView];
        
        UILabel *headerLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 270, 46)];
        [headerLabel setBackgroundColor:[UIColor clearColor]];
        [headerLabel setText:@"My Events"];
        headerLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:20];
        headerLabel.textAlignment = NSTextAlignmentCenter;
        [headerLabel setTextColor:[UIColor whiteColor]];
        [self.view addSubview:headerLabel];
        
        bottomImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height-40, 270, 40)];
        bottomImageView.image = [UIImage imageNamed:@"going.png"];
//        [self.view addSubview:bottomImageView];
        
        goingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        goingButton.frame = CGRectMake(0, self.view.frame.size.height-40, 270/3, 40) ;
        goingButton.tag = 100;
        [goingButton addTarget:self action:@selector(changeTypeofEvent:) forControlEvents:UIControlEventTouchUpInside];
        [goingButton setTitle:@"Going" forState:UIControlStateNormal];
        [self.view addSubview:goingButton];
        
        mayBeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        mayBeButton.frame = CGRectMake(270/3, self.view.frame.size.height-40, 270/3, 40) ;
        mayBeButton.tag = 101;
        [mayBeButton addTarget:self action:@selector(changeTypeofEvent:) forControlEvents:UIControlEventTouchUpInside];
        [mayBeButton setTitle:@"Maybe" forState:UIControlStateNormal];
        [self.view addSubview:mayBeButton];
        
        allButton = [UIButton buttonWithType:UIButtonTypeCustom];
        allButton.frame = CGRectMake(2*(270/3), self.view.frame.size.height-40, 270/3, 40) ;
        [allButton addTarget:self action:@selector(changeTypeofEvent:) forControlEvents:UIControlEventTouchUpInside];
        allButton.tag = 102;
        [allButton setTitle:@"All" forState:UIControlStateNormal];
        [self.view addSubview:allButton];
        eventTypeSelected = kGoingType;

        allEventsArray = [[NSMutableArray alloc]init];
        tableDataArray = [[NSMutableArray alloc]init];
//        [self setRefreshUI];
        
        [goingButton setBackgroundColor:[UIColor clearColor]];
        [mayBeButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"rightTab.png"]]];
        [allButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"rightTab.png"]]];
        
        refreshControl = [[ODRefreshControl alloc] initInScrollView:table];
        [refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
        refreshControl.activityIndicatorViewColor = [UIColor whiteColor];
    }

}

-(void)setRefreshUI
{
    headerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.table.frame.origin.y - kRefreshViewHeight2, self.view.bounds.size.width, kRefreshViewHeight2/4)];
	[headerView setBackgroundColor:[UIColor clearColor]];
	
	CATransform3D transform = CATransform3DIdentity;
	transform.m34 = -1/500.0;
	[headerView.layer setSublayerTransform:transform];
	
	topView = [[UIView alloc] initWithFrame:CGRectMake(0, (self.table.frame.origin.y - kRefreshViewHeight2 ) , headerView.bounds.size.width, kRefreshViewHeight2/ 1.5)];
	[topView setBackgroundColor:[UIColor colorWithRed:226 green:231 blue:238 alpha:1.0]];
	[topView.layer setAnchorPoint:CGPointMake(0.5, 0.0)];
    //	[headerView addSubview:topView];
	
	topLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, -kRefreshViewHeight2/4-10, 270, 28)];
	[topLabel setBackgroundColor:[UIColor clearColor]];
	[topLabel setTextAlignment:UITextAlignmentCenter];
	[topLabel setText:@"Pull down to refresh..."];
    [topLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
    
	[topLabel setTextColor:[AMUtility getColorwithRed:88 green:108 blue:140]];
//	[topLabel setShadowColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7]];
//	[topLabel setShadowOffset:CGSizeMake(0, 1)];
	[headerView addSubview:topLabel];
    
    UIView * aboveView = [[UIView alloc] initWithFrame:CGRectMake(0,-self.table.frame.size.height ,self.view.bounds.size.width ,self.table.frame.size.height )];
	[aboveView setBackgroundColor:[UIColor colorWithRed:226 green:231 blue:238 alpha:0.8]];
	[aboveView setTag:123];
	[self.table addSubview:aboveView];
    [self.table addSubview:headerView];
    
    activtyIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activtyIndicator.frame = CGRectMake(45, -kRefreshViewHeight2/4-10, 30, 30);
    [headerView addSubview:activtyIndicator];
    [activtyIndicator hidesWhenStopped];
    refreshing = NO;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    self.table = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadCategoriesintoArrays];
    [self refreshData];
    [self.table deselectRowAtIndexPath:self.table.indexPathForSelectedRow animated:YES];
    sideMenu.shadowColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mainshadowright.png"]];
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(void)reloadTableData {
    [self performSelectorInBackground:@selector(loadCategoriesintoArrays) withObject:nil];
}
-(void)loadCategoriesintoArrays {

    /*
    NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:kEventsList];
    eventsArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    [allEventsArray removeAllObjects];
    for (int i=0; i<eventsArray.count; i++) {
        AMEventObject *eventObj = [eventsArray objectAtIndex:i];
        if([eventObj.isParticipant isEqualToString:@"YES"] && [eventObj.activityType2 isEqualToString:@"Created an event at"]) {
            [allEventsArray addObject:eventObj];
        }
    }

    for (int i=0; i<allEventsArray.count; i++) {
        for(int j=i+1;j<allEventsArray.count-1 ;j++){
            AMEventObject *evntObj1 = [allEventsArray objectAtIndex:j];
            AMEventObject *evntObj2 = [allEventsArray objectAtIndex:j+1];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
            
            NSDate *date1 = [dateFormatter dateFromString:evntObj1.startingTime];
            NSDate *date2 = [dateFormatter dateFromString:evntObj2.startingTime];
            
            if([date1 compare:date2] == NSOrderedDescending) {
                [allEventsArray replaceObjectAtIndex:j withObject:evntObj2];
                [allEventsArray replaceObjectAtIndex:j+1 withObject:evntObj1];
            }
        }
    }
*/
    if(!allEventsArray)
        allEventsArray = [[NSMutableArray alloc]init];
    PFQuery *query = [PFQuery queryWithClassName:@"EventActivity"];
    [query whereKey:kToUser equalTo:[PFUser currentUser]];
    [query whereKey:kEventActivityType equalTo:kCreated];

        query.cachePolicy = kPFCachePolicyNetworkElseCache;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        allEventsArray = [NSMutableArray arrayWithArray:objects];
        [self loadDataintoTable];
        hud.hidden = YES;
        [refreshControl endRefreshing];
//        if(refreshing)
//        {
//            refreshing = NO;
//            [UIView animateWithDuration:0.2 animations:^{[self.table setContentInset:UIEdgeInsetsZero];}];
//            [activtyIndicator stopAnimating];
//        }
    }];
    
//    [self loadDataintoTable];
}

-(void)loadDataintoTable {
    
    [tableDataArray removeAllObjects];
    int i=0;
    PFObject *entry;
    switch (eventTypeSelected) {
        case 0:
            for (i=0; i<allEventsArray.count; i++) {
                entry = [allEventsArray objectAtIndex:i];
                if([[entry objectForKey:kAttendanceType] isEqualToString:kGoing])
                    [tableDataArray addObject:entry];
            }
            break;
        case 1:
            for (i=0; i<allEventsArray.count; i++) {
                entry = [allEventsArray objectAtIndex:i];
                if([[entry objectForKey:kAttendanceType] isEqualToString:kMaybe])
                    [tableDataArray addObject:entry];
            }
            break;
        case 2:
            [tableDataArray addObjectsFromArray:allEventsArray];
            break;
        default:
            break;
    }
    [self.table reloadData];
}

-(void)changeTypeofEvent:(UIButton *)sender {
    
    [goingButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"rightTab.png"]]];
    [mayBeButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"rightTab.png"]]];
    [allButton setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"rightTab.png"]]];

    switch (sender.tag) {
        case 100:
//            bottomImageView.image = [UIImage imageNamed:@"going.png"];
            eventTypeSelected = kGoingType;
            [goingButton setBackgroundColor:[UIColor clearColor]];
            break;
        
        case 101:
//            bottomImageView.image = [UIImage imageNamed:@"maybe.png"];
            eventTypeSelected = kMayBeType;
           [mayBeButton setBackgroundColor:[UIColor clearColor]];
            break;
            
        case 102:
//            bottomImageView.image = [UIImage imageNamed:@"all.png"];
            eventTypeSelected = kAllEventsType;
            [allButton setBackgroundColor:[UIColor clearColor]];
            break;
            
        default:
            break;
    }
     
    [self loadDataintoTable];
}

#pragma mark - UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 103;
}
- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    tableView.separatorColor = [UIColor clearColor];
    return tableDataArray.count;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    
    AMRightViewCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[AMRightViewCustomCell alloc]initWithFrame:CGRectZero];
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 50 , 320, 4)];
        imgView.image = [UIImage imageNamed:@"divider.png"];
//        [cell addSubview:imgView];
    }
//    AMEventObject *obj = [tableDataArray objectAtIndex:indexPath.row];
    PFObject *entry  = [tableDataArray objectAtIndex:indexPath.row];
    cell.eventName.text = [entry objectForKey:kNameofEvent];
    
    cell.eventName.highlightedTextColor = [UIColor lightTextColor];
    cell.eventTime.highlightedTextColor = [UIColor lightTextColor];
    
    if([[entry objectForKey:kAttendanceType] isEqualToString:kGoing])
        cell.statusControl.selectedSegmentIndex = 0;
    else if ([[entry objectForKey:kAttendanceType] isEqualToString:kMaybe])
        cell.statusControl.selectedSegmentIndex = 1;
    else if ([[entry objectForKey:kAttendanceType] isEqualToString:kNotGoing])
        cell.statusControl.selectedSegmentIndex = 2;
    else
        [cell.statusControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
    cell.statusControl.tag = indexPath.row+1000;
    [cell.statusControl addTarget:self action:@selector(statusOfAttendanceChanged:) forControlEvents:UIControlEventValueChanged];
    
    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
    NSDate *startingDate = [dateFormatter dateFromString:[entry objectForKey:kStartingTime]];
    NSDate *endingDate = [dateFormatter dateFromString:[entry objectForKey:kEndingTime]];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit
                                               fromDate:startingDate
                                                 toDate:endingDate
                                                options:0];
    NSInteger hours = components.hour;
    NSInteger days = components.day;
    NSInteger months = components.month;
    NSInteger years = components.year;
    
    NSString *endTimeString ;
    if( hours && hours >= 1)
        endTimeString =[NSString stringWithFormat:@"- %i hour",hours];
    else
        if(hours)
            endTimeString =[NSString stringWithFormat:@"- %i hours",hours];
    else
            endTimeString =@"";
    if(days)
        endTimeString = [NSString stringWithFormat:@"- %i days",days];
    if(days == 1)
        endTimeString = [NSString stringWithFormat:@"- %i day",days];
    if(months)
        endTimeString = [NSString stringWithFormat:@"- %i months",months];
    if(months == 1)
        endTimeString = [NSString stringWithFormat:@"- %i month",months];
    if(years)
        endTimeString = [NSString stringWithFormat:@"- %i years",years];
    if(years == 1)
        endTimeString = [NSString stringWithFormat:@"- %i year",years];
    
    cell.eventTime.text = [NSString stringWithFormat:@"%@ %@",[entry objectForKey:kStartingTime],endTimeString];
    
    UIImageView *bgView=[[UIImageView alloc]initWithFrame:cell.bounds];
    
    NSInteger n = indexPath.row;
    if(n & 1)
        [bgView setImage:[UIImage imageNamed:@"rightCellBg2.png"]];
    else
        [bgView setImage:[UIImage imageNamed:@"rightCellBg1.png"]];
    [tableView setSeparatorColor:[UIColor clearColor]];
    cell.backgroundView = bgView;
    
    UIView *selectedCellView = [[UIView alloc]initWithFrame:cell.frame];
    selectedCellView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tapped.png"]];
    [cell setSelectedBackgroundView:selectedCellView];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    AMEventViewerController *eventViewerViewController = [[AMEventViewerController alloc]init];
//    
//    eventViewerViewController.event = [tableDataArray objectAtIndex:indexPath.row];
    
    AMDetailEventViewController *eventViewerViewController = [[AMDetailEventViewController alloc]init];
    eventViewerViewController.eventData = [tableDataArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:eventViewerViewController animated:YES];
    NSArray *controllers = [NSArray arrayWithObject:eventViewerViewController];;
    self.sideMenu.navigationController.viewControllers = controllers;
    [self.sideMenu setMenuState:MFSideMenuStateClosed];
    [eventViewerViewController setupMenuBarButtonItems];
}


#pragma mark scrollview methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
	
	if (!refreshing ){
		
		CGFloat fraction = scrollView.contentOffset.y / -(kRefreshViewHeight2-10);
		if (fraction < 0) fraction = 0;
		if (fraction > 1) fraction = 1;
		if (fraction == 1)[topLabel setText:@"Release to refresh..."];
		else [topLabel setText:@"Pull down to refresh..."];
	}
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (scrollView.contentOffset.y < -kRefreshViewHeight2)
        [self refreshData];
}
-(void)refreshData{
//    refreshing = YES;
//    [activtyIndicator startAnimating];
//    [topLabel setText:@"Updating..."];
//    [UIView animateWithDuration:0.2 animations:^{[self.table setContentInset:UIEdgeInsetsMake(kRefreshViewHeight2-10, 0, 0, 0)];}];
     [self loadCategoriesintoArrays];
}
-(void)fetchEvents{
   
//    if(refreshing)
//    {
//        refreshing = NO;
//        [UIView animateWithDuration:0.2 animations:^{[self.table setContentInset:UIEdgeInsetsZero];}];
//        [activtyIndicator stopAnimating];
//    }
}

-(void)statusOfAttendanceChanged:(UISegmentedControl *)control{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    [hud setDimBackground:NO];
    [hud setLabelText:@"Loading..."];
    int selectedIndex = control.tag - 1000;
    NSString *selectedStatus;
    if(control.selectedSegmentIndex ==0)
        selectedStatus = kGoing;
    else if(control.selectedSegmentIndex == 1)
        selectedStatus = kMaybe;
    else
        selectedStatus = kNotGoing;
    
    PFObject *entry = [tableDataArray objectAtIndex:selectedIndex];
    [entry setObject:selectedStatus forKey:kAttendanceType];
    [entry saveInBackgroundWithBlock:^(BOOL success,NSError *error){
        
        if(!success && error)
        {
            hud.hidden = YES;
            [AMUtility showAlertwithTitle:@"Error" andMessage:error.localizedDescription];
        }
        else
        {
            [self updateOtherEntriesStatuswithParentEntry:entry withStatus:selectedStatus];
            [self loadCategoriesintoArrays];
            [[NSNotificationCenter defaultCenter]postNotificationName:kReloadtableData object:nil];
        }
    }];
}
-(void)updateOtherEntriesStatuswithParentEntry:(PFObject *)entry withStatus:(NSString *)status{
    PFQuery *query  =[PFQuery queryWithClassName:kEventActivity];
    [query whereKey:kObjectId notEqualTo:[entry objectId]];
    [query whereKey:kParent equalTo:[entry objectForKey:kParent]];
    [query whereKey:kToUser equalTo:[PFUser currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array,NSError *err){
        if(err)
            [AMUtility showAlertwithTitle:@"Error" andMessage:err.localizedDescription];
        else
        {
            for (int i=0; i<array.count; i++) {
                PFObject *obj = [array objectAtIndex:i];
                [obj setObject:status forKey:kAttendanceType];
                [obj saveInBackground];
            }
        }
    }];
}
@end