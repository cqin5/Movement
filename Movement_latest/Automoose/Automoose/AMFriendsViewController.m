//
//  AMFriendsViewController.m
//  Automoose
//
//  Created by Srinivas on 12/9/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import "AMFriendsViewController.h"
#import "AMUtility.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "AMCreateEventController.h"
#import "AMConstants.h"
@interface AMFriendsViewController ()
{
    MBProgressHUD *progessIndicator;
    NSMutableArray *searchArray,*namesArray;
    BOOL isSearching;
}
@end

@implementation AMFriendsViewController
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
    [self.navigationItem setHidesBackButton:YES];
//    [AMUtility fetchFriends];
    self.title = @"Select Friends";

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(dismissController)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonClicked)];
    self.navigationItem.rightBarButtonItem.enabled = NO;
    
    selectedFriends = [[NSMutableArray alloc]init];
    [selectedFriendsLable.layer setCornerRadius:5.0f];
    [selectedFriendsLable setBackgroundColor:[UIColor grayColor]];
    [self fetchFollowingPeople];
//    [searchBar1 setBackgroundImage:[UIImage imageNamed:@"searchbar.png"]];

    for (UIView *subview in searchBar1.subviews) {
        if ([subview isKindOfClass:NSClassFromString(@"UISearchBarBackground")]) {
            [subview removeFromSuperview];
            break;
        }
    }
    [searchBar1 setSearchFieldBackgroundImage:[UIImage imageNamed:@"search_field.png"] forState:UIControlStateNormal];
    
    
    UISearchDisplayController *controller = [[UISearchDisplayController alloc]initWithSearchBar:searchBar1 contentsController:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if(!isControllerDismissed)
        [self.navigationController popViewControllerAnimated:YES];
}

//Get the list of cached people and show on grid view. 
-(void)fetchFollowingPeople
{
    finalFriendArray = [[NSMutableArray alloc]init];
    
    finalFriendArray = [[NSUserDefaults standardUserDefaults]objectForKey:kFollowers];
    for(int i =0; i < finalFriendArray.count ; i++)
    {
        NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:[finalFriendArray objectAtIndex:i]];
        UIImage *image = [UIImage imageWithData:[dictionary objectForKey:kProfileImage]];
        NSString *nameoFriend = [dictionary objectForKey:kDisplayName];
        [self createIconViewforUser:dictionary withTag:i+100];
    }
    [self prepareNamesArray];
}
-(void)dismissController
{
    isControllerDismissed = YES;
    [self.navigationController popViewControllerAnimated:YES];
}

//Call the appropriate delegate method
-(void)doneButtonClicked
{
    isControllerDismissed = YES;
    [delegate performSelector:@selector(friendSelectionDone:) withObject:selectedFriends withObject:nil];
    [self.navigationController popViewControllerAnimated:YES];

}
//Create the grid view
-(void)createIconViewforUser:(NSDictionary *)entry withTag:(int)tag
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
    
    UIImageView *profileImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 105, 105)];
    profileImageView.image = [UIImage imageWithData:[entry objectForKey:kProfileImage]];
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 105 - 30, 104, 30)];
    label.font = [UIFont fontWithName:@"MyriadPro-Regular" size:14];
    label.text = [entry objectForKey:kDisplayName];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentRight;
    label.backgroundColor = [UIColor clearColor];
    
    
    [profileView addSubview:profileImageView];
    [profileView addSubview:label];
    
    for(int i=0;i<selectedFriends.count;i++){
        NSDictionary *selectedEntry = [selectedFriends objectAtIndex:i ];
        if([[selectedEntry objectForKey:kObjectId] isEqualToString:[entry objectForKey:kObjectId]])
        {
            UIImageView *tickMarkImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tick"]]; //tick.png
            tickMarkImage.frame =CGRectMake(0, 0, 105, 105);
//            CGRectMake(profileView.frame.size.width - 30, 5, 23, 23) ;
            tickMarkImage.tag = tag - 100 + 1000;
            [profileView addSubview:tickMarkImage];
            break;
        }
    }
    [profileImageView.layer setCornerRadius:5];
    profileImageView.clipsToBounds = YES;
    [profileView.layer setCornerRadius:5];
    [scrollView addSubview:profileView];
    [scrollView setContentSize:CGSizeMake(320, yValue+150)];

}

