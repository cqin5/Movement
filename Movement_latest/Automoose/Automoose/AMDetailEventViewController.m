//
//  AMDetailEventViewController.m
//  Automoose
//
//  Created by Srinivas on 09/07/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import "AMDetailEventViewController.h"
#import "AMUtility.h"
#import <QuartzCore/QuartzCore.h>
#import "AMConstants.h"
#import "AMUtility.h"
#import "MFSideMenu.h"
#import "AMPlaceViewController.h"
#import "AMPlaceObject.h"
#import "AMEventImageViewer.h"
#import "MBProgressHUD.h"
#import "AMCreateEventController.h"
#import "AMPeopleViewer.h"
#import "ODRefreshControl.h"
@interface AMDetailEventViewController ()
{
    ODRefreshControl *refreshControl;
    UILabel *nameofTheEvent,*eventType,*placeName,*specifcsLabel,*startingTime,*endingTime,*descriptionLabel,*descriptionValue,*goingCount,*mayBeCount,*goingCellLabel,*mayBeCellLabel;
    UIButton *venueButton,*posterButton,*editButton;
    UIScrollView *goingScrollview,*mayBeScrollview;
    CGFloat heightofDescField;
    UIActivityIndicatorView *goingActivityIndicatorView,*mayBeActivityIndicatorView;

    UISegmentedControl *statusControl;
    MBProgressHUD *progress;
    BOOL mayBeFetched,goingFetched;
    NSString *parentId;
}

@end

