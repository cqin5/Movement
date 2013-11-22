//
//  LeftController.m
//  DDMenuController
//
//  Created by Devin Doty on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LeftController.h"
#import "AMAppDelegate.h"

#import "AMLeftViewCustomCell.h"
#import "AMCreateEventController.h"
#import "AMSearchController.h"
#import "AMConstants.h"
#import "AMGridView.h"
#import "AMUtility.h"
#import "AMEventObject.h"
#import "AMPlaceObject.h"
#import "AMDownloadMngr.h"
#import <QuartzCore/QuartzCore.h>
#import "AMProfileViewerCusotmObject.h"
#import "MBProgressHUD.h"

#import "AMPlaceViewController.h"
#import "AMProfileViewer.h"
#import "OAuthConsumer.h"
#import "AMConstants.h"

@interface LeftController ()
{
    AMGridView *gridView;
    SearchType searchType;
    MBProgressHUD *progress;
    NSURLConnection *theConnection;
}
@end


@implementation LeftController

@synthesize tableView=_tableView;
@synthesize searchBar1,sideMenu,searchDisplayController1;

- (id)init {
    if ((self = [super init])) {
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
    selectedRow = 0;
    if (!_tableView) {
//        self.navigationController.navigationBarHidden = YES;
        overlayView = [[UIView alloc]initWithFrame:CGRectMake(0, 46, 320, kScreenHeight)];
        overlayView.backgroundColor = [UIColor whiteColor];
        
        CGRect frame = self.view.bounds;
        frame.origin.y = frame.origin.y + 46;
        UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        tableView.delegate = (id<UITableViewDelegate>)self;
        tableView.dataSource = (id<UITableViewDataSource>)self;
        [self.view addSubview:tableView];
        self.tableView = tableView;
        
        if(isPhone568)
            [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-568h.png"]]];
        else
            [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
        UIView *view = [[UIView alloc]initWithFrame:self.tableView.bounds];
        view.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundView = view;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        overlayView.alpha = 0.0;
        [self.view insertSubview:overlayView atIndex:0];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0] ;
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        
        searchBar1 = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 0, 270, 46)];
        searchBar1.backgroundColor = [UIColor clearColor];
        searchBar1.barStyle = UIBarStyleBlackTranslucent;
        
        [searchBar1 setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_field.png"] forState:UIControlStateNormal];
        
        [searchBar1 setBackgroundImage:[UIImage imageNamed:@"bg.png"]];

        
        searchBar1.delegate = self;
        [self.view addSubview:searchBar1];
        searchBar1.placeholder = @"";
        
        searchDisplayController1 = [[UISearchDisplayController alloc]initWithSearchBar:searchBar1 contentsController:nil];
        searchDisplayController1.delegate = self;
        [searchDisplayController1 setActive:NO animated:NO];
        
        addImage = [[UIImageView alloc]initWithFrame:CGRectMake(25, self.view.frame.size.height - 91/2, 31, 31)];
        addImage.image = [UIImage imageNamed:@"create.png"];
        
        createEventLabel = [[UILabel alloc]initWithFrame:CGRectMake(25, self.view.frame.size.height - 91/2+9, 200, 31)];
        createEventLabel.text = @"Create a new event";
        createEventLabel.textColor = [UIColor whiteColor];
        createEventLabel.backgroundColor = [UIColor clearColor];
        createEventLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18];
        [createEventLabel setHighlightedTextColor:[UIColor whiteColor]];
        
        
//        UIImageView *dividerImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height - (91/2)- 4, 320, 4)];
//        dividerImg.image = [UIImage imageNamed:@"divider.png"];
//        [self.view addSubview:dividerImg];
        
//        [self.view addSubview:addImage];

        
        createButton = [UIButton buttonWithType:UIButtonTypeCustom];
        createButton.frame = CGRectMake(0, self.view.frame.size.height - 91/2, 270, 50);
        [createButton addTarget:self action:@selector(createButtonTapped) forControlEvents:UIControlEventTouchUpInside];
        [createButton setBackgroundImage:[UIImage imageNamed:@"tapped.png"] forState:UIControlStateHighlighted];
//        [createButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
//        [createButton setTitle:@"Create a new event" forState:UIControlStateNormal];
//        [createButton.titleLabel setFont:[UIFont fontWithName:@"MyriadPro-Semibold" size:20]];
//        [createButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
        [self.view addSubview:createButton];
        [self.view addSubview:createEventLabel];
    }
    NSArray *itemArray = [NSArray arrayWithObjects: @"All", @"Places", @"People",@"Events", nil];
    searchTypeSegControl = [[UISegmentedControl alloc]initWithItems:itemArray];
    searchTypeSegControl.frame = CGRectMake(0, 0, 320, 30);
    searchTypeSegControl.segmentedControlStyle =  UISegmentedControlStyleBar;
    searchTypeSegControl.selectedSegmentIndex = 0;
    [searchTypeSegControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];

    [searchTypeSegControl setBackgroundImage:[UIImage imageNamed:@"left_segUnselected.png"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [searchTypeSegControl setBackgroundImage:[UIImage imageNamed:@"left_segSelected.png"] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    UIColor *buttonColor = [UIColor whiteColor];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                buttonColor,UITextAttributeTextColor,
                                [UIFont fontWithName:@"HelveticaNeue-Light" size:13],UITextAttributeFont,
                                nil];
    [searchTypeSegControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
//    [searchTypeSegControl setDividerImage:[UIImage imageNamed:@"rightDivider.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
//    [searchTypeSegControl setDividerImage:[UIImage imageNamed:@"leftDivider.png"] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [searchTypeSegControl setDividerImage:[UIImage imageNamed:@"left_segUnselected.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    
    [overlayView addSubview:searchTypeSegControl];
    searchType = kAll;
    finalData = [[NSMutableArray alloc]init];
    queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:5];
    gridView = [[AMGridView alloc]init];
    gridView.gridViewDelegate = self;
    [gridView setBackgroundColor:[UIColor clearColor]];
    [gridView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    [overlayView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    placeSearchDone = NO;
    friendsSearchDone = NO;
    eventsSearchDone = NO;
    isSearchingHasBegun = NO;
    
    placeDetails = [[NSMutableArray alloc]init];
    personDetails = [[NSMutableArray alloc]init];
      
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    sideMenu.shadowColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"mainshadowleft.png"]];
}
- (void)viewDidUnload {
    [super viewDidUnload];
    self.tableView = nil;
}


-(void)createButtonTapped {
    
//    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:1 inSection:0];
//    [self.tableView selectRowAtIndexPath:indexpath animated:YES scrollPosition:UITableViewScrollPositionNone];
    
    AMAppDelegate *appDelegate =(AMAppDelegate *) [[UIApplication sharedApplication]delegate];
    NSArray *controllers = [NSArray arrayWithObject:appDelegate.viewController2];;
//    self.sideMenu.navigationController.viewControllers = controllers;
    [self.sideMenu setMenuState:MFSideMenuStateClosed];

    
//    DDMenuController *menuController = (DDMenuController*)((AMAppDelegate*)[[UIApplication sharedApplication] delegate]).menuController;
    
//    [menuController setRootController:appDelegate.viewController2_navigation animated:YES];
    AMCreateEventController *createEventController = [[AMCreateEventController alloc]init];
    UINavigationController *naviController = [[UINavigationController alloc]initWithRootViewController:createEventController];
    naviController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.sideMenu.navigationController presentModalViewController:naviController animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    if(cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//    }

    AMLeftViewCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[AMLeftViewCustomCell alloc]initWithFrame:CGRectZero];
    }

    
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.highlightedTextColor = [UIColor lightTextColor];
    cell.textLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18];
    
    UIView *selectedCellView = [[UIView alloc]initWithFrame:cell.frame];
    selectedCellView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"tapped.png"]];
    [cell setSelectedBackgroundView:selectedCellView];
