//
//  AMPlaceViewController.m
//  Automoose
//
//  Created by Srinivas on 12/2/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import "AMPlaceViewController.h"
#import "AMPlaceObject.h"
#import "AMDownloadMngr.h"
#import "AMUtility.h"
#import <QuartzCore/QuartzCore.h>
#import "AMCreateEventController.h"
@interface AMPlaceViewController ()
{
    int sections;
}
@end

@implementation AMPlaceViewController
@synthesize placeObj;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Place", @"Place");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}

- (void)viewDidLoad
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(imageDownloaded:) name:@"ImageDownloaded" object:nil];
    sections = 1;
//    if(placeObj.photoIdArray.count)
//        sections = sections+1;
//    if(placeObj.review.count)
//        sections = sections+1;
    
    addressLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 300, 44)];
    addressLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    addressLabel.backgroundColor = [UIColor clearColor];
    addressLabel.textAlignment = NSTextAlignmentCenter;
    addressLabel.numberOfLines = 0;
    
    nameofthePlace.text = placeObj.nameofPlace;
    contactNumber.text = placeObj.phoneNumber;
    addressLabel.text = placeObj.address;
    placeIcon.image = placeObj.placeIcon;
    cateoryLabel.text = placeObj.categories;
    mapContainer.backgroundColor = [UIColor clearColor];
    phoneNumberContainer.backgroundColor = [UIColor clearColor];
    
    [super viewDidLoad];
    
    CLLocationCoordinate2D startCoord = CLLocationCoordinate2DMake(placeObj.latitude,placeObj.longitude);
    MKCoordinateRegion adjustedRegion = [placeMapview regionThatFits:MKCoordinateRegionMakeWithDistance(startCoord, 200, 200)];
    [placeMapview setRegion:adjustedRegion animated:YES];
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc]init];
    point.title = addressLabel.text;
    point.coordinate = startCoord;
    [placeMapview addAnnotation:point];
    
    UIButton *goButton = [UIButton buttonWithType:UIButtonTypeCustom];
    goButton.frame = CGRectMake(0, 0, 175, 40);
    [goButton setImage:[UIImage imageNamed:@"taptocreate.png"] forState:UIControlStateNormal];
    [goButton setImage:[UIImage imageNamed:@"taptocreate-t.png"] forState:UIControlStateHighlighted];
    [goButton addTarget:self action:@selector(createEvent) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = goButton;
    
//    photosScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, 320, 200)];
//    photosScrollView.scrollEnabled = YES;
//    photosScrollView.contentSize = CGSizeMake(320, 200);
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonTapped)];
    
    queue = [[NSOperationQueue alloc]init];
    [queue setMaxConcurrentOperationCount:2];
    [placeDetailsTableview reloadData];

    placeDetailsTableview.backgroundView = nil;
    placeDetailsTableview.backgroundColor = [UIColor whiteColor];
    
    if([placeObj.rating intValue] ==0)
        ratingImage.image = [UIImage imageNamed:@"rating_0.png"];
    else if([placeObj.rating intValue] ==1)
        ratingImage.image = [UIImage imageNamed:@"rating_1.png"];
    else if([placeObj.rating intValue] ==2)
        ratingImage.image = [UIImage imageNamed:@"rating_2.png"];
    else if([placeObj.rating intValue] ==3)
        ratingImage.image = [UIImage imageNamed:@"rating_3.png"];
    else if([placeObj.rating intValue] ==4)
        ratingImage.image = [UIImage imageNamed:@"rating_4.png"];
    else if([placeObj.rating intValue] ==5)
        ratingImage.image = [UIImage imageNamed:@"rating_5.png"];
    else if([placeObj.rating intValue] ==1.5)
        ratingImage.image = [UIImage imageNamed:@"rating_1_5.png"];
    else if([placeObj.rating intValue] ==2.5)
        ratingImage.image = [UIImage imageNamed:@"rating_2_5.png"];
    else if([placeObj.rating intValue] ==3.5)
        ratingImage.image = [UIImage imageNamed:@"rating_3_5.png"];
    else if([placeObj.rating intValue] ==4.5)
        ratingImage.image = [UIImage imageNamed:@"rating_4_5.png"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
   
}
-(void)cancelButtonTapped{
    [self dismissModalViewControllerAnimated:YES];
}
-(void)createEvent
{
    AMCreateEventController *createEventController = [[AMCreateEventController alloc]init];
    UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:createEventController];

    NSDictionary *locationDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithFloat:placeObj.latitude],@"latitude",[NSNumber numberWithFloat:placeObj.longitude],@"longitude",placeObj.address,@"Place", nil];
    
    NSString *iconUrl = placeObj.iconUrl;
    UIImage *iconofRestaurant = [UIImage imageNamed:@"place.png"];
    NSMutableDictionary *returnDictionary = [[NSMutableDictionary alloc]init];
    [returnDictionary setObject:placeObj.nameofPlace forKey:@"Name"];
    [returnDictionary setObject:iconUrl forKey:@"iconUrl"];
    
    [returnDictionary setObject:iconofRestaurant forKey:@"Image"];
    [returnDictionary setObject:locationDictionary forKey:@"location"];
    navi.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:navi animated:YES];
    [createEventController placeSelectionDone:[NSArray arrayWithObject:returnDictionary]];
}