@implementation AMDetailEventViewController
@synthesize eventData;
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
    table.separatorStyle = UITableViewCellSeparatorStyleNone;
    nameofTheEvent = [self getLabel];
    eventType = [self getLabel];
    placeName = [self getLabel];
    specifcsLabel = [self getLabel];
    startingTime = [self getLabel];
    endingTime = [self getLabel];
    descriptionLabel = [self getLabel];
    descriptionValue = [self getLabel];
    goingCount = [self getLabel];
    mayBeCount = [self getLabel];
    goingCellLabel = [self getLabel];
    mayBeCellLabel = [self getLabel];
    
    venueButton = [self getButton];
    posterButton = [self getButton];
    editButton = [self getButton];
    [venueButton setTitle:@"Venue" forState:UIControlStateNormal];
    [posterButton setTitle:@"Poster" forState:UIControlStateNormal];
    [editButton setTitle:@"Edit" forState:UIControlStateNormal];
    
    [venueButton addTarget:self action:@selector(venueButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [posterButton addTarget:self action:@selector(posterButtonAction) forControlEvents:UIControlEventTouchUpInside];
    [editButton addTarget:self action:@selector(editButtonAction) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *itemArray = [NSArray arrayWithObjects: @"Going", @"May be", @"Not going", nil];
    statusControl = [[UISegmentedControl alloc]initWithItems:itemArray];
    statusControl.frame = CGRectMake(10, 5, 290, 30);
    statusControl.segmentedControlStyle =  UISegmentedControlStyleBar;
    statusControl.selectedSegmentIndex = 0;
    [statusControl addTarget:self action:@selector(statusControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    UIImage *unselectedBackgroundImage = [[UIImage imageNamed:@"unselectedBg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [statusControl setBackgroundImage:unselectedBackgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    UIImage *selectedBackgroundImage = [[UIImage imageNamed:@"selectedBg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [statusControl setBackgroundImage:selectedBackgroundImage forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    UIColor *buttonColor = [UIColor blackColor];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                buttonColor,UITextAttributeTextColor,
                                [UIFont fontWithName:@"HelveticaNeue-Light" size:13],UITextAttributeFont,
                                nil];
    
    [statusControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    UIImage *divider1 = [[UIImage imageNamed:@"right_selected_divider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [statusControl setDividerImage:divider1 forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    UIImage *divider2 = [[UIImage imageNamed:@"left_selected_divider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [statusControl setDividerImage:divider2 forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    [statusControl setDividerImage:[UIImage imageNamed:@"unselectedDividerBg.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    eventType.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12.5];
    eventType.textColor = [AMUtility getColorwithRed:106 green:106 blue:106];
    
    nameofTheEvent.numberOfLines = 0;
    nameofTheEvent.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    nameofTheEvent.textColor = [UIColor blackColor];
    
    placeName.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    placeName.textColor = [UIColor blackColor];
    
    specifcsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    specifcsLabel.textColor = [UIColor blackColor];
    
    startingTime.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    startingTime.textColor = [UIColor blackColor];
    
    endingTime.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    endingTime.textColor = [UIColor blackColor];
    
    descriptionValue.font = [UIFont fontWithName:@"MyriadPro-Regular" size:14];
    descriptionLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12.5];
    descriptionLabel.textColor = [UIColor blackColor];
    descriptionValue.textColor = [UIColor blackColor];
    descriptionValue.numberOfLines = 5;
    descriptionLabel.textColor = [AMUtility getColorwithRed:106 green:106 blue:106];
    
    goingCount.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12.5];
    goingCount.textColor = [AMUtility getColorwithRed:106 green:106 blue:106];
    
    mayBeCount.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:12.5];
    mayBeCount.textColor = [AMUtility getColorwithRed:106 green:106 blue:106];
    
    goingCellLabel.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:20];
    goingCellLabel.numberOfLines = 0;
    
    descriptionLabel.text=@"Description";
    goingCount.text=@"Going (0)";
    mayBeCount.text =@"MayBe (0)";
   
    goingActivityIndicatorView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(130, 35, 30, 30)];
    goingActivityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    goingActivityIndicatorView.hidesWhenStopped = YES;
    
    mayBeActivityIndicatorView = [[UIActivityIndicatorView alloc]initWithFrame:CGRectMake(130, 50, 30, 30)];
    mayBeActivityIndicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    mayBeActivityIndicatorView.hidesWhenStopped = YES;
    
    goingScrollview = [[UIScrollView alloc]init];
    goingScrollview.scrollEnabled = NO;
    
    mayBeScrollview = [[UIScrollView alloc]init];
    mayBeScrollview.scrollEnabled = NO;
    
    refreshControl = [[ODRefreshControl alloc] initInScrollView:table];
    [refreshControl addTarget:self action:@selector(reloadTableData) forControlEvents:UIControlEventValueChanged];
    [self loadRequiredStuff];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//This method does the required loading of various components on the screen.
-(void)loadRequiredStuff{
    if(eventData)
        self.title = [eventData objectForKey:kNameofEvent];
    [goingActivityIndicatorView startAnimating];
    [mayBeActivityIndicatorView startAnimating];
    
    if(eventData)
    {
        BOOL isParticipant = [[[eventData objectForKey:kToUser] objectId] isEqualToString:[[PFUser currentUser] objectId]];
        if(isParticipant)
        {
            if([[eventData objectForKey:kAttendanceType] isEqualToString:kGoing])
                [statusControl setSelectedSegmentIndex:0];
            else if ([[eventData objectForKey:kAttendanceType] isEqualToString:kMaybe])
                [statusControl setSelectedSegmentIndex:1];
            else if ([[eventData objectForKey:kAttendanceType] isEqualToString:kNotGoing])
                [statusControl setSelectedSegmentIndex:2];
            else
                [statusControl setSelectedSegmentIndex:UISegmentedControlNoSegment];
        }
        
        [self getGoingPeopleData];
        [self getMayBePeopleData];
    }
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
//Utility methods to create buttons
-(UIButton *)getButton{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button.layer setBorderWidth:0.5];
    UIColor *buttonColor = [AMUtility getColorwithRed:154 green:154 blue:154];
    [button.layer setBorderColor:buttonColor.CGColor];
    [button setBackgroundColor:[AMUtility getColorwithRed:249 green:249 blue:249]];
    [button.layer setCornerRadius:6];
    [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15]];
    [button setTitleColor:[AMUtility getColorwithRed:67 green:67 blue:67] forState:UIControlStateNormal];
    [button setTitleColor:[AMUtility getColorwithRed:246 green:246 blue:246] forState:UIControlStateHighlighted];
    [button setShowsTouchWhenHighlighted:YES];
    return button;
}
-(UILabel *)getLabel{
    UILabel *label = [[UILabel alloc]init];
    label.backgroundColor = [UIColor clearColor];
    [label setFont:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:15.0]];
    label.textAlignment = NSTextAlignmentLeft;
    label.textColor = [AMUtility getColorwithRed:94 green:94 blue:94];
    return label;
}

#pragma mark table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    BOOL isOwner =  [[[eventData objectForKey:kFromUser] objectId] isEqualToString:[[PFUser currentUser]objectId]];
    if(eventData)
    {
        if(isOwner)
            return 2;
        else
            return 1;
    }

    return 0;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        if(eventData)
        {
            NSString * description = [eventData objectForKey:kNotes];
            BOOL isParticipant = [[[eventData objectForKey:kToUser] objectId] isEqualToString:[[PFUser currentUser] objectId]];
            //        BOOL isOwner =  [[[eventData objectForKey:kFromUser] objectId] isEqualToString:[[PFUser currentUser]objectId]];
            if(!description.length)
            {
                UIFont *font = [UIFont fontWithName:@"MyriadPro-Regular" size:14];
                CGSize maxSize = CGSizeMake(300, 999);
                CGSize newSize = [description sizeWithFont:font constrainedToSize:maxSize lineBreakMode:UIViewAutoresizingFlexibleHeight];
                heightofDescField = newSize.height;
                if(isParticipant)
                    return 7;
                return 6;
            }
            if(isParticipant)
                return 8;
            return 7;
        }
    }
    else
        return 1;
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 1)
        return 66;
    
    BOOL isParticipant = [[[eventData objectForKey:kToUser] objectId] isEqualToString:[[PFUser currentUser] objectId]];
    NSString * description = [eventData objectForKey:kNotes];
    UIFont *font = [UIFont fontWithName:@"MyriadPro-Regular" size:14];
    CGSize maxSize = CGSizeMake(300, 999);
    CGSize newSize = [description sizeWithFont:font constrainedToSize:maxSize lineBreakMode:UIViewAutoresizingFlexibleHeight];
    heightofDescField = newSize.height;
    if(description.length)
    {
        switch (indexPath.row) {
            case 0:
                return 70;
                break;
            case 1:
                return 44;
            case 2:
                return 44;
            case 3:
                return 50;
            case 4:
                if(isParticipant)
                    return 44;
                return 49+heightofDescField;
            case 5:
                 if(isParticipant)
                     return 49+heightofDescField;
                return 100;
            case 6:
                 if(isParticipant)
                     return 100;
                return 120;
            case 7:
                return 120;
            case 8:
                return 44;
            default:
                break;
        }
    }
    else
    {
        switch (indexPath.row) {
            case 0:
                return 70;
                break;
            case 1:
                return 44;
            case 2:
                return 44;
            case 3:
                return 50;
//            case 4:
//                return 130;
            case 4:
                if(isParticipant)
                    return 44;
                return 100;
            case 5:
                if(isParticipant)
                    return 100;
                return 120;
            case 6:
                return 120;
            default:
                break;
        }

    }
       return 0;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
    UIImageView *placeIcon, *timeIcon,*lineView1,*lineView2,*lineView3;
    UIButton *moreNotesButton,*moreGoingButton, *moreMayBeButton;
    if(cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        placeIcon =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"location.png"]];
        timeIcon =[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"clock.png"]];
        
        moreNotesButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreNotesButton setBackgroundImage:[UIImage imageNamed:@"morebutton.png"] forState:UIControlStateNormal];
        [moreNotesButton setBackgroundImage:[UIImage imageNamed:@"morebutton-t.png"] forState:UIControlStateHighlighted];
        
        moreGoingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreGoingButton setBackgroundImage:[UIImage imageNamed:@"morebutton.png"] forState:UIControlStateNormal];
        [moreGoingButton setBackgroundImage:[UIImage imageNamed:@"morebutton-t.png"] forState:UIControlStateHighlighted];
        [moreGoingButton addTarget:self action:@selector(moreGoingButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        moreMayBeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [moreMayBeButton setBackgroundImage:[UIImage imageNamed:@"morebutton.png"] forState:UIControlStateNormal];
        [moreMayBeButton setBackgroundImage:[UIImage imageNamed:@"morebutton-t.png"] forState:UIControlStateHighlighted];
        [moreMayBeButton addTarget:self action:@selector(moreMayBeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        
        lineView1 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"horizontal.png"]];
        lineView2 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"horizontal.png"]];
        lineView3 = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"horizontal.png"]];
    }
    [cell.contentView.subviews enumerateObjectsUsingBlock:^(UIView *view,NSUInteger integer,BOOL *stop){
        [view removeFromSuperview];
    }];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CGRect frame = cell.contentView.frame;
    eventType.frame = CGRectMake(10, 5, 200, 20);
    nameofTheEvent.frame = CGRectMake(10, 20, frame.size.width, 50);
    
    placeIcon.frame = CGRectMake(10, 8, 15, 15);
    placeName.frame = CGRectMake(30, 5, frame.size.width - 30, 20);
    specifcsLabel.frame = CGRectMake(30, 25, frame.size.width - 30, 20);
    
    timeIcon.frame = CGRectMake(10, 8, 15, 15);
    startingTime.frame = CGRectMake(30, 5, frame.size.width - 30, 20);
    endingTime.frame = CGRectMake(30, 25, frame.size.width - 30, 20);
    
    UIFont *font = [UIFont fontWithName:@"MyriadPro-Regular" size:14];
    CGSize maxSize = CGSizeMake(300, 999);
    CGSize newSize = [[eventData objectForKey:kNotes] sizeWithFont:font constrainedToSize:maxSize lineBreakMode:UIViewAutoresizingFlexibleHeight];
    heightofDescField = newSize.height;
    
    descriptionLabel.frame = CGRectMake(10, 5, 100, 16);
    descriptionValue.frame = CGRectMake(10, 25, 300, heightofDescField);
    moreNotesButton.frame = CGRectMake(270, 13+heightofDescField, 45, 35);
     lineView2.frame = CGRectMake(10, moreNotesButton.frame.origin.y+29, 300, 1);
    
    venueButton.frame = CGRectMake(10, 7, 90, 30);
    posterButton.frame = CGRectMake(10+100, 7, 90, 30);
    editButton.frame = CGRectMake(10+100+100, 7, 90, 30);
    lineView1.frame = CGRectMake(10, 45, 300, 1);
    
    lineView3.frame = CGRectMake(10, 45, 300, 1);
    
    goingCount.frame = CGRectMake(10, 5, 100, 20);
    moreGoingButton.frame = CGRectMake(270, 80, 45, 35);
    
    mayBeCount.frame = CGRectMake(10, 5, 100, 20);
    moreMayBeButton.frame = CGRectMake(270, 80, 40, 35);
    
    if([[eventData objectForKey:kTypeofEvent] isEqualToString:@"Open"])
        eventType.text =@"An open event";
    else
        eventType.text =@"An invite-only event";
    nameofTheEvent.text = [eventData objectForKey:kNameofEvent];
    placeName.text = [[eventData objectForKey:kPlaceDetails] objectForKey:kName];
    startingTime.text = [eventData objectForKey:kStartingTime];
    endingTime.text = [eventData objectForKey:kEndingTime];
    descriptionValue.text = [eventData objectForKey:kNotes];
    specifcsLabel.text = [eventData objectForKey:kSpecifics];
    
    goingCellLabel.frame = CGRectMake(10, 30, frame.size.width, 50);
    mayBeCellLabel.frame = CGRectMake(10, 30, frame.size.width, 50);
    
    goingScrollview.frame = CGRectMake(10, goingCount.frame.origin.y+20, 300, 55);
    mayBeScrollview.frame= CGRectMake(10, goingCount.frame.origin.y+20, 300, 55);
    
    BOOL isParticipant = [[[eventData objectForKey:kToUser] objectId] isEqualToString:[[PFUser currentUser] objectId]];
    UIButton *button;
    NSString * description = [eventData objectForKey:kNotes];
    if(indexPath.section == 0)
    {
        switch (indexPath.row) {
            case 0:
                [cell.contentView addSubview:eventType];
                [cell.contentView addSubview:nameofTheEvent];
                break;
            case 1:
                [cell.contentView addSubview:placeIcon];
                [cell.contentView addSubview:placeName];
                [cell.contentView addSubview:specifcsLabel];
                break;
            case 2:
                [cell.contentView addSubview:timeIcon];
                [cell.contentView addSubview:startingTime];
                [cell.contentView addSubview:endingTime];
                break;
            case 3:
                if([[[eventData objectForKey:kFromUser] objectId] isEqualToString:[[PFUser currentUser]objectId]])
                    [cell.contentView addSubview:editButton];
                [cell.contentView addSubview:posterButton];
                [cell.contentView addSubview:venueButton];
                [cell.contentView addSubview:lineView1];
                break;
            case 4:
                if(isParticipant)
                {
                    [cell.contentView addSubview:statusControl];
                    [cell.contentView addSubview:lineView3];
                }
                else
                {
                    if(description.length)
                    {
                        [cell.contentView addSubview:descriptionLabel];
                        [cell.contentView addSubview:descriptionValue];
                        [cell.contentView addSubview:moreNotesButton];
                        [cell.contentView addSubview:lineView2];
                    }
                    else
                    {
                        [cell.contentView addSubview:goingCellLabel];
                        [cell.contentView addSubview:goingCount];
                        [cell.contentView addSubview:goingScrollview];
                        [cell.contentView addSubview:moreGoingButton];
                        [cell.contentView addSubview:goingActivityIndicatorView];
                    }
                }
                break;
                
            case 5:
                if(isParticipant)
                {
                    if(description.length)
                    {
                        [cell.contentView addSubview:descriptionLabel];
                        [cell.contentView addSubview:descriptionValue];
                        [cell.contentView addSubview:moreNotesButton];
                        [cell.contentView addSubview:lineView2];
                    }
                    else
                    {
                        [cell.contentView addSubview:goingCellLabel];
                        [cell.contentView addSubview:goingCount];
                        [cell.contentView addSubview:goingScrollview];
                        [cell.contentView addSubview:moreGoingButton];
                        [cell.contentView addSubview:goingActivityIndicatorView];
                    }
                }
                else
                {
                    if(description.length)
                    {
                        [cell.contentView addSubview:goingCellLabel];
                        [cell.contentView addSubview:goingCount];
                        [cell.contentView addSubview:goingScrollview];
                        [cell.contentView addSubview:moreGoingButton];
                        [cell.contentView addSubview:goingActivityIndicatorView];
                    }
                    else
                    {
                        [cell.contentView addSubview:mayBeCellLabel];
                        [cell.contentView addSubview:mayBeCount];
                        [cell.contentView addSubview:mayBeScrollview];
                        [cell.contentView addSubview:moreMayBeButton];
                        [cell.contentView addSubview:mayBeActivityIndicatorView];
                    }
                }
                
                break;
            case 6:
                if(isParticipant)
                {
                    if(description.length)
                    {
                        [cell.contentView addSubview:goingCellLabel];
                        [cell.contentView addSubview:goingCount];
                        [cell.contentView addSubview:goingScrollview];
                        [cell.contentView addSubview:moreGoingButton];
                        [cell.contentView addSubview:goingActivityIndicatorView];
                    }
                    else
                    {
                        [cell.contentView addSubview:mayBeCellLabel];
                        [cell.contentView addSubview:mayBeCount];
                        [cell.contentView addSubview:mayBeScrollview];
                        [cell.contentView addSubview:moreMayBeButton];
                        [cell.contentView addSubview:mayBeActivityIndicatorView];
                    }
                }
                else
                {
                    [cell.contentView addSubview:mayBeCellLabel];
                    [cell.contentView addSubview:mayBeCount];
                    [cell.contentView addSubview:mayBeScrollview];
                    [cell.contentView addSubview:moreMayBeButton];
                    [cell.contentView addSubview:mayBeActivityIndicatorView];
                }
                break;
            case 7:
                [cell.contentView addSubview:mayBeCellLabel];
                [cell.contentView addSubview:mayBeCount];
                [cell.contentView addSubview:mayBeScrollview];
                [cell.contentView addSubview:moreMayBeButton];
                [cell.contentView addSubview:mayBeActivityIndicatorView];
                break;
            default:
                break;
        }
    }
    else
    {
        button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(10, 10, 300, 44);
        [button setBackgroundImage:[UIImage imageNamed:@"redColorBg.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"whiteBg"] forState:UIControlStateHighlighted];
        [cell.contentView  addSubview:button];
        [button setTitle:@"Delete Event" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        cell.backgroundView = [UIView new];
        cell.backgroundColor = [UIColor clearColor];
        [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
        [button addTarget:self action:@selector(deleteEvent) forControlEvents:UIControlEventTouchUpInside];
        button.clipsToBounds = YES;
        button.layer.cornerRadius = 10;
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark button methods

//Method to delete event
-(void)deleteEvent{
    progress = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    [progress setDimBackground:NO];
    [progress setLabelText:@"Deleting.."];
    self.view.userInteractionEnabled = NO;
    parentId = [eventData objectForKey:kParent];
    [eventData deleteInBackgroundWithBlock:^(BOOL succeeded,NSError *err){
        self.view.userInteractionEnabled = YES;
        progress.hidden = YES;
        if(succeeded && !err)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:kReloadtableData object:nil];
            [AMUtility deleteEventWithParentId:parentId];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else
            [AMUtility showAlertwithTitle:@"Error" andMessage:err.localizedDescription];
    }];
}

//Method to show venue details.
-(void)venueButtonAction{
    AMPlaceViewController *placeViewController = [[AMPlaceViewController alloc]init];
    NSDictionary *placeData = [eventData objectForKey:kPlaceDetails];
    progress = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    [progress setDimBackground:NO];
    [progress setLabelText:@"Loading..."];  
    PFFile *placeFile = [placeData objectForKey:kImage];
    [placeFile getDataInBackgroundWithBlock:^(NSData *data,NSError *error){
        [MBProgressHUD hideHUDForView:self.view  animated:YES];
        if(!error)
        {
            AMPlaceObject *placeObject = [[AMPlaceObject alloc]init];
            placeObject.nameofPlace = [placeData objectForKey:kName];
            placeObject.placeIcon = [UIImage imageWithData:data];
            placeObject.latitude = [[[placeData objectForKey:kLocation] objectForKey:kLatitude] floatValue];
            placeObject.longitude = [[[placeData objectForKey:kLocation] objectForKey:kLongitude] floatValue];
            placeObject.rating = [placeData objectForKey:kRating];
            placeObject.iconUrl = [placeData objectForKey:kIconUrl];
            placeObject.isImageDownloaded = 1;
            placeObject.address = [placeData objectForKey:kAddress];
            placeObject.phoneNumber = [placeData objectForKey:kDisplay_phone];
            placeObject.mobileUrl = [placeData objectForKey:kMobile_url];
            placeObject.categories = [placeData objectForKey:kCategories];
            
            placeViewController.placeObj = placeObject;
            UINavigationController *naviContrlr  = [[UINavigationController alloc]initWithRootViewController:placeViewController];
            naviContrlr.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            [self presentModalViewController:naviContrlr animated:YES];
        }
    }];
}


//Here we retrieve details of people going to the event. 
-(void)getGoingPeopleData{
    if(!goingPeopleData)
        goingPeopleData  = [[NSMutableArray alloc]init];
    [goingPeopleData removeAllObjects];
    NSArray *conditions = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%@",kUpdated],[NSString stringWithFormat:@"%@",kAttended], nil];
    
    PFQuery *query  = [PFQuery queryWithClassName:kEventActivity];
    [query whereKey:kParent equalTo:[eventData objectForKey:kParent]];
    [query whereKey:kAttendanceType equalTo:kGoing];
    [query orderByAscending:kUpdatedAt];
    [query whereKey:kEventActivityType notContainedIn:conditions];
     
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects,NSError *error){
        
//        goingPeopleData = objects;
        if(!objects.count)
        {
            goingCellLabel.text = @"No people are going for now. :(";
            goingFetched = YES;
            [self setPeopleAttendanceStatus];
            [goingScrollview removeFromSuperview];
            [goingActivityIndicatorView stopAnimating];
        }
        else
        {
            goingCount.text = [NSString stringWithFormat:@"Going(%d)",objects.count];
        }
        [objects enumerateObjectsUsingBlock:^(PFObject *object,NSUInteger index,BOOL *stop){
            PFUser *user = [object objectForKey:kToUser];
            PFImageView *imageview = [[PFImageView alloc]initWithFrame:CGRectMake(5*(index+1)+(55*index), 5, 55,55)];
            [user fetchIfNeededInBackgroundWithBlock:^(PFObject *obj,NSError *error){
                imageview.file = [obj objectForKey:kProfileImage];
                imageview.image = [UIImage imageNamed:@"person_icon.png"];
                [goingScrollview addSubview:imageview];
                [imageview loadInBackground];
                [goingActivityIndicatorView stopAnimating];
                [goingPeopleData addObject:user];
                goingFetched = YES;
                [self setPeopleAttendanceStatus];
            }];
            
        }];
     }];
}

//Here we retrieve details of people who might go to the event
-(void)getMayBePeopleData{
    if(!mayBePeopleData)
        mayBePeopleData = [[NSMutableArray alloc]init];
    [mayBePeopleData removeAllObjects];
    PFQuery *query  = [PFQuery queryWithClassName:kEventActivity];
    [query whereKey:kParent equalTo:[eventData objectForKey:kParent]];
    [query whereKey:kAttendanceType equalTo:kMaybe];
    [query orderByAscending:kUpdatedAt];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects,NSError *error){
        
//        mayBePeopleData = objects;
        if(!objects.count)
        {
            mayBeFetched = YES;
            [self setPeopleAttendanceStatus];
//            mayBeCellLabel.text = @"No people are going for now. :(";
//            [mayBeScrollview removeFromSuperview];
//            [mayBeActivityIndicatorView stopAnimating];
        }
        else
        {
            mayBeCount.text = [NSString stringWithFormat:@"MayBe(%d)",objects.count];
        }
        [objects enumerateObjectsUsingBlock:^(PFObject *object,NSUInteger index,BOOL *stop){
            PFUser *user = [object objectForKey:kToUser];
            PFImageView *imageview = [[PFImageView alloc]initWithFrame:CGRectMake(5*(index+1)+(55*index), 5, 55,55)];
            [user fetchIfNeededInBackgroundWithBlock:^(PFObject *obj,NSError *error){
                imageview.file = [obj objectForKey:kProfileImage];
                imageview.image = [UIImage imageNamed:@"person_icon.png"];
                [mayBeScrollview addSubview:imageview];
                [imageview loadInBackground];
                [mayBeActivityIndicatorView stopAnimating];
                [mayBePeopleData addObject:user];
            }];
            
        }];
    }];
}