//    tableView.separatorColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"divider.png"]];
  
    
    switch (indexPath.row) {
        case 0:
//            cell.imageView.image = [UIImage imageNamed:@"now-t.png"];
//            cell.imageView.highlightedImage = [UIImage imageNamed:@"now.png"];
            cell.textLabel.text = @"Now";
            break;
        case 1:
//            cell.imageView.image = [UIImage imageNamed:@"glance-t.png"];
//            cell.imageView.highlightedImage = [UIImage imageNamed:@"glance.png"];
            cell.textLabel.text = @"Timeline";
            break;
//        case 2:
//            cell.textLabel.text = @"Search";
//            break;
        case 2:
//            cell.imageView.image = [UIImage imageNamed:@"settings-t.png"];
//            cell.imageView.highlightedImage = [UIImage imageNamed:@"settings.png"];
            cell.textLabel.text = @"Me";
            break;
        case 3:
//            cell.imageView.image = [UIImage imageNamed:@"me-t.png"];
//            cell.imageView.highlightedImage = [UIImage imageNamed:@"me.png"];
            cell.textLabel.text = @"Settings";
            break;
        default:
            break;
    }
    return cell;
    
}

//- (NSString*)tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section {
//    return @"Automoose";
//}


#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 2;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 91/2;
//}
- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    

