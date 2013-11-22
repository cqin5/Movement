//
//  AMProfileViewer.m
//  Automoose
//
//  Created by Srinivas on 12/15/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import "AMProfileViewer.h"
#import "AMEventCustomCell.h"
#import "AMEventObject.h"
#import "AMConstants.h"
#import "AMProfileViewerCusotmObject.h"
#import "AMUtility.h"
#import "AMCreateEventController.h"
#import "UIImage+ResizeAdditions.h"
#import <QuartzCore/QuartzCore.h>
#import "PeopleCollectionViewController.h"
#import "AMDetailEventViewController.h"
@interface AMProfileViewer ()
{
    NSMutableData *_data;
    MBProgressHUD *hud;
    int followersCountValue;
}
@end

@implementation AMProfileViewer
@synthesize dataArray;
@synthesize imageview,name,followersCount,followingCount,eventsCount,summaryView;
@synthesize followButton,user,facebookID,inviteButton;

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
    
    name.text = @"Name";
    [self setUpSummaryview];
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Invite" style:UIBarButtonItemStylePlain target:self action:@selector(inviteFriendtoanEvent)];
    
    table.backgroundView = nil;
    table.backgroundColor = [UIColor clearColor];
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    table.separatorColor = [UIColor clearColor];
    
    eventsNameLabel.textColor = [AMUtility getColorwithRed:79 green:79 blue:79];
    eventsNameLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:13];
    
    followersNameLabel.textColor = [AMUtility getColorwithRed:79 green:79 blue:79];
    followersNameLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:13];
    
    followingNameLabel.textColor = [AMUtility getColorwithRed:79 green:79 blue:79];
    followingNameLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:13];
    
    eventsCount.textColor = [AMUtility getColorwithRed:47 green:47 blue:47];
    followersCount.textColor =[AMUtility getColorwithRed:47 green:47 blue:47];
    followingCount.textColor = [AMUtility getColorwithRed:47 green:47 blue:47];;
    
    eventsCount.font = [UIFont fontWithName:@"MyriadPro-Regular" size:30];
    followingCount.font = [UIFont fontWithName:@"MyriadPro-Regular" size:30];
    followersCount.font = [UIFont fontWithName:@"MyriadPro-Regular" size:30];
    name.font = [UIFont fontWithName:@"HelveticaNeue" size:22.5];
    [name.layer setShadowColor:[UIColor colorWithRed:178.0/255.0 green:178.0/255.0 blue:178.0/255.0 alpha:1.0].CGColor];
    [name.layer setShadowOffset:CGSizeMake(1, 1)];
    name.layer.shadowRadius = 0.5;
    name.layer.shadowOpacity = 0.7;
    name.textColor = [UIColor whiteColor];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:profileBar.bounds];
    profileBar.layer.masksToBounds = NO;
    profileBar.layer.shadowColor = [UIColor blackColor].CGColor;
    profileBar.layer.shadowOffset = CGSizeMake(0.0f, -3.0f);
    profileBar.layer.shadowOpacity = 0.3f;
    profileBar.layer.shadowPath = shadowPath.CGPath;
    table.tableHeaderView= profileView;
    profileImage.clipsToBounds = YES;
    [profileImage.layer setCornerRadius:50.0f];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    /*
    if (![self.parentViewController.presentingViewController.modalViewController isEqual:self.parentViewController]) {
        self.navigationController.navigationBarHidden = NO;
        [self.navigationItem setHidesBackButton:NO];
    }
    else
    {
        [self.navigationItem setHidesBackButton:YES];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped)];
    }
     */
}