//Show poster on full screen
-(void)posterButtonAction{
    AMEventImageViewer *controller = [[AMEventImageViewer alloc]init];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    if([eventData objectForKey:kPosterImage])
    {
        [controller loadFileinBackground: [eventData objectForKey:kPosterImage]];
    }
    else if([[eventData objectForKey:kTypeofEvent] isEqualToString:@"Open"])
    {
        UIImage *posterImage = [UIImage imageNamed:@"defaultpublic.png"];
        if(kIsIphone568)
            posterImage = [UIImage imageNamed:@"defaultpublic-568h.png"];
        [controller loadImage:posterImage];
    }
    else
    {
        UIImage *posterImage = [UIImage imageNamed:@"defaultprivate.png"];
        if (kIsIphone568) {
            posterImage = [UIImage imageNamed:@"defaultprivate-568h.png"];
        }
        [controller loadImage:posterImage];

    }
}

//Method to show edit screen
-(void)editButtonAction{
    AMCreateEventController *controller = [[AMCreateEventController alloc]init];
    [self.navigationController pushViewController:controller animated:YES];
    [controller updateDetailstoEditforEvent:eventData];
    controller.navigationItem.hidesBackButton = NO;
}

//This method is called when status of user attedance is altered using segmented control
-(void)statusControlValueChanged:(UISegmentedControl *)control{
    progress = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    [progress setDimBackground:NO];
    [progress setLabelText:@"Updating.."];
    NSString *statusControlString;
    if(control.selectedSegmentIndex == 0)
        statusControlString= kGoing;
    else if (control.selectedSegmentIndex == 1)
        statusControlString = kMaybe;
    else if (control.selectedSegmentIndex == 2)
        statusControlString = kNotGoing;
    [eventData setObject:statusControlString forKey:kAttendanceType];
    [eventData saveInBackgroundWithBlock:^(BOOL succeded,NSError *error){
        
        if(!succeded)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
        else
        {
//            [progress setLabelText:@"Saved"];
            [self updateOtherEntriesStatuswithParentEntry:eventData withStatus:statusControlString];
            [[NSNotificationCenter defaultCenter]postNotificationName:kReloadtableData object:nil];
        }
        progress.hidden = YES;
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

-(void)updateTableDatawithEvent:(PFObject *)event
{
    [table reloadData];
}


//Show all users who are going to event in people viewer controller
-(void)moreGoingButtonAction{
    AMPeopleViewer *peopleViewer = [[AMPeopleViewer alloc]init];
    peopleViewer.peopleArray = [NSArray arrayWithArray:goingPeopleData];
    peopleViewer.titleString = @"Going";
    [self.navigationController pushViewController:peopleViewer animated:YES];
    
}

//Show all users who might go to event in people viewer controller
-(void)moreMayBeButtonAction{
    AMPeopleViewer *peopleViewer = [[AMPeopleViewer alloc]init];
    peopleViewer.peopleArray = [NSArray arrayWithArray:mayBePeopleData];
    peopleViewer.titleString = @"May be";
    [self.navigationController pushViewController:peopleViewer animated:YES];
}

//Method to show appropriate status in the table view
-(void)setPeopleAttendanceStatus{
    if(mayBeFetched && goingFetched && !mayBePeopleData.count && !goingPeopleData.count){
        mayBeCellLabel.text = @"No people are going for now. :(";
        [mayBeScrollview removeFromSuperview];
        [mayBeActivityIndicatorView stopAnimating];
    }
    else if(mayBePeopleData && goingFetched && !mayBePeopleData.count && goingPeopleData.count)
    {
        mayBeCellLabel.text = @"Everybody is going";
        [mayBeScrollview removeFromSuperview];
        [mayBeActivityIndicatorView stopAnimating];
    }
}

-(void)reloadTableData{
    PFQuery *query = [PFQuery queryWithClassName:kEventActivity];
    [query whereKey:kObjectId equalTo:[eventData objectId]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object, NSError *error){
        if(!error && object){
           eventData = nil;
            eventData = object;
            NSLog(@"ScrlView Count: %d",goingScrollview.subviews.count);
            NSArray *viewsToRemove = [goingScrollview subviews];
            for (UIView *v in viewsToRemove) [v removeFromSuperview];
            
            viewsToRemove = [mayBeScrollview subviews];
            for (UIView *v in viewsToRemove) [v removeFromSuperview];

            [self loadRequiredStuff];
        }
        else
        {
            eventData = nil;
        }
        [refreshControl endRefreshing];
    }];
}
@end