//    DDMenuController *menuController = (DDMenuController*)((AMAppDelegate*)[[UIApplication sharedApplication] delegate]).menuController;
    AMAppDelegate *appDelegate =(AMAppDelegate *) [[UIApplication sharedApplication]delegate];
    selectedRow = indexPath.row;
    NSArray *controllers;

        switch (indexPath.row) {
        case 0:
                controllers = [NSArray arrayWithObject:appDelegate.viewController1];
            break;
        case 1:
                controllers = [NSArray arrayWithObject:appDelegate.viewController2];
            break;
        case 3:
                controllers = [NSArray arrayWithObject:appDelegate.viewController5];
            break;
        case 2:
                controllers = [NSArray arrayWithObject:appDelegate.viewController4];
        default:
            break;
    }
    self.sideMenu.navigationController.viewControllers = controllers;
    [self.sideMenu setMenuState:MFSideMenuStateClosed];
}

#pragma mark search delegate methods
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(imageDownloaded:) name:@"ImageDownloaded" object:nil];
    
    [self.sideMenu setShadowEnabled:NO];
    [self.sideMenu setPanMode:MFSideMenuPanModeNone];
    [searchBar1 setShowsCancelButton:YES animated:YES];
    [self.sideMenu setMenuWidth:320 animated:YES];
    
    [self.view bringSubviewToFront:overlayView];
    overlayView.alpha = 1.0;
    isSearchingHasBegun = NO;
    
    searchBar.showsCancelButton = YES;
    //Iterate the searchbar sub views
    for (UIView *subView in searchBar.subviews) {
        //Find the button
        if([subView isKindOfClass:[UIButton class]])
        {
            //Change its properties
            UIButton *cancelButton = (UIButton *)[searchBar.subviews lastObject];
            [cancelButton setBackgroundImage:[UIImage imageNamed:@"sbCancelBG.png"] forState:UIControlStateNormal];
            [cancelButton setBackgroundImage:[UIImage imageNamed:@"sbCancelBG.png"] forState:UIControlStateHighlighted];
            [cancelButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
            [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            break;
        }
    }
}
-(void)setUpSearchView {
    
//    self.view.frame = CGRectMake(0, 0, 320, kScreenHeight);
//    [self.view addSubview:overlayView];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    return YES;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    if(searchBar.text.length)
    {
        [self searchWithString:searchBar.text];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert!" message:@"Please enter search term" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }

}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
//    self.navigationController.navigationBarHidden = YES;
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"ImageDownloaded" object:nil];
    [self.sideMenu setPanMode:MFSideMenuPanModeDefault];
    overlayView.alpha = 0.0;
    for(UIView *view in [gridView subviews])
    {
        [view removeFromSuperview];
    }
    [self.view sendSubviewToBack:overlayView];
    searchBar.text = @"";
//    searchBar.frame = CGRectMake(0, 0, 270, 46);
    [searchBar resignFirstResponder];
    [searchBar setShowsCancelButton:NO];
    [self.sideMenu setShadowEnabled:YES];
    [self.sideMenu setMenuWidth:270];
    self.view.frame = CGRectMake(0, 0, 270, kScreenHeight);
    
}


-(IBAction)segmentedControlValueChanged:(UISegmentedControl *)segmentedControl
{
    [finalData removeAllObjects];
    switch (segmentedControl.selectedSegmentIndex) {
        case 0:
            searchType = kAll;
            if(!placeSearchDone && isSearchingHasBegun)
            {
                [self fetchPlaceswithString:searchBar1.text];
                placeSearchDone = YES;
            }
            else
                [self addPlacestoFinalArray];
            if(!friendsSearchDone && isSearchingHasBegun)
            {
                [self performSelectorInBackground:@selector(fetchFriendswithString:) withObject:searchBar1.text];
                friendsSearchDone = YES;
            }
            else
                [self addPeopleToFinalArray];
            if(!eventsSearchDone && isSearchingHasBegun)
            {
                eventsSearchDone = YES;
                [self performSelectorInBackground:@selector(fetchEventswithString:) withObject:searchBar1.text];
            }
            else
                [self addEventstoFinalArray];
            break;
        case 1:
            searchType = kPlaces;
            if(!placeSearchDone && isSearchingHasBegun)
            {
                [self fetchPlaceswithString:searchBar1.text];
                placeSearchDone = YES;
            }
            else
                [self addPlacestoFinalArray];
            break;
        case 2:
            searchType = kPeople;
            if(!friendsSearchDone && isSearchingHasBegun)
            {
                [self performSelectorInBackground:@selector(fetchFriendswithString:) withObject:searchBar1.text];
                friendsSearchDone = YES;
            }
            else
                [self addPeopleToFinalArray];
            break;
        case 3:
            searchType = kEvents;
            if(!eventsSearchDone && isSearchingHasBegun)
            {
                eventsSearchDone = YES;
                [self performSelectorInBackground:@selector(fetchEventswithString:) withObject:searchBar1.text];
            }
            else
                [self addEventstoFinalArray];
            
            break;
        default:
            break;
    }
    
    for(UIView *view in [gridView subviews])
    {
        [view removeFromSuperview];
    }
    if(finalData.count)
    {
        [gridView setFrame:CGRectMake(0, 30, 320, kScreenHeight - 30) andWithData:finalData];
        
        [overlayView addSubview:gridView];
        
    }
}

