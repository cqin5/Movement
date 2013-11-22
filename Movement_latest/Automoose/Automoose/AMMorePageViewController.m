//
//  AMMorePageViewController.m
//  Automoose
//
//  Created by LAVANYA  on 10/02/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import "AMMorePageViewController.h"
//#import "AMRequestViewController.h"
#import "AMProfileCommonController.h"
#import "AMConstants.h"
#import "AMEventObject.h"
#import "AMEventsViewController.h"
#import "MFSideMenu.h"
#import "AMUtility.h"
#import "AMEventCustomCell.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+ResizeAdditions.h"
#import "PECropViewController.h"

#import "PeopleCollectionViewController.h"
#import "AMDetailEventViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "ODRefreshControl.h"
static CGFloat kImageOriginHight = 230.0f;

@interface AMMorePageViewController ()
{
    NSMutableArray *eventsList;
    MBProgressHUD *hud;
    ODRefreshControl *refreshControl;
}
@end

@implementation AMMorePageViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Me", @"Me");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Me";
    
//    imageEditor = [[AGSimpleImageEditorView alloc] initWithFrame:imageEditorContainer.frame];
    
//    [imageEditorContainer addSubview:imageEditor];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(loadCategoriesintoArrays) name:kRefreshProfile object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updatePeopleCount) name:kNotificationUpdatePeopleCount object:nil];
    self.view.backgroundColor = [AMUtility getColorwithRed:253 green:253 blue:253];
    [self setupMenuBarButtonItems];
    UIView *backGroundview = [[UIView alloc]initWithFrame:eventListTable.frame];
    backGroundview.backgroundColor = [UIColor whiteColor];
    eventListTable.backgroundView =backGroundview;
    eventListTable.backgroundColor = [UIColor clearColor];
    eventListTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    eventListTable.separatorColor = [UIColor clearColor];
    
    eventsNameLabel.textColor = [AMUtility getColorwithRed:79 green:79 blue:79];
    eventsNameLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:13];
    
    followersNameLabel.textColor = [AMUtility getColorwithRed:79 green:79 blue:79];
    followersNameLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:13];
    
    followingNameLabel.textColor = [AMUtility getColorwithRed:79 green:79 blue:79];
    followingNameLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:13];
    
    eventsCount.textColor = [AMUtility getColorwithRed:47 green:47 blue:47];
    followersCount.textColor =[AMUtility getColorwithRed:47 green:47 blue:47];
    follwingCount.textColor = [AMUtility getColorwithRed:47 green:47 blue:47];;
    
    eventsCount.font = [UIFont fontWithName:@"MyriadPro-Regular" size:30];
    follwingCount.font = [UIFont fontWithName:@"MyriadPro-Regular" size:30];
    followersCount.font = [UIFont fontWithName:@"MyriadPro-Regular" size:30];
    name.font = [UIFont fontWithName:@"HelveticaNeue" size:22.5];
    name.textColor = [UIColor whiteColor];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:profileBar.bounds];
    profileBar.layer.masksToBounds = NO;
    profileBar.layer.shadowColor = [UIColor blackColor].CGColor;
    profileBar.layer.shadowOffset = CGSizeMake(0.0f, -3.0f);
    profileBar.layer.shadowOpacity = 0.3f;
    profileBar.layer.shadowPath = shadowPath.CGPath;
     [self loadCategoriesintoArrays];
//    eventListTable.contentInset = UIEdgeInsetsMake(kImageOriginHight, 0, 0, 0);
//    [eventListTable addSubview:profileView];
    eventListTable.tableHeaderView= profileView;
    profileImage.clipsToBounds = YES;
    [profileImage.layer setCornerRadius:50.0f];
    
    refreshControl = [[ODRefreshControl alloc] initInScrollView:eventListTable];
    [refreshControl addTarget:self action:@selector(loadCategoriesintoArrays) forControlEvents:UIControlEventValueChanged];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    eventsNameLabel.textColor = [AMUtility getColorwithRed:79 green:79 blue:79];
    eventsNameLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:13];
    
    followersNameLabel.textColor = [AMUtility getColorwithRed:79 green:79 blue:79];
    followersNameLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:13];
    
    followingNameLabel.textColor = [AMUtility getColorwithRed:79 green:79 blue:79];
    followingNameLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:13];
    
    eventsCount.textColor = [AMUtility getColorwithRed:47 green:47 blue:47];
    followersCount.textColor =[AMUtility getColorwithRed:47 green:47 blue:47];
    follwingCount.textColor = [AMUtility getColorwithRed:47 green:47 blue:47];;
    
    eventsCount.font =[UIFont fontWithName:@"MyriadPro-Regular" size:30];