-(void)showCancelButton{
    [self.navigationItem setHidesBackButton:YES];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped)];
}
-(BOOL)isModal {
    
    BOOL isModal = ((self.parentViewController && self.parentViewController.modalViewController == self) ||
                    //or if I have a navigation controller, check if its parent modal view controller is self navigation controller
                    ( self.navigationController && self.navigationController.parentViewController && self.navigationController.parentViewController.modalViewController == self.navigationController) ||
                    //or if the parent of my UITabBarController is also a UITabBarController class, then there is no way to do that, except by using a modal presentation
                    [[[self tabBarController] parentViewController] isKindOfClass:[UITabBarController class]]);
    
    //iOS 5+
    if (!isModal && [self respondsToSelector:@selector(presentingViewController)]) {
        
        isModal = ((self.presentingViewController && self.presentingViewController.modalViewController == self) ||
                   //or if I have a navigation controller, check if its parent modal view controller is self navigation controller
                   (self.navigationController && self.navigationController.presentingViewController && self.navigationController.presentingViewController.modalViewController == self.navigationController) ||
                   //or if the parent of my UITabBarController is also a UITabBarController class, then there is no way to do that, except by using a modal presentation
                   [[[self tabBarController] presentingViewController] isKindOfClass:[UITabBarController class]]);
        
    }
    
    return isModal;        
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    /*
    PFFile *imageFile = [user objectForKey:kProfileImage_Big];
    [imageFile getDataInBackgroundWithBlock:^(NSData *data,NSError *error){
        [indicatorView stopAnimating];
        if(!error)
        {
            UIImage *image = [UIImage imageWithData:data];
            profileImage.image = image;
        }
        else{
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:@"Error retrieving photo" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
        
    }];
    */
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    if (![self.parentViewController.presentingViewController.modalViewController isEqual:self.parentViewController]) {
//        self.navigationController.navigationBarHidden = YES;
//    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setUpSummaryview
{
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
           return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        static NSString *CellIdentifier = @"Cell";
    AMEventCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = (AMEventCustomCell *) [[AMEventCustomCell alloc] initWithFrame:CGRectZero];
    }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        PFObject *event = [dataArray objectAtIndex:indexPath.row];
    cell.nameoftheEventLabel.text = [event objectForKey:kNameofEvent];
    cell.actionLabel.text = [event objectForKey:kEventActivityType];
    NSDictionary *placeDetails = [event objectForKey:kPlaceDetails];
    cell.locationLabel.text = [placeDetails objectForKey:kName];
    PFUser *user_temp = [event objectForKey:kFromUser];
    [user_temp fetchIfNeededInBackgroundWithBlock:^(PFObject *object,NSError *err){
        cell.displayNameLabel.text = [object objectForKey:kDisplayName];
        cell.photoView.file = [object objectForKey:kProfileImage];
        [cell.photoView loadInBackground];
    }];
    
    NSDate *todayDate = [NSDate date];
    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
    
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *eventDate = [dateFormatter dateFromString:[event objectForKey:kCreatedDate]];
    
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit | NSHourCalendarUnit)
                                               fromDate: eventDate
                                                 toDate:todayDate
                                                options:0];
    NSString *timeString = [NSString stringWithFormat:@"%ih", components.hour];
    if(components.day)
        timeString = [NSString stringWithFormat:@"%id", components.day];
    cell.timeLabel.text = timeString;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;        return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AMDetailEventViewController *eventViewerViewController = [[AMDetailEventViewController alloc]init];
    eventViewerViewController.eventData = [dataArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:eventViewerViewController animated:YES];
    
}


