//
//  AMSearchController.m
//  Automoose
//
//  Created by Srinivas on 12/2/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import "AMSearchController.h"
#import "AMUtility.h"
#import "AMConstants.h"
#import "AMEventObject.h"
#import "AMGridView.h"
#import "AMProfileViewer.h"
#import "AMPlaceObject.h"
#import "AMDownloadMngr.h"
#import <QuartzCore/QuartzCore.h>
#import "AMProfileViewerCusotmObject.h"
#import "MBProgressHUD.h"

#import "AMAppDelegate.h"
#import "AMPlaceViewController.h"
@interface AMSearchController ()
{
    AMGridView *gridView;
    SearchType searchType;
    MBProgressHUD *progress;
    NSURLConnection *theConnection;
}
@end

@implementation AMSearchController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Search", @"Search");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
        searchBar1.backgroundImage = [UIImage imageNamed:@"search-t.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(imageDownloaded:) name:@"ImageDownloaded" object:nil];
//    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"BeginSearch" object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(beginSearchAfterNotification:) name:@"BeginSearch" object:nil];
    searchType = kAll;
    finalData = [[NSMutableArray alloc]init];
    queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:5];
    gridView = [[AMGridView alloc]init];
    gridView.gridViewDelegate = self;
    placeSearchDone = NO;
    friendsSearchDone = NO;
    eventsSearchDone = NO;
    isSearchingHasBegun = NO;
    
    placeDetails = [[NSMutableArray alloc]init];
    personDetails = [[NSMutableArray alloc]init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark searching related
-(void)beginSearchAfterNotification:(NSNotification *)notification {
    [searchBar1 becomeFirstResponder];
    segmentControl.hidden = NO;
    isSearchingHasBegun = NO;
    searchBar1.showsCancelButton = YES;
    
//    [self searchWithString:[notification object]];
//    [self searchBarTextDidBeginEditing:searchBar1];
//    searchBar1.text = [notification object];
    
}
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    segmentControl.hidden = NO;
    isSearchingHasBegun = NO;
    searchBar.showsCancelButton = YES;
    
//    if(searchBar.text.length)
//    {
//        searchBar.showsCancelButton = YES;
//    }
//    else
//    {
//        searchBar.showsCancelButton = NO;
//    }
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
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
    searchBar1.text = @"";
    if([[self.view subviews] containsObject:gridView])
    {
        [gridView removeFromSuperview];
        gridView = nil;
    }
    isSearchingHasBegun = NO;
    [searchBar resignFirstResponder];
    [self.view removeFromSuperview];
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
        [gridView setFrame:CGRectMake(0, 73, 320, 294+44) andWithData:finalData];
        
        [self.view addSubview:gridView];
        segmentControl.hidden = NO;
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
    
    [self.view addSubview:gridView];
    segmentControl.hidden = NO;
    [self downloadPlacesImages];
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
//                   NSLog(@"%@",[placesData objectAtIndex:index_local]);
                    [self fetchDetailsofPlace:[placesData objectAtIndex:index_local]];
                    break;
                case 2:
                    progress = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
                    [progress setDimBackground:YES];
                    [progress setLabelText:@"Loading"];
                    [self.view bringSubviewToFront:progress];
//                    [self performSelectorInBackground:@selector(fetchuserTimeLineofUser:) withObject:[friendsData objectAtIndex:index_local]];
                    [self fetchuserTimeLineofUser:[friendsData objectAtIndex:index_local]];
                    break;
                case 3:
                    [self showDetailsofEvent:[eventsData objectAtIndex:index_local]];
                    break;
                default:
                    break;
            }
            break;
        case 1:
//            NSLog(@"%@",[placesData objectAtIndex:index_local]);
//            [self performSelectorInBackground:@selector(fetchDetailsofPlace:) withObject:[placesData objectAtIndex:index_local]];
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
}


-(void)fetchuserTimeLineofUser:(PFUser *)user
{   AMProfileViewerCusotmObject *obj;
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
//       obj = [AMUtility fetchTimelineofUser:user];
        [personDetails addObject:obj];
    }

    AMProfileViewer *profileViewer = [[AMProfileViewer alloc]init];
    UINavigationController *naviContrlr = [[UINavigationController alloc]initWithRootViewController:profileViewer];
