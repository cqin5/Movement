//
//  AMPeopleViewer.m
//  Automoose
//
//  Created by Srinivas on 11/08/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import "AMPeopleViewer.h"
#import "AMGridView.h"
#import "AMConstants.h"
#import "AMProfileViewer.h"
@interface AMPeopleViewer ()
{
    AMGridView *gridView;
    IBOutlet UIScrollView *scrollView;
    NSInteger yValueCount;
    NSInteger xValueCount;
}
@end

@implementation AMPeopleViewer
@synthesize peopleArray,titleString;
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
    for(int i =0; i < peopleArray.count ; i++)
    {
//        NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:[finalFriendArray objectAtIndex:i]];
        PFUser *user = [peopleArray objectAtIndex:i];
//        UIImage *image = [UIImage imageWithData:[user objectForKey:kProfileImage]];
        PFFile *file = [user objectForKey:kProfileImage];
        NSString *nameoFriend = [user objectForKey:kDisplayName];
        [self createIconViewforUser:nameoFriend withFile:file withTag:i+100];
    }
    
    NSLog(@"%@",titleString);
    self.title = titleString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
   
}

//Setting up the grid view
-(void)createIconViewforUser:(NSString *)nameofUser withFile:(PFFile *)file withTag:(int)tag
{
    int xValue = 2.5+xValueCount*105;
    int yValue = 2.5+yValueCount*105;
    
    if(xValueCount == 0)
        xValue = 0;
    else if (xValueCount == 1)
        xValue = 2.5+105;
    else if(xValueCount == 2)
        xValue = 2*107.5 ;
    
    xValueCount++;
    
    if(xValueCount == 3)
    {
        yValueCount++;
        xValueCount = 0;
    }
    CGRect frame = CGRectMake(xValue, yValue, 105, 105);
    
    UIView *profileView = [[UIView alloc]initWithFrame:frame];
    [profileView.layer setCornerRadius:5.0f];
    profileView.backgroundColor = [UIColor clearColor];
    profileView.tag = tag;
    
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(friendSelected:)];
    [profileView addGestureRecognizer:tapGesture];
    
    PFImageView *profileImageView = [[PFImageView alloc]initWithFrame:CGRectMake(0, 0, 105, 105)];
    profileImageView.file = file;
    [profileImageView loadInBackground];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 105 - 30, 104, 30)];
    label.font = [UIFont fontWithName:@"MyriadPro-Regular" size:14];
    label.text = nameofUser;
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentRight;
    label.backgroundColor = [UIColor clearColor];
    
    
    [profileView addSubview:profileImageView];
    [profileView addSubview:label];
    [scrollView addSubview:profileView];
    [scrollView setContentSize:CGSizeMake(320, yValue+150)];
}

//Method to show user details when tapped on grid item.
-(void)friendSelected:(UITapGestureRecognizer *)recgonizer
{
    int indexofSelectedFriend = [recgonizer.view tag] - 100;
//    UIView *selecedFriend = (UIView *)[self.view viewWithTag:indexofSelectedFriend+100];
    NSLog(@"%d",indexofSelectedFriend);
    
    
    AMProfileViewer *profileViewer = [[AMProfileViewer alloc]init];
    [self.navigationController pushViewController:profileViewer animated:YES];
    
    PFUser *user1 = [peopleArray objectAtIndex:indexofSelectedFriend];
    [profileViewer showDetailsofUser:user1];
}

@end