//    [UIFont fontWithName:@"BrandonGrotesque-Light" size:30];
    
    follwingCount.font = [UIFont fontWithName:@"MyriadPro-Regular" size:30];
    followersCount.font = [UIFont fontWithName:@"MyriadPro-Regular" size:30];
    name.font = [UIFont fontWithName:@"HelveticaNeue" size:22.5];


    if([[PFUser currentUser]objectForKey:kDisplayName])
        name.text = [[PFUser currentUser]objectForKey:kDisplayName];

    NSData *imgData = [[NSUserDefaults standardUserDefaults]objectForKey:kProfileImage_Big];
    if(imgData)
        profileImage.image = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults]objectForKey:kProfileImage_Big]];
//    follwingCount.text = [NSString stringWithFormat:@"%d",followersCount1];
//    followersCount.text = [NSString stringWithFormat:@"%d", followingCount];
    
    int invitationCount = [[[NSUserDefaults standardUserDefaults]objectForKey:kBadgeNumber]intValue];
    invitationsCount.text = [NSString stringWithFormat:@"%d",invitationCount];;
    [self updatePeopleCount];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark button actions
-(IBAction)followersButtonTapped:(id)sender{
    PeopleCollectionViewController *controller = [[PeopleCollectionViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller loadFollowers];
}
-(IBAction)followingButtonTapped:(id)sender{
    PeopleCollectionViewController *controller = [[PeopleCollectionViewController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller loadFollowing];
}

-(IBAction)eventButtonTapped:(id)sender
{
    [eventListTable setContentOffset:CGPointMake(0, 230) animated:YES];
}

-(void)backButtonTapped{
    [eventListTable setContentOffset:CGPointMake(0, 0) animated:YES];
    [self setupMenuBarButtonItems];
    self.navigationController.sideMenu.panMode = MFSideMenuPanModeDefault;
}

/*
-(IBAction)invitationButtonTapped:(id)sender{
    AMRequestViewController *requestController = [[AMRequestViewController alloc]init];
    [self.navigationController pushViewController:requestController animated:YES];
}
 */
-(IBAction)settingsButtonTapped:(id)sender
{
    AMProfileCommonController *profileController = [[AMProfileCommonController alloc]init];
    [self.navigationController pushViewController:profileController animated:YES];
}

-(void)loadCategoriesintoArrays {
    PFQuery *query = [PFQuery queryWithClassName:@"EventActivity"];
    [query whereKey:kToUser equalTo:[PFUser currentUser]];
    [query whereKey:kEventActivityType containedIn:[NSArray arrayWithObjects:kCreated,kAttended, nil]];
    
    query.cachePolicy = kPFCachePolicyCacheThenNetwork;
     [query orderByDescending:@"createdAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
        [eventsList removeAllObjects];
        eventsList = [NSMutableArray arrayWithArray:objects];
        [eventListTable reloadData];
        eventsCount.text = [NSString stringWithFormat:@"%d",eventsList.count];
        [refreshControl endRefreshing];
    }];
    [AMUtility fetchFollowers:^(NSError *err){
        
    }];
    [AMUtility fetchFollowing:^(NSError *err){
        
    }];
}
-(void)updatePeopleCount
{
    int followingCount = [[[NSUserDefaults standardUserDefaults]objectForKey:kFollowersCount]intValue];
    followersCount.text = [NSString stringWithFormat:@"%d", followingCount];
    
    int followersCount1 = [[[NSUserDefaults standardUserDefaults]objectForKey:kFollowingCount]intValue];
    follwingCount.text = [NSString stringWithFormat:@"%d",followersCount1];
}

#pragma mark table view methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat yOffset  = scrollView.contentOffset.y;
    if (yOffset < -kImageOriginHight) {
        CGRect f = profileView.frame;
        f.origin.y = yOffset;
        f.size.height =  -yOffset;
        NSLog(@"%f ",f.origin.y);
        
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return eventsList.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    AMEventCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[AMEventCustomCell alloc]initWithFrame:CGRectZero];
    }
    cell.backgroundView =[[ UIImageView alloc]initWithImage:[UIImage imageNamed:@"timelineshadow.png"]];
    PFObject *event = [eventsList objectAtIndex:indexPath.row];
    cell.nameoftheEventLabel.text = [event objectForKey:kNameofEvent];
    cell.actionLabel.text = [event objectForKey:kEventActivityType];
    NSDictionary *placeDetails = [event objectForKey:kPlaceDetails];
    cell.locationLabel.text = [placeDetails objectForKey:kName];
    PFUser *user = [event objectForKey:kFromUser];
    [user fetchIfNeededInBackgroundWithBlock:^(PFObject *object,NSError *err){
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
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AMDetailEventViewController *eventViewerViewController = [[AMDetailEventViewController alloc]init];
    eventViewerViewController.eventData = [eventsList objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:eventViewerViewController animated:YES];

}
-(IBAction)changeImageButtonClick:(id)sender {
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    [hud setDimBackground:YES];
    hud.labelText = @"Loading";
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
//    UIImagePickerControllerSourceTypeSavedPhotosAlbum;

    picker.allowsEditing = YES;

    [picker setMediaTypes:[NSArray arrayWithObjects:(NSString *) kUTTypeImage, nil]];
	[self presentModalViewController:picker animated:YES];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {

    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *image = [[UIImage alloc]init];
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        image = (UIImage *) [info objectForKey:
                             UIImagePickerControllerEditedImage];
        [self dismissViewControllerAnimated:YES completion:^{
            PECropViewController *controller = [[PECropViewController alloc] init];
            controller.delegate = self;
            controller.image = image;
            controller.typeOfController = @"ProfilePhoto";
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
            
            
            UIImage *mediumImage = [image thumbnailImage:105 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationLow];
            UIImage *largeImage= [image resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(320, 230) interpolationQuality:kCGInterpolationLow];
            profileImage.image = largeImage;

            [[NSUserDefaults standardUserDefaults]setObject:UIImagePNGRepresentation(mediumImage) forKey:kProfileImage_small];
            [[NSUserDefaults standardUserDefaults]setObject:UIImagePNGRepresentation(largeImage) forKey:kProfileImage_Big];
            [[NSUserDefaults standardUserDefaults]synchronize];

            [AMUtility reloadEventsData:^(NSError *err){
                [self loadCategoriesintoArrays];
            }];
            
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
            
            hud.hidden = YES;

            
//            [self presentViewController:navigationController animated:YES completion:NULL];
        }];
    }
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
    hud.hidden = YES;
}
#pragma mark crop view controller delegate

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:NULL];

    NSLog(@"%f %f",croppedImage.size.width,croppedImage.size.height);
    
    UIImage *mediumImage = [croppedImage thumbnailImage:105 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationLow];
    UIImage *largeImage= [croppedImage resizedImageWithContentMode:UIViewContentModeScaleAspectFill bounds:CGSizeMake(320, 230) interpolationQuality:kCGInterpolationLow];

    NSLog(@"%f %f",largeImage.size.width,largeImage.size.height);
    [[NSUserDefaults standardUserDefaults]setObject:UIImagePNGRepresentation(mediumImage) forKey:kProfileImage_small];
    [[NSUserDefaults standardUserDefaults]setObject:UIImagePNGRepresentation(largeImage) forKey:kProfileImage_Big];
    [[NSUserDefaults standardUserDefaults]synchronize];
    profileImage.image = croppedImage;
    [AMUtility reloadEventsData:^(NSError *err){
        [self loadCategoriesintoArrays];
    }];
    
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
    
    hud.hidden = YES;
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    hud.hidden = YES;
}


- (UIImage *)useImage:(UIImage *)image {
   
    
    // Create a graphics image context
    CGSize newSize = CGSizeMake(320, 230);
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    return newImage;
   
}

- (UIImage*)stripExif:(UIImage*)image
{
    CGImageRef cgImage = image.CGImage;
    UIImage* result = [UIImage imageWithCGImage:cgImage scale:1
                                    orientation:UIImageOrientationRight];

    return result;
}
- (UIImage *)scaleAndRotateImage:(UIImage *)image {
    int kMaxResolution = 320; // Or whatever
    
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = roundf(bounds.size.width / ratio);
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = roundf(bounds.size.height * ratio);
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

@end
