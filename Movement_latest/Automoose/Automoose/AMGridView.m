//
//  AMGridView.m
//  Automoose
//
//  Created by Srinivas on 12/11/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import "AMGridView.h"
#import "AMProfileViewerCusotmObject.h"
#import "AMConstants.h"
#import <QuartzCore/QuartzCore.h>

#import "AMDownloadMngr.h"

@implementation AMGridView
@synthesize gridViewDelegate;

-(id)init
{
    self = [super init];
    if(self)
    {
        self.backgroundColor = [UIColor colorWithRed:253.0/255.0 green:253.0/255.0 blue:253.0/255.0 alpha:1.0];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame andWithData:(NSArray *)data
{
    [self setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]]];

    xValueCount = 0;
    yValueCount = 0;
        for(UIView *view in self.subviews)
        {
            [view removeFromSuperview];
        }
        self.frame = frame;
        receivedData = [data mutableCopy];
        firstPlaceIndex = 0;
        for(int i=0; i < data.count ; i++)
        {
            NSDictionary *dictionary = [data objectAtIndex:i];
            NSString *nameofRestaurant = [dictionary objectForKey:@"Name"];
            UIImage *imageofRestaurant = [dictionary objectForKey:@"Image"];
            [self createViewForGrid:nameofRestaurant withImage:imageofRestaurant withTag:i+100];
        }
        isIndexSaved = NO;
//    }
//    return self;
}

- (id)initWithFrame:(CGRect)frame andWithPlaceData:(NSArray *)data
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:253.0/255.0 green:253.0/255.0 blue:253.0/255.0 alpha:1.0];
        queue = [[NSOperationQueue alloc] init];
        [queue setMaxConcurrentOperationCount:5];
        for(int i=0; i < data.count ; i++)
        {
            NSDictionary *dictionary = [data objectAtIndex:i];
            NSString *nameofRestaurant = [dictionary objectForKey:@"Name"];
            UIImage *imageofRestaurant = [dictionary objectForKey:@"Image"];
            [self createViewForGrid:nameofRestaurant withPlaceImage:imageofRestaurant withTag:i+100];
        }
    }
    return self;
}
-(void)setUpPeopleData:(NSArray *)data{
    for(int i =0; i < data.count ; i++)
    {
        NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:[data objectAtIndex:i]];
        UIImage *image = [UIImage imageWithData:[dictionary objectForKey:kProfileImage]];
        NSString *nameoFriend = [dictionary objectForKey:kDisplayName];
        [self createViewForGrid:nameoFriend withImage:image withTag:i+100];
    }
}

-(void)loadDatawithUsers:(NSArray *)users {
    for (int i=0; i<users.count; i++) {
        PFUser *user = [users objectAtIndex:i];
        PFFile *file = [user objectForKey:kProfileImage];
        NSString *name = [user objectForKey:kDisplayName];
        [self createViewForGridwithName:name withImageFile:file withTag:i+100];
    }
}

-(void)createViewForGridwithName:(NSString *)name withImageFile:(PFFile *)file withTag:(int)tag{
    int xValue = 5+xValueCount*100;
    int yValue = 5*(yValueCount +1)+yValueCount*100;
    self.backgroundColor = [UIColor colorWithRed:253.0/255.0 green:253.0/255.0 blue:253.0/255.0 alpha:1.0];
    if(xValueCount == 0)
        xValue = 5;
    else if (xValueCount == 1)
        xValue = 10+100;
    else if(xValueCount == 2)
        xValue = 215;
    xValueCount++;
    if(xValueCount == 3)
    {
        yValueCount++;
        xValueCount = 0;
    }
    CGRect frame = CGRectMake(xValue, yValue, 100, 100);
    
    UIView *profileView = [[UIView alloc]initWithFrame:frame];
    [profileView.layer setCornerRadius:5.0f];
    profileView.backgroundColor = [UIColor clearColor];
    profileView.tag = tag;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedonGridCell_local:)];
    [profileView addGestureRecognizer:tapGesture];
    
    PFImageView *profileImageView = [[PFImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    profileImageView.image = [UIImage imageNamed:@""];
    if(file)
    {
        profileImageView.file = file;
        [profileImageView loadInBackground];
    }
    profileImageView.clipsToBounds = YES;
    profileImageView.tag = tag+1000;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 100 - 35, 98, 36)];
    label.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15];
    label.text = name;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentRight;
    label.numberOfLines = 0;
    [profileView addSubview:profileImageView];
    [profileView addSubview:label];
    [self addSubview:profileView];
    [self setContentSize:CGSizeMake(320, yValue+150)];

}

