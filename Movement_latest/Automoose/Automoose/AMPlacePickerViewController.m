//
//  AMPlacePickerViewController.m
//  Automoose
//
//  Created by Srinivas on 12/11/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import "AMPlacePickerViewController.h"
#import "AMUtility.h"
#import "MBProgressHUD.h"
#import "AMGridView.h"
#import "AMDownloadMngr.h"
#import "OAuthConsumer.h"
#import "AMConstants.h"
#import "AMPlaceObject.h"
@interface AMPlacePickerViewController ()
{
    MBProgressHUD *hud;
}
@end

@implementation AMPlacePickerViewController
@synthesize delegate;
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
    selectedPlace = [[NSMutableArray alloc]init];
    self.title = @"Select Place";
    [self.navigationItem setHidesBackButton:NO];
    placeData = [[NSMutableArray alloc]init];
    queue = [[NSOperationQueue alloc] init];
    [queue setMaxConcurrentOperationCount:5];
    
//    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    backButton.frame = CGRectMake(0, 0, 100, 30);
//    [backButton setTitle:@"Back" forState:UIControlStateNormal];
//    [backButton addTarget:self action:@selector(dismissController) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc]initWithCustomView:backButton];
//    self.navigationItem.leftBarButtonItem = backBarButton;
//    
//    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    doneButton.frame = CGRectMake(0, 0, 100, 30);
//    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
//    [doneButton addTarget:self action:@selector(doneButtonClicked) forControlEvents:UIControlEventTouchUpInside];
//    
//    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]initWithCustomView:doneButton];
//    self.navigationItem.rightBarButtonItem = doneBarButton;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(dismissController)];

     self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonClicked)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    [searchBar1 becomeFirstResponder];
     [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(imageDownloaded:) name:@"ImageDownloaded" object:nil];
    [searchBar1 setBackgroundImage:[UIImage imageNamed:@"searchbar.png"]];
    for (UIView *subview in searchBar1.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subview removeFromSuperview];
            break;
        }
    }
    [searchBar1 setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_field.png"] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [theConnection cancel];
    if(!isControllerDismissed)
        [self.navigationController popViewControllerAnimated:YES];
}
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self FetchPlaces];
}
-(void)dismissController
{
    isControllerDismissed = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)doneButtonClicked
{
    isControllerDismissed = YES;
    [delegate placeSelectionDone:selectedPlace];
    [self.navigationController popViewControllerAnimated:YES];
    
}

//Method to select places using yelp

-(void)FetchPlaceswithString:(NSString *)searchString
{
    for(UIView *view in [gridView subviews])
    {
        [view removeFromSuperview];
    }
    responseData = nil;
    responseData = [[NSMutableData alloc]init];

     CLLocationCoordinate2D location = CLLocationCoordinate2DMake(locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude);
    NSString *urlString = [NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=%@&ll=%f,%f",searchString,location.latitude,location.longitude];
//    NSString *urlString = [NSString stringWithFormat:@"http://api.yelp.com/v2/search?term=%@&ll=%f,%f",searchString,kTempLatitude,kTempLongitude];
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
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    hud.hidden = YES;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}
//Here we parse the response and show the details on grid view. We do background loading of images.

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    
    NSArray *places = [json objectForKey:@"businesses"];
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    for (int i=0; i<[places count]; i++)
    {
        NSDictionary* place = [places objectAtIndex:i];
        NSDictionary *geo = [place objectForKey:kLocation];
        UIImage *iconofRestaurant = [UIImage imageNamed:@"place.png"];
        NSString *name=[place objectForKey:kPlace_name];
        NSDictionary *loc = [geo objectForKey:kCoordinate];
        CLLocationCoordinate2D placeCoord;
        placeCoord.latitude=[[loc objectForKey:kLatitude] doubleValue];
        placeCoord.longitude=[[loc objectForKey:kLongitude] doubleValue];
        
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
        
        NSDictionary *locationDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithFloat:placeCoord.latitude],@"latitude",[NSNumber numberWithFloat:placeCoord.longitude],@"longitude",address,@"Place", nil];
        
        NSMutableDictionary *placeDetails = [[NSMutableDictionary  alloc]initWithObjectsAndKeys:name,kName,iconofRestaurant,kImage,locationDictionary,kLocation,(iconUrl.length?iconUrl:@"NA"),kIconUrl,(rating?rating:@"0"),kRating,address,kAddress,[place objectForKey:kDisplay_phone],kDisplay_phone,[place objectForKey:kMobile_url],kMobile_url,categories,kCategories, nil];
        [returnArray addObject:placeDetails];
    }
    
    [placeData removeAllObjects];
    placeData = [returnArray mutableCopy];
    if(placeData)
    {
        gridView = [[AMGridView alloc]initWithFrame:CGRectMake(0, 44, 320, kScreenHeight - 44) andWithPlaceData:placeData];
        gridView.gridViewDelegate = self;
    }
    [self.view addSubview:gridView];
    [self downloadPlacesImages];
     
    [hud hide:YES];
}

//Method to download image in background using NSOperationQueue
-(void)downloadPlacesImages
{
    for(int i=0;i<placeData.count;i++)
    {
        NSDictionary *data = [placeData objectAtIndex:i];
           if(![[data objectForKey:kIconUrl] isEqualToString:@"NA"])
            {
                AMDownloadMngr *dwnldMngr = [[AMDownloadMngr alloc]initwithUrlString:[data objectForKey:kIconUrl] withIndex:i+100];
                [queue addOperation:dwnldMngr];
            }
    }
}

//Call back method for image download call. 
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
    
    UIImageView *imgView = (UIImageView *)[gridView viewWithTag:index+2000];
    [imgView setBackgroundColor:[UIColor lightTextColor]];
    [imgView.layer setCornerRadius:5];
    imgView.clipsToBounds = YES;
    imgView.image = nil;
    imgView.image = newImage;
    
    NSMutableDictionary *object = [placeData objectAtIndex:index-100];
    [object removeObjectForKey:@"Image"];
    [object setObject:image forKey:@"Image"];
    
    if(object)
        [placeData replaceObjectAtIndex:index-100 withObject:object];
}
-(void)tappedonGridCellwithIndex:(int )index andGrid:(UIView*)selectedFriend
{
    if(selectedPlace.count)
    {
        [selectedPlace removeAllObjects];
        UIImageView *viewtobeRemoved = (UIImageView *)[self.view viewWithTag:10000];
        [viewtobeRemoved removeFromSuperview];
    }
        [selectedPlace addObject:[placeData objectAtIndex:index-100]];
        UIImageView *tickMarkImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tick"]]; // tick.png
        tickMarkImage.frame = CGRectMake(0, 0, 100, 100);
//    CGRectMake(selectedFriend.frame.size.width - 30, 5, 23, 23) ;
        tickMarkImage.backgroundColor = [UIColor clearColor];
        tickMarkImage.tag =  10000;
        [selectedFriend addSubview:tickMarkImage];
    if(selectedPlace.count)
        self.navigationItem.rightBarButtonItem.enabled = YES;
    else
        self.navigationItem.rightBarButtonItem.enabled = NO;
}

#pragma mark search methods
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if(searchBar.text.length)
    {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
        [hud setDimBackground:YES];
        [hud setLabelText:@"Fetching Places"];
        [self FetchPlaceswithString:searchBar.text];
        [searchBar resignFirstResponder];
    }
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    [searchBar resignFirstResponder];
    
}
@end