//    [self.navigationController pushViewController:profileViewer animated:YES];
    [self presentModalViewController:naviContrlr animated:YES];
    profileViewer.dataArray = obj.eventTimelineArray;
    profileViewer.imageview.image = [UIImage imageWithData:obj.profileImageData];
    profileViewer.user = user;
    profileViewer.name.text = obj.nameofProfile;
    profileViewer.followingCount.text = obj.followingCount;
    profileViewer.followersCount.text = obj.follwersCount;
    profileViewer.eventsCount.text = obj.eventsCount;
    profileViewer.navigationItem.rightBarButtonItem.enabled = NO;
    profileViewer.followButton.hidden = NO;
    
    NSArray *friendsArray = [[NSUserDefaults standardUserDefaults]objectForKey:kFollowing];
    for(int i=0;i<friendsArray.count;i++)
    {
        NSDictionary *dict = [friendsArray objectAtIndex:i];
        if([[dict objectForKey:kObjectId] isEqualToString:[user objectId]])
        {
//            [profileViewer.followButton setTitle:@"Following" forState:UIControlStateNormal];
            profileViewer.followButton.enabled = NO;
            profileViewer.navigationItem.rightBarButtonItem.enabled = YES;
            break;
        }
        else
            profileViewer.navigationItem.rightBarButtonItem.enabled = NO;
    }
    [progress setHidden:YES];
}
-(void)showDetailsofEvent:(AMEventObject *)eventObj
{
    /* //Modifications
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
    friendsData = [AMUtility fetchPeopleFromParseWithString:searchString];
    [finalData removeAllObjects];
    [self addDatatoFinalArray];
    [gridView setFrame:CGRectMake(0, 73, 320, 294+44) andWithData:finalData];
    [self.view addSubview:gridView];
    friendsSearchDone = YES;
}
#pragma mark events fetch

-(void)fetchEventswithString:(NSString *)searchString
{
    eventsData = [AMUtility fetchEventsofFriendsWithString:searchString];
    [finalData removeAllObjects];
    [self addDatatoFinalArray];
    [gridView setFrame:CGRectMake(0, 73, 320, 294+44) andWithData:finalData];
    [self.view addSubview:gridView];
    eventsSearchDone = YES;
}
#pragma mark fetching places

-(void)fetchDetailsofPlace:(AMPlaceObject *)placeObj
{
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
    {
        AMPlaceViewController *placeViewController = [[AMPlaceViewController alloc]init];
        placeViewController.placeObj = placeObj;
//        [self.navigationController pushViewController:placeViewController animated:YES];
        UINavigationController *naviContrlr  = [[UINavigationController alloc]initWithRootViewController:placeViewController];
        
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
            AMDownloadMngr *dwnldMngr = [[AMDownloadMngr alloc]initwithUrlString:placeObj.iconUrl withIndex:i+100+1000];
            [queue addOperation:dwnldMngr];
        }
    }
}
    
-(void)imageDownloaded:(NSNotification *)notification
{
    NSDictionary *dictionary = [notification object];
    NSData *data = [dictionary objectForKey:@"imageData"];
    NSInteger index = [[dictionary objectForKey:@"index"]intValue];
    UIImage *image = [UIImage imageWithData:data];
    
    CGFloat width = 50;
    CGFloat height = 50;
    if(image.size.width < 50)
        width = image.size.width;
    if(image.size.height < 50)
        height = image.size.height;
    CGSize newSize = CGSizeMake(width , height);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    
    UIImageView *imgView = (UIImageView *)[gridView viewWithTag:index];
    [imgView setBackgroundColor:[UIColor lightTextColor]];
    [imgView.layer setCornerRadius:5];
    imgView.clipsToBounds = YES;
    imgView.image = nil;
    imgView.image = newImage;
    AMPlaceObject *placeObj = [placesData objectAtIndex:index-1100];
    placeObj.placeIcon = newImage;
    placeObj.isImageDownloaded = 1;
    NSMutableArray *data2 = [NSMutableArray arrayWithArray:placesData];
    if(placeObj)
        [data2 replaceObjectAtIndex:index-1100 withObject:placeObj];
}

-(void)fetchPlaceswithString:(NSString *)searchString
{
    responseData = nil;
    responseData = [[NSMutableData alloc]init];
    
    progress = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    [progress setDimBackground:YES];
    [progress setLabelText:@"Searching..."];
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude);
    NSLog(@"Location : %f %f",location.latitude,location.longitude);
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=%@&sensor=true&location=%f,%f&radius=1000&types=%@&key=%@",searchString,location.latitude, location.longitude, @"food|cafe|hotel",kGOOGLE_API_KEY];
    NSURL *googleRequestURL=[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:googleRequestURL];
    theConnection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
    theConnection.accessibilityHint = kPlacesFetching;
    if (!theConnection) {
        NSLog(@"Connection Failure");
    }
}

#pragma mark connection delegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
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
    if([connection.accessibilityHint isEqualToString:kPlacesFetching])
    {
        NSMutableArray *returnArray = [[NSMutableArray alloc]init];
        NSError *error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:kNilOptions
                              error:&error];
        if(!error)
        {
            NSArray *places = [json objectForKey:@"results"];
            
            for (int i=0; i<[places count]; i++)
            {
                NSDictionary* place = [places objectAtIndex:i];
                NSDictionary *geo = [place objectForKey:@"geometry"];
                UIImage *iconofRestaurant = [UIImage imageNamed:@"place.png"];
                NSString *name=[place objectForKey:@"name"];
//                NSString *vicinity=[place objectForKey:@"vicinity"];
                NSDictionary *loc = [geo objectForKey:@"location"];
                CLLocationCoordinate2D placeCoord;
                placeCoord.latitude=[[loc objectForKey:@"lat"] doubleValue];
                placeCoord.longitude=[[loc objectForKey:@"lng"] doubleValue];
                
                NSString *iconUrl = [place objectForKey:@"icon"];
                NSString *placeId = [place objectForKey:@"reference"];
//                NSArray *photosArray = [place objectForKey:@"photos"];
                NSString *rating = [place objectForKey:kRating];
                NSString *address = [place objectForKey:@"formatted_address"];
                
                AMPlaceObject *placeObject = [[AMPlaceObject alloc]init];
                placeObject.nameofPlace = name;
                placeObject.placeIcon = iconofRestaurant;
                placeObject.latitude = placeCoord.latitude;
                placeObject.longitude = placeCoord.longitude;
                placeObject.placeId = placeId;
                placeObject.rating = rating;
                placeObject.iconUrl = iconUrl;
                placeObject.isImageDownloaded = 0;
                placeObject.address = address;
                [returnArray addObject:placeObject];
            }
            //        if(!placesData)
            //            placesData = [[NSArray alloc]init];
            //        [placesData arrayByAddingObjectsFromArray:returnArray];
            
            
            placesData = [returnArray mutableCopy];
            [finalData removeAllObjects];
            [self addDatatoFinalArray];
            [progress setHidden:YES];
            [gridView setFrame:CGRectMake(0, 73, 320, 294+44) andWithData:finalData];
            [self.view addSubview:gridView];
            [self downloadPlacesImages];
            placeSearchDone = YES;
        }
    }
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
   
}



@end