-(void)searchWithString:(NSString *)searchString
{
    placeSearchDone = NO;
    friendsSearchDone = NO;
    eventsSearchDone = NO;
    isSearchingHasBegun = YES;
    [finalData removeAllObjects];
    [placeDetails removeAllObjects];
    [personDetails removeAllObjects];
    
    placesData = nil;
    eventsData = nil;
    friendsData = nil;
    
    if(!gridView)
    {
        gridView = [[AMGridView alloc]init];
        gridView.gridViewDelegate = self;
        [gridView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];
    }
    switch (searchType) {
        case 0:
            
            [self fetchPlaceswithString:searchString];
            [self performSelectorInBackground:@selector(fetchFriendswithString:) withObject:searchString];
            [self performSelectorInBackground:@selector(fetchEventswithString:) withObject:searchString];
            break;
        case 1:
            [self fetchPlaceswithString:searchString];
            placeSearchDone = YES;
            friendsSearchDone = NO;
            eventsSearchDone = NO;
            break;
        case 2:
            [self performSelectorInBackground:@selector(fetchFriendswithString:) withObject:searchString];
            placeSearchDone = NO;
            friendsSearchDone = YES;
            eventsSearchDone = NO;
            break;
        case 3:
            placeSearchDone = NO;
            friendsSearchDone = NO;
            eventsSearchDone = YES;
            [self performSelectorInBackground:@selector(fetchEventswithString:) withObject:searchString];
        default:
            break;
    }
    
    [overlayView addSubview:gridView];

//    [self downloadPlacesImages];
}
#pragma mark adding data to final array -begin
-(void)addDatatoFinalArray
{
    [finalData removeAllObjects];
    switch (searchType) {
        case 0:
            [self addPlacestoFinalArray];
            [self addPeopleToFinalArray];
            [self addEventstoFinalArray];
            break;
        case 1:
            [self addPlacestoFinalArray];
            break;
        case 2:
            [self addPeopleToFinalArray];
            break;
        case 3:
            [self addEventstoFinalArray];
            break;
        default:
            break;
    }
}

-(void)addPeopleToFinalArray
{
    for(int i=0 ; i<friendsData.count;i++)
    {
        
        PFUser *user = [friendsData objectAtIndex:i];
        PFFile *profileImage = [user objectForKey:kProfileImage];
        NSData *imgData = [profileImage getData];
        UIImage *image = [UIImage imageWithData:imgData];
        NSString *nameoFriend = [user objectForKey:kDisplayName];
        NSDictionary *dictionary2 = [NSDictionary dictionaryWithObjectsAndKeys:image,kImage,nameoFriend,kName,[NSNumber numberWithInteger:kPeople],kType,[NSNumber numberWithInt:i],kIndex, nil];
        [finalData addObject:dictionary2];
    }
}

-(void)addEventstoFinalArray
{
    for(int i=0; i< eventsData.count;i++)
    {
        AMEventObject *eventObject = [eventsData objectAtIndex:i];
        NSDictionary *dictionary2 = [NSDictionary dictionaryWithObjectsAndKeys:eventObject.eventImage ,kImage,eventObject.nameoftheEvent,kName,[NSNumber numberWithInteger:kEvents],kType,[NSNumber numberWithInt:i],kIndex, nil];
        [finalData addObject:dictionary2];
    }
}
-(void)addPlacestoFinalArray
{
    for (int i=0; i<placesData.count; i++) {
        AMPlaceObject *placeObj = [placesData objectAtIndex:i];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:placeObj.placeIcon,kImage,placeObj.nameofPlace,kName,[NSNumber numberWithInteger:kPlaces],kType,[NSNumber numberWithInt:i],kIndex,placeObj.iconUrl,kIconUrl,[NSNumber numberWithInt:placeObj.isImageDownloaded], kIsImageDownloaded,nil];
        [finalData addObject:dictionary];
    }
}
#pragma mark adding data to final array -end