-(void )createViewForGrid:(NSString *)nameofPlace withPlaceImage:(UIImage *)image withTag:(int)tag
{
    int xValue =5+xValueCount*100;
    int yValue = 5*(yValueCount +1)+yValueCount*100;
    self.backgroundColor = [UIColor colorWithRed:253.0/255.0 green:253.0/255.0 blue:253.0/255.0 alpha:1.0];
    if(xValueCount == 0)
        xValue = 5;
    else if (xValueCount == 1)
        xValue = 10+100;
    else if(xValueCount == 2)
        xValue = 215;
    xValueCount++;
    if(xValueCount == 3)
    {
        yValueCount++;
        xValueCount = 0;
    }
    CGRect frame = CGRectMake(xValue, yValue, 100, 100);
    
    UIView *profileView = [[UIView alloc]initWithFrame:frame];

    profileView.backgroundColor = [UIColor clearColor];
    profileView.tag = tag;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedonGridCell_local:)];
    [profileView addGestureRecognizer:tapGesture];
    [profileView.layer setCornerRadius:5.0f];
    
    
    UIImageView *profileImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    profileImageView.image = image;
    profileImageView.clipsToBounds = YES;
    profileImageView.tag = tag+2000;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 100 - 35, 98, 36)];
    label.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15];
    label.text = nameofPlace;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentRight;
    label.numberOfLines = 0;
    [profileView addSubview:profileImageView];
    [profileView addSubview:label];
    [self addSubview:profileView];
    [self setContentSize:CGSizeMake(320, yValue+150)];
    
}



-(id)initWithFrame:(CGRect)frame andWithPeopleData:(NSArray *)data
{
    self = [super initWithFrame:frame];
    if (self) {
       self.backgroundColor = [UIColor colorWithRed:253.0/255.0 green:253.0/255.0 blue:253.0/255.0 alpha:1.0];
        for(int i=0;i<data.count;i++)
        {
            AMProfileViewerCusotmObject *object = [[AMProfileViewerCusotmObject alloc]init];
            object = [data objectAtIndex:i];
            NSString *nameofPerson = object.nameofProfile;
            UIImage *image = [UIImage imageWithData:object.profileImageData];
            [self createViewForGrid:nameofPerson withImage:image withTag:i+100];
            object = nil;
        }
    }
    return self;
}



-(void )createViewForGrid:(NSString *)nameofUser withImage:(UIImage *)image withTag:(int)tag
{
    int xValue = 5+xValueCount*100;
    int yValue = 5*(yValueCount +1)+yValueCount*100;
    self.backgroundColor = [UIColor colorWithRed:253.0/255.0 green:253.0/255.0 blue:253.0/255.0 alpha:1.0];
    if(xValueCount == 0)
        xValue = 5;
    else if (xValueCount == 1)
        xValue = 10+100;
    else if(xValueCount == 2)
        xValue = 215;
    xValueCount++;
    if(xValueCount == 3)
    {
        yValueCount++;
        xValueCount = 0;
    }
    CGRect frame = CGRectMake(xValue, yValue, 100, 100);
    
    UIView *profileView = [[UIView alloc]initWithFrame:frame];
    [profileView.layer setCornerRadius:5.0f];
    profileView.backgroundColor = [UIColor clearColor];
    profileView.tag = tag;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedonGridCell_local:)];
    [profileView addGestureRecognizer:tapGesture];
    
    UIImageView *profileImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 100)];
    profileImageView.image = image;
    profileImageView.clipsToBounds = YES;
    profileImageView.tag = tag+1000;
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 100 - 35, 98, 36)];
    label.font = [UIFont fontWithName:@"MyriadPro-Regular" size:15];
    label.text = nameofUser;
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentRight;
    label.numberOfLines = 0;
    [profileView addSubview:profileImageView];
    [profileView addSubview:label];
    [self addSubview:profileView];
    [self setContentSize:CGSizeMake(320, yValue+150)];
   
}