//Here details of the user are shown on the screen. 
-(void)showDetailsofUser:(PFUser *)user1
{
    user = user1;
    self.title = [user1 objectForKey:kDisplayName];
    
    self.name.text = [user1 objectForKey:kDisplayName];
    PFFile *imgData = [user1 objectForKey:kProfileImage]; //Fetching user image
    if(imgData)
    {
        [imgData getDataInBackgroundWithBlock:^(NSData *data,NSError *error){
            profileImage.image = [UIImage imageWithData:data];
            [indicatorView stopAnimating];
        }];
    }
    else
    {
        [indicatorView stopAnimating];
    }
    //Enabling/disbaling invite button and setting up follow/unfollow button.
    PFQuery *query =[PFQuery queryWithClassName:@"Activity"];
    [query whereKey:kToUser equalTo: [user1 objectId]];
    [query whereKey:kFromUser equalTo:[[PFUser currentUser] objectId]];
    [query countObjectsInBackgroundWithBlock:^(int number,NSError *error){
        if(!error && number)
        {
            followButton.tag = 101;
            
            [followButton setEnabled:YES];
            [followButton setBackgroundImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateNormal];
        }
        else
        {
            followButton.tag = 100;
           
            [followButton setEnabled:YES];
            [followButton setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
            if(error)
                [AMUtility showAlertwithTitle:@"Error" andMessage:error.localizedDescription];
        }
        if([[user1 objectId] isEqualToString:[[PFUser currentUser] objectId]])
        {
            followButton.enabled = NO;
            inviteButton.enabled = NO;
        }
    }];
    
    //Checking whether or not person can be invited
    PFQuery *queryInvite =[PFQuery queryWithClassName:@"Activity"];
    [queryInvite whereKey:kToUser equalTo:[[PFUser currentUser] objectId] ];
    [queryInvite whereKey:kFromUser equalTo:[user1 objectId]];
    [queryInvite countObjectsInBackgroundWithBlock:^(int number,NSError *error){
         if(!error && number)
         {
            [inviteButton setEnabled:YES];
         }
        else
        {
            [inviteButton setEnabled:NO];
        }
        if([[user1 objectId] isEqualToString:[[PFUser currentUser] objectId]])
        {
            followButton.enabled = NO;
            inviteButton.enabled = NO;
        }

    }];
    
    //Querying events of the user. 
    {
        PFQuery *query = [PFQuery queryWithClassName:@"EventActivity"];
        [query whereKey:kToUser equalTo:user1];
        [query whereKey:kEventActivityType containedIn:[NSArray arrayWithObjects:kCreated,kAttended, nil]];
        
//        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
        [query orderByDescending:@"createdAt"];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
            if(!error && objects)
            {
                dataArray = [NSArray arrayWithArray:objects];
                eventsCount.text = [NSString stringWithFormat:@"%d",dataArray.count];
            }
             [table reloadData];
        }];
    }
    //Querying followers
    PFQuery *followersQuery = [PFQuery queryWithClassName:kActivity];
    [followersQuery whereKey:kToUser equalTo:[user1 objectId]];
    [followersQuery countObjectsInBackgroundWithBlock:^(int number,NSError *error){
        if(!error)
        {
            followersCount.text = [NSString stringWithFormat:@"%d",number];
            followersCountValue = number;
        }
        else
            followersCount.text = @"0";
    }];
    //Querying following 
    PFQuery *followingQuery = [PFQuery queryWithClassName:kActivity];
    [followingQuery whereKey:kFromUser equalTo:[user1 objectId]];
    [followingQuery countObjectsInBackgroundWithBlock:^(int number,NSError *error){
        if(!error)
            followingCount.text = [NSString stringWithFormat:@"%d",number];
        else
            followingCount.text = @"0";
    }];
    
}

//Method to invite an user for an event.
-(IBAction)invitationButtonTapped:(id)sender
{
    AMCreateEventController *createEventController = [[AMCreateEventController alloc]init];
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:createEventController];
   NSArray *friendData ;
    NSArray *friendsArray = [[NSUserDefaults standardUserDefaults]objectForKey:kFollowers];
    for (int i=0;i<friendsArray.count; i++) {
        NSDictionary *dict = [friendsArray objectAtIndex:i];
        if([[dict objectForKey:kObjectId] isEqualToString:[user objectId]])
        {
            friendData = [NSArray arrayWithObject:dict];
            break;
        }
    }
//    [self presentModalViewController:navi animated:YES];
    [self presentViewController:navi animated:YES completion:^(void){
        [createEventController friendSelectionDone:friendData];
    }];
    
}