#pragma mark table view delegate and datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
            break;
        case 1:
            return 1;
            break;
        default:
            break;
    }
    return 0;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
    NSString *value;
    NSDictionary *dictionary;
    CGSize maxSize = CGSizeMake(300, 999); // 999 can be any maxmimum height you want
    UIFont *font = [UIFont systemFontOfSize:15];
    CGSize newSize;
//    CGSize newSize = [text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:15.0f] constrainedToSize:maxSize lineBreakMode:UIViewAutoresizingFlexibleHeight];
    if(sections == 3)
    {
        switch (indexPath.section) {
            case 0:
                newSize = [placeObj.address sizeWithFont:font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
                if(newSize.height < 44)
                    return 44;
                else
                    return newSize.height;
                break;
            case 1:
                return 200;
                break;
            case 2:
                    dictionary = [placeObj.review objectAtIndex:indexPath.row];
                    value = [dictionary objectForKey:@"review"];
                    newSize = [value sizeWithFont:font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
                    if(newSize.height<44)
                        return 44;
                    else
                        return newSize.height + 50;
                break;
            default:
                break;
        }
    }
    if(sections == 2)
    {
        switch (indexPath.section) {
            case 0:
                if(indexPath.row != 1)
                    return 44;
                newSize = [placeObj.address sizeWithFont:font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
                if(newSize.height < 44)
                    return 44;
                else
                    return newSize.height;
                break;
            case 1:
                if(placeObj.photoIdArray.count)
                    return 200;
                else
                {
                    dictionary = [placeObj.review objectAtIndex:indexPath.row];
                    value = [dictionary objectForKey:@"review"];
                    newSize = [value sizeWithFont:font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
                    if(newSize.height<44)
                        return 44;
                    else
                        return newSize.height+50;
                }
                break;
            default:
                break;
        }
    }
    if(sections == 1)
    {
        newSize = [placeObj.address sizeWithFont:font constrainedToSize:maxSize lineBreakMode:NSLineBreakByWordWrapping];
        if(newSize.height < 44)
            return 44;
        else
            return newSize.height;
    }
    return 0;
     */
    if(indexPath.section == 0 && indexPath.row == 0)
    {
        if(indexPath.row == 0)
            return 136;
        else if (indexPath.row == 1)
            return 50;
    }
    return 44;
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(sections == 3)
    {
        switch (section) {
            case 0:
                return @"";
                break;
            case 1:
                return @"Photos";
                break;
            case 2:
                return @"Reviews";
                break;
            default:
                break;
        }
    }
    else
    {
        switch (section) {
            case 0:
               return @"";
                break;
            case 1:
                if(placeObj.photoIdArray.count)
                    return @"Photos";
                else
                    return @"Reviews";
                break;
            default:
                break;
        }
    }
    return @"";
}
 */

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
        NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    if(indexPath.section == 0)
    {
        switch (indexPath.row) {
            case 0:
                [cell.contentView addSubview:mapContainer];
                break;
            case 1:
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                [cell.contentView addSubview:addressLabel];
                break;
            case 2:
                [cell.contentView addSubview:phoneNumberContainer];
                break;
            default:
                break;
        }
    }
    else
    {
        cell.textLabel.text = @"Read reviews on Yelp";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:17];
    }
    /*
    for(UIView *view in [cell.contentView subviews])
    {
        [view removeFromSuperview];
    }
    cell.textLabel.text = @"";
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.textColor = [UIColor grayColor];
    
    [cell.textLabel setTextColor:[UIColor colorWithRed:0.298 green:0.337 blue:0.424 alpha:1]];
    [cell.textLabel setShadowColor: [UIColor whiteColor]];
    [cell.textLabel setShadowOffset: CGSizeMake(0.0, 1.0)];
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    [cell.contentView clearsContextBeforeDrawing];
    if(indexPath.section == 0)
    {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.text = placeObj.nameofPlace;
                break;
            case 1:
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.text = placeObj.address;
                break;
            case 2:
                cell.textLabel.text = placeObj.phoneNumber;
            default:
                break;
        }
    }
    
    if(placeObj.photoIdArray.count)
    {
        CGFloat xPosition =10;
        NSDictionary *dictionary ;
        CGRect frame;
        UIActivityIndicatorView *activityIndicator;
        switch (indexPath.section) {
            case 1:
                if(placeObj.photosArray.count)
                {
                    for(int i=0;i<placeObj.photosArray.count ;i++)
                    {
                        UIImage *image = [placeObj.photosArray objectAtIndex:i];
                        UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
                        imageView.frame = CGRectMake(xPosition, 10,image.size.width,image.size.height);
                        xPosition = xPosition + image.size.width + 10;
                        [imageView.layer setCornerRadius:5];
                        imageView.clipsToBounds = YES;
                        [photosScrollView addSubview:imageView];
                        photosScrollView.contentSize = CGSizeMake(xPosition, 180);
                        frame = photosScrollView.frame;
                        frame.size.width = cell.contentView.frame.size.width - 20;
                        photosScrollView.frame = frame;
                        [cell.contentView addSubview:photosScrollView];
                    }
                }
                else
                {
                  
                    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                    activityIndicator.frame = CGRectMake(135, 80, 40, 40) ;
                    [activityIndicator startAnimating];
                    [cell.contentView addSubview:activityIndicator];
                }
                break;
            case 2:
                cell.textLabel.numberOfLines = 0;
                 dictionary = [placeObj.review objectAtIndex:indexPath.row];
                cell.textLabel.text = [dictionary objectForKey:@"review"];
                break;
            default:
                break;
        }
    }
    else
    {
        if(indexPath.section == 1)
        {
            cell.textLabel.numberOfLines = 0;
            NSDictionary *dictionary = [placeObj.review objectAtIndex:indexPath.row];
            cell.textLabel.text = [dictionary objectForKey:@"review"];
        }
    }
     */
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0 && indexPath.row == 2)
    {
        NSString *phoneNumber = placeObj.phoneNumber;
        NSString *phoneURLString = [NSString stringWithFormat:@"tel:%@", phoneNumber];
        NSURL *phoneURL = [NSURL URLWithString:phoneURLString];
        [[UIApplication sharedApplication] openURL:phoneURL];
    }
    else if(indexPath.section == 1 && indexPath.row == 0)
    {
        NSURL *mobileURL = [NSURL URLWithString:placeObj.mobileUrl];
        [[UIApplication sharedApplication]openURL:mobileURL];
    }
}