-(void)detectedTouches
{
    [searchBar1 resignFirstResponder];
}
-(void)tappedonGridCellWithIndex:(int )index
{
    [searchBar1 resignFirstResponder];
    NSDictionary *dict = [finalData objectAtIndex:index];
    int type = [[dict objectForKey:kType]intValue];
    int index_local = [[dict objectForKey:kIndex]intValue];
    switch (searchType) {
        case 0:
            switch (type) {
                case 1:
                    [self fetchDetailsofPlace:[placesData objectAtIndex:index_local]];
                    break;
                case 2:
                    progress = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
                    [progress setDimBackground:YES];
                    [progress setLabelText:@"Loading"];
                    [self.view bringSubviewToFront:progress];
                    [self performSelectorInBackground:@selector(fetchuserTimeLineofUser:) withObject:[friendsData objectAtIndex:index_local]];
                    break;
                case 3:
                    [self showDetailsofEvent:[eventsData objectAtIndex:index_local]];
                    break;
                default:
                    break;
            }
            break;
        case 1:
            [self fetchDetailsofPlace:[placesData objectAtIndex:index_local]];
            break;
        case 2:
            progress = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
            [progress setDimBackground:YES];
            [progress setLabelText:@"Loading"];
            [self.view bringSubviewToFront:progress];
            [self fetchuserTimeLineofUser:[friendsData objectAtIndex:index_local]];
            break;
        case 3:
            [self showDetailsofEvent:[eventsData objectAtIndex:index_local]];
            break;
        default:
            break;
    }
}

-(void)fetchuserTimeLineofUser:(PFUser *)user
{
    AMProfileViewer *profileViewer = [[AMProfileViewer alloc]init];
    UINavigationController *naviContrlr = [[UINavigationController alloc]initWithRootViewController:profileViewer];
    [self presentModalViewController:naviContrlr animated:YES];
    [profileViewer showCancelButton];
    profileViewer.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [profileViewer showDetailsofUser:user];
    progress.hidden = YES;

    
    /*
    AMProfileViewerCusotmObject *obj;
    BOOL found = NO;
    for(obj in personDetails)
    {
        if([obj.nameofProfile isEqualToString:[user objectForKey:kDisplayName]])
        {
            found = YES;
            break;
        }
    }
    if(!found)
    {
        PFFile *profImage = [user objectForKey:kProfileImage];
        [profImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
            NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[user objectId],kObjectId,[user objectForKey:kDisplayName],kDisplayName,[user objectForKey:kFacebookId],kFacebookId,data,kProfileImage,nil];
            [AMUtility fetchTimelineofUserwithData:dict block:^(BOOL success,NSError *error,AMProfileViewerCusotmObject *object)
             {
                 [personDetails addObject:object];
                 AMProfileViewer *profileViewer = [[AMProfileViewer alloc]init];
                 UINavigationController *naviContrlr = [[UINavigationController alloc]initWithRootViewController:profileViewer];
                 [self presentModalViewController:naviContrlr animated:YES];
                 naviContrlr.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                 self.navigationController.navigationBarHidden = NO;
                 profileViewer.user = user;

                 [profileViewer.followButton setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
                 profileViewer.followButton.tag = 100;
                 [profileViewer.inviteButton setEnabled:NO];
                 
                 profileViewer.dataArray = object.eventTimelineArray;
                 profileViewer.imageview.image = [UIImage imageWithData:object.profileImageData];
                 profileViewer.name.text = object.nameofProfile;
                 profileViewer.followingCount.text = object.followingCount;
                 profileViewer.followersCount.text = object.follwersCount;
                 profileViewer.eventsCount.text = object.eventsCount;
                 profileViewer.facebookID = object.facebookID;
                 
                 NSArray *friendsArray = [[NSUserDefaults standardUserDefaults]objectForKey:kFollowing];
                 for(int i=0;i<friendsArray.count;i++)
                 {
                     NSDictionary *dict = [friendsArray objectAtIndex:i];
                     if([[dict objectForKey:kObjectId] isEqualToString:[user objectId]])
                     {
                         [profileViewer.followButton setBackgroundImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateNormal];
                         [profileViewer.inviteButton setEnabled:YES];
                         profileViewer.followButton.tag = 101;
                         profileViewer.navigationItem.rightBarButtonItem.enabled = YES;
                         break;
                     }
                     else
                     {
                         [profileViewer.followButton setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
                         profileViewer.followButton.tag = 100;
                         [profileViewer.inviteButton setEnabled:NO];
                     }
                 }
                 [progress setHidden:YES];
             }];
        }];
    }
    else{
        AMProfileViewer *profileViewer = [[AMProfileViewer alloc]init];
        UINavigationController *naviContrlr = [[UINavigationController alloc]initWithRootViewController:profileViewer];
        [self presentModalViewController:naviContrlr animated:YES];
//        [self.navigationController pushViewController:profileViewer animated:YES];
//        self.navigationController.navigationBarHidden = NO;
        profileViewer.user = user;
        
        [profileViewer.followButton setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
        profileViewer.followButton.tag = 100;
        [profileViewer.inviteButton setEnabled:NO];
        
        profileViewer.dataArray = obj.eventTimelineArray;
        profileViewer.imageview.image = [UIImage imageWithData:obj.profileImageData];
        profileViewer.name.text = obj.nameofProfile;
        profileViewer.followingCount.text = obj.followingCount;
        profileViewer.followersCount.text = obj.follwersCount;
        profileViewer.eventsCount.text = obj.eventsCount;
        profileViewer.facebookID = obj.facebookID;

        
        NSArray *friendsArray = [[NSUserDefaults standardUserDefaults]objectForKey:kFollowing];
        for(int i=0;i<friendsArray.count;i++)
        {
            NSDictionary *dict = [friendsArray objectAtIndex:i];
            if([[dict objectForKey:kObjectId] isEqualToString:[user objectId]])
            {
                [profileViewer.followButton setBackgroundImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateNormal];
                [profileViewer.inviteButton setEnabled:YES];
                profileViewer.followButton.tag = 101;
                profileViewer.navigationItem.rightBarButtonItem.enabled = YES;
                break;
            }
            else
            {
                [profileViewer.followButton setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
                profileViewer.followButton.tag = 100;
                [profileViewer.inviteButton setEnabled:NO];
            }
            
        }
        [progress setHidden:YES];
    }
*/
}
-(void)showDetailsofEvent:(AMEventObject *)eventObj
{
    /*
    AMEventViewerController *evntContrl = [[AMEventViewerController alloc]init];
    evntContrl.eventObject = eventObj;
    evntContrl.indexofEvent = 0;
    evntContrl.isEventEditingAllowed = NO;
    [self.navigationController pushViewController:evntContrl animated:YES];
    */
}
#pragma mark friends fetch
-(void)fetchFriendswithString:(NSString *)searchString
{
    friendsData = [AMUtility fetchPeopleFromParseWithString:[searchString lowercaseString]];
    [finalData removeAllObjects];
    [self addDatatoFinalArray];
    [gridView setFrame:CGRectMake(0, 30, 320, kScreenHeight - 30) andWithData:finalData];
    [overlayView addSubview:gridView];
    friendsSearchDone = YES;
}
#pragma mark events fetch