-(void )createViewForGrid:(NSString *)nameofUser withImageUrl:(NSString *)imageUrl withTag:(int)tag
{
    self.backgroundColor = [UIColor colorWithRed:253.0/255.0 green:253.0/255.0 blue:253.0/255.0 alpha:1.0];
   int xValue = 40+xValueCount*90;
    int yValue = 10+yValueCount*90;
    xValueCount++;
    if(xValueCount == 3)
    {
        yValueCount++;
        xValueCount = 0;
    }
    CGRect frame = CGRectMake(xValue, yValue, 90, 200);
    UIView *profileView = [[UIView alloc]initWithFrame:frame];
//    [profileView.layer setCornerRadius:5.0f];
    profileView.backgroundColor = [UIColor clearColor];
    profileView.tag = tag;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedonGridCell_local:)];
    [profileView addGestureRecognizer:tapGesture];
    
    UIImageView *profileImageView = [[UIImageView alloc]initWithFrame:CGRectMake(5, 0, 50, 50)];
    profileImageView.image = [UIImage imageNamed:@"place.png"];
    profileImageView.tag = tag+1000;
//    [profileImageView.layer setCornerRadius:5];
    profileImageView.clipsToBounds = YES;
    
    AMDownloadMngr *dwnldMngr = [[AMDownloadMngr alloc]initwithUrlString:imageUrl withIndex:tag+1000];
    [queue addOperation:dwnldMngr];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 52, 90, 30)];
    label.font = [UIFont fontWithName:@"Arial" size:9];
    label.text = nameofUser;
    [profileView addSubview:profileImageView];
    [profileView addSubview:label];
    [self addSubview:profileView];
    [self setContentSize:CGSizeMake(320, yValue+150)];
}

-(void)tappedonGridCell_local:(UITapGestureRecognizer *)recgonizer
{
    int index = [recgonizer.view tag] ;
    UIView *selectedGrid = (UIView *)[self viewWithTag:index];
    if([gridViewDelegate respondsToSelector:@selector(tappedonGridCellwithIndex:andGrid:)])
        [gridViewDelegate tappedonGridCellwithIndex:index andGrid:selectedGrid];

    if([gridViewDelegate respondsToSelector:@selector(tappedonGridCellWithIndex:)])
        [gridViewDelegate tappedonGridCellWithIndex:index-100];
    
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
-(void)downloadImagewithUrl:(NSString *)urlString
{
    responseData = [[NSMutableData alloc]init];
    NSURLRequest *urlRequest = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:urlRequest delegate:self];
    if(!connection)
        NSLog(@"Network connection failed!");
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [responseData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
//    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:responseData,@"imageData",[NSNumber numberWithInteger:indexofImage],@"index", nil];
//    [[NSNotificationCenter defaultCenter]postNotificationName:@"ImageDownloaded" object:dictionary];
    [gridViewDelegate imageDownloaded:[UIImage imageWithData:responseData] withIndex:1];
}

-(void)imageDownloaded:(NSNotification *)notification
{
    NSDictionary *dictionary = [notification object];
    NSData *data = [dictionary objectForKey:@"imageData"];
    NSInteger index = [[dictionary objectForKey:@"index"]intValue];
    UIImageView *imgView = (UIImageView *)[self viewWithTag:index];
    [imgView setBackgroundColor:[UIColor lightTextColor]];
//    [imgView.layer setCornerRadius:5];
    imgView.clipsToBounds = YES;
    imgView.image = nil;
    imgView.image = [UIImage imageWithData:data];
//    NSLog(@"%d",index-1100-firstPlaceIndex);
    [gridViewDelegate imageDownloaded:[UIImage imageWithData:data] withIndex:1];
}
@end