-(void)fetchPhotoImages
{
//    https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=CoQBegAAAFg5U0y-iQEtUVMfqw4KpXYe60QwJC-wl59NZlcaxSQZNgAhGrjmUKD2NkXatfQF1QRap-PQCx3kMfsKQCcxtkZqQ&sensor=true&key=AddYourOwnKeyHere
    
    NSArray *photoIdArray = placeObj.photoIdArray;
    for(int i=0;i<photoIdArray.count;i++)
    {
        NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=%@&sensor=true&key=%@",[photoIdArray objectAtIndex:i],kGOOGLE_API_KEY];
        AMDownloadMngr *downloadManager = [[AMDownloadMngr alloc]initwithUrlString:urlString withIndex:1110];
        [queue addOperation:downloadManager];
    }
}
-(void)imageDownloaded:(NSNotification *)notification
{
    NSDictionary *dictionary = [notification object];
    NSData *data = [dictionary objectForKey:@"imageData"];
    UIImage *image = [UIImage imageWithData:data];
    
    CGFloat width = 200;
    CGFloat height = 180;
    if(image.size.width < 200)
        width = image.size.width;
    if(image.size.height < 180)
        height = image.size.height;
    CGSize newSize = CGSizeMake(width , height);
    UIGraphicsBeginImageContext(newSize);
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSMutableArray *temp_photosArray = [[NSMutableArray alloc]initWithArray:placeObj.photosArray];
    [temp_photosArray addObject:newImage];
    placeObj.photosArray = temp_photosArray;
//    NSIndexSet *indexSet = [[NSIndexSet alloc]initWithIndex:1];
//    [placeDetailsTableview reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    [placeDetailsTableview reloadData];
}

@end