//Method to follow/unfollow an user.This is decided basing on the button tag we had set. 
-(IBAction)followButtonTapped:(id)sender
{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    [hud setDimBackground:YES];
    [hud setLabelText:@"Please wait.."];
    if(followButton.tag == 100)
    {
        [AMUtility followUserInBackground_justFollow:user block:^(BOOL success,NSError *error)
         {
             
             if(success)
             {
                 followersCountValue ++;
                 followersCount.text = [NSString stringWithFormat:@"%d",followersCountValue ];
                 followButton.tag = 101;
//                 [inviteButton setEnabled:YES];
                 [followButton setBackgroundImage:[UIImage imageNamed:@"unfollow.png"] forState:UIControlStateNormal];
                 
                 PFFile *profileImage1 = [user objectForKey:kProfileImage];
                 [profileImage1 getDataInBackgroundWithBlock:^(NSData *imgData,NSError *error){
                     NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[user objectForKey:kDisplayName],kDisplayName,[user objectForKey:kChannel],kChannel,[user objectId],kObjectId,imgData,kProfileImage,[user objectForKey:kFacebookId],kFacebookId, nil];
                     NSMutableArray *follwersArray = [[NSMutableArray alloc]init];
                     follwersArray  =[NSMutableArray arrayWithArray: [[NSUserDefaults standardUserDefaults]objectForKey:kFollowing]];
                     [follwersArray addObject:dictionary];
                     [[NSUserDefaults standardUserDefaults]setObject:follwersArray forKey:kFollowing];
                     [[NSUserDefaults standardUserDefaults]synchronize];
                     [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:follwersArray.count] forKey:kFollowingCount];
                     [[NSUserDefaults standardUserDefaults]synchronize];
                     [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationUpdatePeopleCount object:nil];
                     hud.hidden = YES;
                 }];
                
             }
             else
             {
                 hud.hidden = YES;
//                 NSLog(@"Error: %@",error.localizedDescription);
                 if(error)
                     [AMUtility showAlertwithTitle:kError andMessage:error.localizedDescription];
             }
         }];

    }
    else
    {
        [AMUtility unfollowUserInBackground:user block:^(BOOL success,NSError *error)
         {
             
             if(success)
             {
                 followersCountValue--;
                 followersCount.text = [NSString stringWithFormat:@"%d",followersCountValue ];
                 followButton.tag = 100;
//                 [inviteButton setEnabled:NO];
                  [followButton setBackgroundImage:[UIImage imageNamed:@"follow.png"] forState:UIControlStateNormal];
                 NSString *objectId = [user objectId];
                 NSMutableArray *follwersArray = [[NSMutableArray alloc]init];
                 follwersArray  =[NSMutableArray arrayWithArray: [[NSUserDefaults standardUserDefaults]objectForKey:kFollowing]];
                 for (int i=0; i<follwersArray.count; i++) {
                     NSDictionary *temp = [follwersArray objectAtIndex:i];
                     if([[temp objectForKey:kObjectId ] isEqualToString:objectId])
                     {
                         [follwersArray removeObjectAtIndex:i];
                         [[NSUserDefaults standardUserDefaults]setObject:follwersArray forKey:kFollowing];
                         [[NSUserDefaults standardUserDefaults]synchronize];
                         [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:follwersArray.count] forKey:kFollowingCount];
                         [[NSUserDefaults standardUserDefaults]synchronize];
                         [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationUpdatePeopleCount object:nil];
                         break;
                     }
                     
                 }
                 hud.hidden = YES;
             }
             else
             {
                 hud.hidden = YES;
                 if(error)
                     [AMUtility showAlertwithTitle:kError andMessage:error.localizedDescription];
             }
         }];
    }
}


-(void)cancelButtonTapped{
    [self dismissModalViewControllerAnimated:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark button actions
//Show user's followers in PeopleCollectionViewController
-(IBAction)followersButtonTapped:(id)sender{
    PeopleCollectionViewController *controller = [[PeopleCollectionViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller loadFollowingofUser:user];
}

//Show user's fllowoing people in PeopleCollectionViewController
-(IBAction)followingButtonTapped:(id)sender{
    PeopleCollectionViewController *controller = [[PeopleCollectionViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller loadFollowersofUser:user];
}

-(IBAction)eventButtonTapped:(id)sender
{
    [table setContentOffset:CGPointMake(0, 281) animated:YES];
}

/*
#pragma mark - NSURLConnectionDataDelegate

-(void)loadProfileImagewithFacebookId:(NSString *)facebookID1{
    if([facebookID isEqualToString:[[PFUser currentUser]objectForKey:kFacebookId]])
    {
        profileImage.image = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults]objectForKey:kProfileImage_Big]];
        [indicatorView stopAnimating];
        return;
    }
    NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=320&height=230", facebookID1]];
    NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f]; 
    [NSURLConnection connectionWithRequest:profilePictureURLRequest delegate:self];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    _data = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    
    profileImage.image = [UIImage imageWithData:_data];
    [indicatorView stopAnimating];
//    [[NSUserDefaults standardUserDefaults]setObject:_data forKey:kProfileImage_Big];
//    [[NSUserDefaults standardUserDefaults]synchronize];
    
//    UIImage *image = [UIImage imageWithData:_data];
//    
//    UIImage *mediumImage = [image thumbnailImage:105 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
//    //   UIImage *mediumImage = [image resizedImage:CGSizeMake(105, 105) interpolationQuality:kCGInterpolationHigh];
//    [[NSUserDefaults standardUserDefaults]setObject:UIImagePNGRepresentation(mediumImage) forKey:kProfileImage_small];
//    [[NSUserDefaults standardUserDefaults]synchronize];
//    
//    PFFile *imageFile = [PFFile fileWithData:UIImagePNGRepresentation(mediumImage)];
//    [imageFile saveInBackgroundWithBlock:^(BOOL succeed,NSError *error){
//        [[PFUser currentUser]setObject:imageFile forKey:@"profileImage"];
//        
//        [[PFUser currentUser]saveInBackground];
//    }];
    
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [indicatorView stopAnimating];
}
*/
@end