//When tap on the griview is detected, this method gets called and corresponding user details are saved for later use. 
-(void)friendSelected:(UITapGestureRecognizer *)recgonizer
{
    if(!isSearching)
    {
        int indexofSelectedFriend = [recgonizer.view tag] - 100;
        UIView *selecedFriend = (UIView *)[self.view viewWithTag:indexofSelectedFriend+100];
        if(![selectedFriends containsObject:[finalFriendArray objectAtIndex:indexofSelectedFriend]])
        {
            UIImageView *tickMarkImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tick"]]; //tick.png
            tickMarkImage.frame = CGRectMake(0, 0, 105, 105);
//            CGRectMake(selecedFriend.frame.size.width - 30, 5, 23, 23) ;
            tickMarkImage.tag = indexofSelectedFriend + 1000;
            [selecedFriend addSubview:tickMarkImage];
            [selectedFriends addObject:[finalFriendArray objectAtIndex:indexofSelectedFriend]];
        }
        else{
            UIImageView *tickMarkImage = (UIImageView *)[self.view viewWithTag:indexofSelectedFriend + 1000];
            [tickMarkImage removeFromSuperview];
            [selectedFriends removeObject:[finalFriendArray objectAtIndex:indexofSelectedFriend]];
        }
        if(selectedFriends.count)
            self.navigationItem.rightBarButtonItem.enabled = YES;
        else
            self.navigationItem.rightBarButtonItem.enabled = NO;
        selectedFriendsLable.text = [NSString stringWithFormat:@"%d persons selected!",selectedFriends.count];
    }
    else
    {
        int indexofSelectedFriend = [recgonizer.view tag] - 100;
        UIView *selecedFriend = (UIView *)[self.view viewWithTag:indexofSelectedFriend+100];
        if(![selectedFriends containsObject:[searchArray objectAtIndex:indexofSelectedFriend]])
        {
            UIImageView *tickMarkImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tick"]]; //tick.png
            tickMarkImage.frame = CGRectMake(0, 0, 105, 105);
//            CGRectMake(selecedFriend.frame.size.width - 30, 5, 23, 23) ;
            tickMarkImage.tag = indexofSelectedFriend + 1000;
            [selecedFriend addSubview:tickMarkImage];
            [selectedFriends addObject:[searchArray objectAtIndex:indexofSelectedFriend]];
        }
        else{
            UIImageView *tickMarkImage = (UIImageView *)[self.view viewWithTag:indexofSelectedFriend + 1000];
            [tickMarkImage removeFromSuperview];
            [selectedFriends removeObject:[searchArray objectAtIndex:indexofSelectedFriend]];
        }
        if(selectedFriends.count)
            self.navigationItem.rightBarButtonItem.enabled = YES;
        else
            self.navigationItem.rightBarButtonItem.enabled = NO;
        selectedFriendsLable.text = [NSString stringWithFormat:@"%d persons selected!",selectedFriends.count];
    }
}

//Get names for search
-(void)prepareNamesArray{
    if(!namesArray)
        namesArray = [[NSMutableArray alloc]init];
    [finalFriendArray enumerateObjectsUsingBlock:^(NSDictionary *dictionary,NSUInteger index,BOOL *stop){
        [namesArray addObject:[[dictionary objectForKey:kDisplayName] lowercaseString]];
    }];
}

#pragma mark search bar delegate methods
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    isSearching = YES;
    searchBar.showsCancelButton = YES;
    [self searchWithString:[searchBar.text lowercaseString]];
}
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar{
    [self searchWithString:[searchBar.text lowercaseString]];
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self searchWithString:[searchBar.text lowercaseString]];
}
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [self searchWithString:[searchBar.text lowercaseString]];
    [searchBar resignFirstResponder];
}
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar
{
    isSearching = NO;
    searchBar.text = @"";
    searchBar.showsCancelButton = NO;
    [searchBar resignFirstResponder];
    for(UIView *view in scrollView.subviews){
        [view removeFromSuperview];
    }
    for(int i =0; i < finalFriendArray.count ; i++)
    {
        NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:[finalFriendArray objectAtIndex:i]];
        UIImage *image = [UIImage imageWithData:[dictionary objectForKey:kProfileImage]];
        NSString *nameoFriend = [dictionary objectForKey:kDisplayName];
        [self createIconViewforUser:dictionary withTag:i+100];
    }
}
-(void)searchWithString:(NSString *)searchString{
    if(!searchArray)
        searchArray = [[NSMutableArray alloc]init];
    [searchArray removeAllObjects];
    for (int i=0; i<finalFriendArray.count; i++) {
        NSDictionary *entry = [NSDictionary dictionaryWithDictionary:[finalFriendArray objectAtIndex:i]];
        
        if([[namesArray objectAtIndex:i] rangeOfString:searchString].location != NSNotFound)
        {
            [searchArray addObject:entry];
        }
    }
    for(UIView *view in scrollView.subviews){
        [view removeFromSuperview];
    }
    xValueCount = 0;
    yValueCount = 0;
    for(int i =0; i < searchArray.count ; i++)
    {
        NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:[searchArray objectAtIndex:i]];
        UIImage *image = [UIImage imageWithData:[dictionary objectForKey:kProfileImage]];
        NSString *nameoFriend = [dictionary objectForKey:kDisplayName];
        [self createIconViewforUser:dictionary withTag:i+100];
    }
}
@end