-(void)fetchEventswithString:(NSString *)searchString
{
    eventsData = [AMUtility fetchEventsofFriendsWithString:searchString];
    [finalData removeAllObjects];
    [self addDatatoFinalArray];
    [gridView setFrame:CGRectMake(0, 30, 320, kScreenHeight - 30) andWithData:finalData];
    [overlayView addSubview:gridView];
    eventsSearchDone = YES;
}
#pragma mark fetching places

-(void)fetchDetailsofPlace:(AMPlaceObject *)placeObj
{
    /*
    if(!placeObj.review.count)
    {
        progress = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
        [progress setDimBackground:YES];
        [progress setLabelText:@"Fetching place details"];
        selectedPlaceObj = placeObj;
        NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=true&key=%@",placeObj.placeId, kGOOGLE_API_KEY];
        NSURL *googleRequestURL=[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:googleRequestURL];
        theConnection = nil;
        responseData = nil;
        responseData = [[NSMutableData alloc]init];;
        theConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        theConnection.accessibilityHint = kPlaceDetails;
        if (!theConnection) {
            NSLog(@"Connection failure");
        }
    }
    else
  */
    {
        AMPlaceViewController *placeViewController = [[AMPlaceViewController alloc]init];
        placeViewController.placeObj = placeObj;
        UINavigationController *naviContrlr  = [[UINavigationController alloc]initWithRootViewController:placeViewController];
        naviContrlr.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentModalViewController:naviContrlr animated:YES];
        [progress setHidden:YES];
    }
    
}
-(void)downloadPlacesImages
{
    for(int i=0;i<placesData.count;i++)
    {
        AMPlaceObject *placeObj = [placesData objectAtIndex:i];
        if(!placeObj.isImageDownloaded)
        {
            if(![placeObj.iconUrl isEqualToString:@"NA"])
            {
                AMDownloadMngr *dwnldMngr = [[AMDownloadMngr alloc]initwithUrlString:placeObj.iconUrl withIndex:i+100];
                [queue addOperation:dwnldMngr];
            }
        }
    }
}

-(void)imageDownloaded:(NSNotification *)notification
{
    NSDictionary *dictionary = [notification object];
    NSData *data = [dictionary objectForKey:@"imageData"];
    NSInteger index = [[dictionary objectForKey:@"index"]intValue];
    UIImage *image = [UIImage imageWithData:data];
    
    CGFloat width = 100;
    CGFloat height = 100;
    if(image.size.width < 50)
        width = image.size.width;
    if(image.size.height < 50)
        height = image.size.height;
    CGSize newSize = CGSizeMake(width , height);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    UIImageView *imgView = (UIImageView *)[gridView viewWithTag:index+1000];
    [imgView setBackgroundColor:[UIColor lightTextColor]];
    [imgView.layer setCornerRadius:5];
    imgView.clipsToBounds = YES;
    imgView.image = nil;
    imgView.image = newImage;
    AMPlaceObject *placeObj = [placesData objectAtIndex:index-100];
    placeObj.placeIcon = newImage;
    placeObj.isImageDownloaded = 1;
    NSMutableArray *data2 = [NSMutableArray arrayWithArray:placesData];
    if(placeObj)
        [data2 replaceObjectAtIndex:index-100 withObject:placeObj];
}

-(void)fetchPlaceswithString:(NSString *)searchString
{
    responseData = nil;
    responseData = [[NSMutableData alloc]init];
    
    progress = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    [progress setDimBackground:YES];
    [progress setLabelText:@"Searching..."];
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude);
//    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(kTempLatitude,kTempLongitude);
    NSLog(@"Location : %f %f",location.latitude,location.longitude);
    NSString *urlString = [NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=%@&ll=%f,%f",searchString,location.latitude,location.longitude];
    NSURL *URL = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    OAConsumer *consumer = [[OAConsumer alloc] initWithKey:@"5hAr28GfcAGk62th0lcT4g" secret:@"Sg9crZHhRVbs7a8qKrThH5bthxQ"] ;
    OAToken *token = [[OAToken alloc] initWithKey:@"GrfqNU0al7Kn9UWb-PjhHWcgEG7of6f_" secret:@"qozFwIaEvhDtwWHEA2fzhzh60SI"] ;
    
    id<OASignatureProviding, NSObject> provider = [[OAHMAC_SHA1SignatureProvider alloc] init] ;
    NSString *realm = nil;
    
    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:URL
                                                                   consumer:consumer
                                                                      token:token
                                                                      realm:realm
                                                          signatureProvider:provider];
    [request prepare];
    theConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(!theConnection)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:@"Error in connection. Please try again." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
    }
    /*
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/nearbysearch/json?query=%@&sensor=true&location=%f,%f&radius=1000&types=%@&key=%@",searchString,location.latitude, location.longitude, @"food|cafe|hotel",kGOOGLE_API_KEY];
    NSURL *googleRequestURL=[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:googleRequestURL];
    theConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    theConnection.accessibilityHint = kPlacesFetching;
    if (!theConnection) {
        NSLog(@"Connection Failure");
    }
     */
}

#pragma mark connection delegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    progress.hidden = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//    if([connection.accessibilityHint isEqualToString:kPlacesFetching])
    {
        NSMutableArray *returnArray = [[NSMutableArray alloc]init];
        NSError *error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:kNilOptions
                              error:&error];
        if([json objectForKey:@"error"] != nil)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:[[json objectForKey:@"error"]objectForKey:@"text"] delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [alert show];
        }
        
        if(!error)
        {
            NSArray *places = [json objectForKey:@"businesses"];
            for (int i=0; i<[places count]; i++)
            {
                NSDictionary* place = [places objectAtIndex:i];
//                NSLog(@"%@",place);
                NSDictionary *geo = [place objectForKey:kLocation];
                UIImage *iconofRestaurant ;
                /*
                if([place objectForKey:kImage_url ] != nil)
                {
                    NSString *image_url = [place objectForKey:kImage_url];
                    NSURL *url = [NSURL URLWithString:image_url];
                    NSData *imgData = [NSData dataWithContentsOfURL:url];
                    iconofRestaurant = [UIImage imageWithData:imgData];
                }
                else
                 */
                iconofRestaurant = [UIImage imageNamed:@"place.png"];
                NSString *name=[place objectForKey:kPlace_name];
                NSString *vicinity=[place objectForKey:kAddress];
                NSDictionary *loc = [geo objectForKey:kCoordinate];
                CLLocationCoordinate2D placeCoord;
                placeCoord.latitude=[[loc objectForKey:kLatitude] doubleValue];
                placeCoord.longitude=[[loc objectForKey:kLongitude] doubleValue];
                
//                NSDictionary *locationDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithFloat:placeCoord.latitude],@"Latitude",[NSNumber numberWithFloat:placeCoord.longitude],@"Longitude",vicinity,@"Place", nil];
                NSString *iconUrl;
                if([place objectForKey:kImage_url ] != nil)
                    iconUrl = [place objectForKey:kImage_url];
                else
                    iconUrl =@"";
                NSString *rating = [place objectForKey:kRating];
                NSArray *addressArray =[geo objectForKey:kDisplay_address];
                NSMutableString *address = [[NSMutableString alloc]init];
                [addressArray enumerateObjectsUsingBlock:^(id obj,NSUInteger indx,BOOL *stop) {
                    NSString *value = (NSString *)obj;
                    if(indx != 0)
                        [address appendFormat:@",%@",value];
                    else
                        [address appendString:value];
                }];
                
                NSMutableString *categories = [[NSMutableString alloc]init];;
                NSArray *categoriesArray = [place objectForKey:kCategories];
                [categoriesArray enumerateObjectsUsingBlock:^(id object, NSUInteger indx, BOOL *stop){
                    NSArray *entry  = (NSArray *)object;
                    if(indx != 0)
                        [categories appendString:@","];
                    [categories appendFormat:@"%@",[entry objectAtIndex:0]];
                }];
                
                AMPlaceObject *placeObject = [[AMPlaceObject alloc]init];
                placeObject.nameofPlace = name;
                placeObject.placeIcon = iconofRestaurant;
                placeObject.latitude = placeCoord.latitude;
                placeObject.longitude = placeCoord.longitude;
                placeObject.rating = (rating?rating:@"0");
                placeObject.iconUrl = (iconUrl.length?iconUrl:@"NA");
                placeObject.isImageDownloaded = 0;
                placeObject.address = address;
                placeObject.phoneNumber = [place objectForKey:kDisplay_phone];
                placeObject.mobileUrl = [place objectForKey:kMobile_url];
                placeObject.categories = categories;
                [returnArray addObject:placeObject];
            }

            
            
            placesData = [returnArray mutableCopy];
            
            [finalData removeAllObjects];
            [self addDatatoFinalArray];
            [progress setHidden:YES];
            [gridView setFrame:CGRectMake(0, 30, 320, kScreenHeight - 30) andWithData:finalData];
            [overlayView addSubview:gridView];
            placeSearchDone = YES;
            [self downloadPlacesImages];
        }
    }
    /*
    else
    {
        AMPlaceObject *returnObj = selectedPlaceObj;
        
        NSError* error;
        NSDictionary* json = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        NSDictionary *results = [json objectForKey:@"result"];
        NSArray *photosArray = [results objectForKey:@"photos"];
        NSMutableArray *photoIdArray = [[NSMutableArray alloc]init];
        for (int i=0; i<photosArray.count; i++) {
            NSDictionary *dict = [photosArray objectAtIndex:i];
            [photoIdArray addObject:[dict objectForKey:@"photo_reference"]];
        }
        if(photoIdArray.count)
            returnObj.photoIdArray = photoIdArray;
        returnObj.phoneNumber = [results objectForKey:@"formatted_phone_number"];
        NSArray *reviews = [results objectForKey:@"reviews"];
        NSMutableArray *reviewArray = [[NSMutableArray alloc]init];
        for(int i=0;i<reviews.count;i++)
        {
            NSDictionary *review = [reviews objectAtIndex:i];
            NSString *reviewText = [review objectForKey:@"text"];
            NSArray *ratingsArray = [review objectForKey:@"aspects"];
            NSString *rating;
            if(ratingsArray.count)
            {
                NSDictionary *ratingDict = [ratingsArray objectAtIndex:0];
                rating = [ratingDict objectForKey:@"rating"];
            }
            else
            {
                rating = @"Not Available";
            }
            NSDictionary *finalReviewDict = [NSDictionary dictionaryWithObjectsAndKeys:reviewText,@"review",rating,@"rating", nil];
            [reviewArray addObject:finalReviewDict];
        }
        returnObj.review = reviewArray;
        //        NSLog(@"%@",photoIdArray);
        //        NSLog(@"****************");
        //        NSLog(@"%@",reviewArray);
        
        AMPlaceViewController *placeViewController = [[AMPlaceViewController alloc]init];
        placeViewController.placeObj = returnObj;
        //        [self.navigationController pushViewController:placeViewController animated:YES];
        UINavigationController *naviContrlr  = [[UINavigationController alloc]initWithRootViewController:placeViewController];
        
        [self presentModalViewController:naviContrlr animated:YES];
        [progress setHidden:YES];
    }
    */
}


@end
