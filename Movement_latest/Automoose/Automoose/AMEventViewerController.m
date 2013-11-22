//
//  AMEventViewerController.m
//  Automoose
//
//  Created by Srinivas on 19/12/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import "AMEventViewerController.h"
#import "AMEventObject.h"
#import "AMConstants.h"
#import "AMUtility.h"
#import "AMCreateEventController.h"
#import <QuartzCore/QuartzCore.h>
#import "AMTimelineEntity.h"
#import "MFSideMenu.h"
#import "AppDatabase.h"
@interface AMEventViewerController ()
{
    UIButton *showEventasHomepageButton;
    UISegmentedControl *statusSelectionSegmentedControl;
    UILabel *eventNameLable;
    UILabel *inviteesListLabel;
    UILabel *startingTimeLabel;
    UILabel *endingTimeLabel;
    UISegmentedControl *invitationTypeSegmentControl;
    UITextView *notesView;
    UIImageView *homepageSelectionStatusImage;
    BOOL isEventChosenasdefault;
}
@end

@implementation AMEventViewerController
@synthesize eventObject,indexofEvent,isEventEditingAllowed;
@synthesize event;
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
    self.title = [event objectForKey:kNameofEvent];
    isEventEditingAllowed = NO;
    if([[[event objectForKey:kFromUser]objectId ] isEqual:[[PFUser currentUser] objectId]]){
        isEventEditingAllowed = YES;
    }
    [self prepareUIComponents];
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

-(void)prepareUIComponents
{
    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMM-DD-YY HH:mm"];

    showEventasHomepageButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [showEventasHomepageButton setTitle:@"Show Event on Home Page" forState:UIControlStateNormal];
    showEventasHomepageButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
    [showEventasHomepageButton addTarget:self action:@selector(chooseEventAsDefault) forControlEvents:UIControlEventTouchUpInside];
    [showEventasHomepageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIFont *customFont = [UIFont fontWithName:@"Helvetica" size:16];
    NSTextAlignment textAlignment = NSTextAlignmentCenter;
    NSArray *statusSelectionTypes = [[NSArray alloc]initWithObjects:@"Going",@"May be",@"Not going", nil];
    statusSelectionSegmentedControl = [[UISegmentedControl alloc]initWithItems:statusSelectionTypes];
    statusSelectionSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar ;
    [statusSelectionSegmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    eventNameLable = [[UILabel alloc]initWithFrame:CGRectZero];
    eventNameLable.text = [event objectForKey:kNameofEvent];
    eventNameLable.font = customFont;
    eventNameLable.textAlignment = textAlignment;
    eventNameLable.backgroundColor = [UIColor clearColor];
    NSMutableString *inviteesLabelString = [[NSMutableString alloc]init];
    /*
    NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:[[event objectForKey:kInvitees] objectAtIndex:0]];
    [inviteesLabelString appendString:[dictionary objectForKey:kDisplayName]];
    NSArray *invitees = [event objectForKey:kInvitees];
    if([[event objectForKey:kInvitees] count] > 3)
    {
        dictionary = [eventObject.invitees objectAtIndex:1];
        [inviteesLabelString appendString:[NSString stringWithFormat:@",%@",[dictionary objectForKey:kDisplayName]]];
        
        [inviteesLabelString appendString:[NSString stringWithFormat:@"& %d other people",invitees.count - 2]];
    }
    else
    {
        for(int i=1; i< invitees.count ; i++)
        {
            dictionary = [invitees objectAtIndex:i];
            [inviteesLabelString appendString:[NSString stringWithFormat:@",%@",[dictionary objectForKey:kDisplayName]]];
        }
    }
     */
    
    NSArray *invitees = [event objectForKey:kInvitees];
    [inviteesLabelString appendFormat:[NSString stringWithFormat:@"%d people are invited",invitees.count]];
    /*
    PFUser *user = [invitees objectAtIndex:0];

    [inviteesLabelString appendString:[NSString stringWithFormat:@"%@",[user objectForKey:kDisplayName]]];
    if([[event objectForKey:kInvitees] count] > 3)
    {
        PFUser *user = [invitees objectAtIndex:1];

        [inviteesLabelString appendString:[NSString stringWithFormat:@",%@",[user objectForKey:kDisplayName]]];
        
        [inviteesLabelString appendString:[NSString stringWithFormat:@"& %d other people",invitees.count - 2]];
    }
    else
    {
        for(int i=1; i< invitees.count ; i++)
        {
            PFUser *user = [invitees objectAtIndex:i];
            [inviteesLabelString appendString:[NSString stringWithFormat:@",%@",[user objectForKey:kDisplayName]]];
        }
    }
     */
    inviteesListLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    inviteesListLabel.text = inviteesLabelString;
    inviteesListLabel.font = customFont;
    inviteesListLabel.textAlignment = textAlignment;
    inviteesListLabel.backgroundColor = [UIColor clearColor];
    
    startingTimeLabel = [[UILabel alloc]init];
    startingTimeLabel.text = [event objectForKey:kStartingTime];
    startingTimeLabel.font = customFont;
    startingTimeLabel.textAlignment = textAlignment;
    startingTimeLabel.backgroundColor = [UIColor clearColor];
    
    endingTimeLabel = [[UILabel alloc]init];
    endingTimeLabel.text = [event objectForKey:kEndingTime];
    endingTimeLabel.font = customFont;
    endingTimeLabel.textAlignment = textAlignment;
    endingTimeLabel.backgroundColor = [UIColor clearColor];
    
    NSArray *inviationTypes = [[NSArray alloc]initWithObjects:@"Open",@"Invite-only", nil];
    invitationTypeSegmentControl = [[UISegmentedControl alloc]initWithItems:inviationTypes];
    invitationTypeSegmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    invitationTypeSegmentControl.userInteractionEnabled = NO;
    if([[event objectForKey:kTypeofEvent] isEqualToString:@"Open"])
        [invitationTypeSegmentControl setSelectedSegmentIndex:0];
    else
        [invitationTypeSegmentControl setSelectedSegmentIndex:1];
    
    notesView = [[UITextView alloc]initWithFrame:CGRectZero];
    notesView.text = [event objectForKey:kNotes];
    notesView.backgroundColor = [UIColor clearColor];
    notesView.font = customFont;
    notesView.textAlignment = NSTextAlignmentLeft;
    notesView.editable = NO;
    notesView.userInteractionEnabled = NO;
    [notesView.layer setCornerRadius:5];
    [notesView.layer setBorderWidth:1];
    notesView.contentSize = [notesView.text sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:CGSizeMake(100, notesView.contentSize.height) lineBreakMode:UIViewAutoresizingFlexibleHeight];

    notesView.frame = CGRectMake(0, 0, 300, notesView.contentSize.height);
    
    homepageSelectionStatusImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"tick.png"]];
    
    homepageSelectionStatusImage.frame = CGRectMake(5, 7, 24, 24);
    [showEventasHomepageButton addSubview:homepageSelectionStatusImage];
    
    
    if([[NSUserDefaults standardUserDefaults]boolForKey:kDefaultEventSaved])
    {
        NSString *defaultEventId = [[NSUserDefaults standardUserDefaults]objectForKey:kDefaultEvent];
        if([defaultEventId isEqualToString:[event objectId]])
            isEventChosenasdefault = YES;
        else
            isEventChosenasdefault = NO;
    }
  PFUser *user = [event objectForKey:kToUser];
    if(![[user objectId] isEqualToString:[[PFUser currentUser]objectId]])
    {
        invitationTypeSegmentControl.userInteractionEnabled = NO;
//        showEventasHomepageButton.enabled = NO;
        titleHeaders = [[NSArray alloc]initWithObjects:@"Name of the event",@"Invitees",@"Starting Time",@"Ending Time",@"Event Type",@"Notes", nil];
    }
    else
    {
        if([[[event objectForKey:kFromUser] objectId] isEqualToString:[[PFUser currentUser]objectId]])
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editButtonTapped) ];
        titleHeaders = [[NSArray alloc]initWithObjects:@"",@"Your status",@"Name of the event",@"Invitees",@"Starting Time",@"Ending Time",@"Event Type",@"Notes", nil];
        invitationTypeSegmentControl.enabled = YES;
        showEventasHomepageButton.enabled = YES;
    }
    [eventTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)segmentedControlValueChanged:(UISegmentedControl *)sender
{
    self.title = @"Updating...";
    NSString *selectedStatus ;
    switch (sender.selectedSegmentIndex) {
        case 0:
            selectedStatus= kGoing;
//            eventObject.attendanceType = kGoing;
            break;
        case 1:
            selectedStatus = kMaybe;
//            eventObject.attendanceType = kMaybe;
            break;
        case 2:
            selectedStatus = kNotGoing;
//            eventObject.attendanceType = kNotGoing;
            break;
        default:
            break;
    }
    /*
    PFQuery *query = [PFQuery queryWithClassName:kEventActivity];
    [query whereKey:kFromUser equalTo:[[PFUser currentUser] objectId]];
    [query whereKey:kEventId equalTo:eventObject.eventId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array,NSError *error)
     {
         if(!error && array.count)
         {
             PFObject *object  = [array objectAtIndex:0];
             [object setObject:selectedStatus forKey:kAttendanceType];
             [object saveInBackgroundWithBlock:^(BOOL done,NSError *error)
              {
                  self.title = eventObject.nameoftheEvent;
                  if(done)
                  {
                      NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:kEventsList];
                      NSMutableArray *eventsArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                      
                      [eventsArray replaceObjectAtIndex:indexofEvent withObject:eventObject];
                      
                      
                        NSData *timeLineData = [[NSUserDefaults standardUserDefaults]objectForKey:kTimeline];
                       NSMutableArray *timeLine = [NSKeyedUnarchiver unarchiveObjectWithData:timeLineData];
                      for(int i=0;i<timeLine.count;i++) {
                          AMTimelineEntity *timeLineEntity = [timeLine objectAtIndex:i];
                          if([timeLineEntity.eventId isEqualToString:eventObject.eventId]){
                              timeLineEntity.attendanceType = eventObject.attendanceType;
                              [timeLine replaceObjectAtIndex:i withObject:timeLineEntity];
                          }
                      }
                      timeLineData = [NSKeyedArchiver archivedDataWithRootObject:timeLine];
                       [[NSUserDefaults standardUserDefaults]setObject:timeLineData forKey:kTimeline];
                      
                      NSData *data2 = [NSKeyedArchiver archivedDataWithRootObject:eventsArray];
                      [[NSUserDefaults standardUserDefaults]setObject:data2 forKey:kEventsList];
                      [[NSUserDefaults standardUserDefaults]synchronize];
                      
                      
                  }
                  else
                      NSLog(@"Save failed: %@",error.localizedDescription);
              }];
         }
         else
             NSLog(@"%@",error.localizedDescription);
     }];
     */
    
    [event setObject:selectedStatus forKey:kAttendanceType];
    [event saveInBackgroundWithBlock:^(BOOL success,NSError *error){
        self.title = [event objectForKey:kNameofEvent];
        [[NSNotificationCenter defaultCenter]postNotificationName:kReloadtableData object:nil];
        PFQuery *query  =[PFQuery queryWithClassName:kEventActivity ];
        [query whereKey:kFromUser equalTo:[PFUser currentUser]];
        [query whereKey:kParent equalTo:[event objectForKey:kParent]];
        [query whereKey:kObjectId notEqualTo:event];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects,NSError *error){
            for(int i=0;i<objects.count;i++){
                PFObject *object = [objects objectAtIndex:i];
                [object setObject:selectedStatus forKey:kAttendanceType];
                [object saveInBackground];
            }
        }];
        
    }];
    
   
}
-(void)editButtonTapped
{
    AMCreateEventController *createEventController = [[AMCreateEventController alloc]init];
//    [self.navigationController pushViewController:createEventController animated:YES];
    UINavigationController *naviCntrl =[[ UINavigationController alloc]initWithRootViewController:createEventController];
    [self presentModalViewController:naviCntrl animated:YES];
    [createEventController updateDetailstoEditforEvent:event];
}
-(void)chooseEventAsDefault
{
    

    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kFriendTimeLineList];
    [[NSUserDefaults standardUserDefaults]synchronize];
    if(isEventChosenasdefault)
    {
        isEventChosenasdefault = NO;
       if( [[NSUserDefaults standardUserDefaults]boolForKey:kDefaultEventSaved])
           [[NSUserDefaults standardUserDefaults]removeObjectForKey:kDefaultEvent];
        [[NSUserDefaults standardUserDefaults]setBool:NO forKey:kDefaultEventSaved];
        [[NSUserDefaults standardUserDefaults]synchronize];
    }
    else
    {
        isEventChosenasdefault = YES;
        if([[NSUserDefaults standardUserDefaults]boolForKey:kDefaultEventSaved])
           [[NSUserDefaults standardUserDefaults]removeObjectForKey:kDefaultEvent];
        [[NSUserDefaults standardUserDefaults]setObject:[event objectId] forKey:kDefaultEvent];
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:kDefaultEventSaved];
        [[NSUserDefaults standardUserDefaults]synchronize];
        
    }
    [eventTableView reloadData];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"LoadDefaultNotification" object:nil];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 7)
        return notesView.contentSize.height+30;
    return 50;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    NSLog(@"%@",[event objectForKey:kToUser]);
    NSLog(@"%@ %d",[PFUser currentUser],titleHeaders.count);
    return titleHeaders.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
        return [titleHeaders objectAtIndex:section];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
    if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    CGRect frame = CGRectMake( 8, 10, 280, 30);
    NSString *attendanceType;
    cell.textLabel.text = @"";
    if([[[event objectForKey:kToUser] objectId] isEqualToString:[[PFUser currentUser]objectId]])
    {
    switch (indexPath.section) {
        case 0:
            frame.origin.y = 8;
            frame.size.height = 40;
            for(UIView *view in [cell.contentView subviews])
                [view removeFromSuperview];
            showEventasHomepageButton.frame = frame;
            [cell.contentView addSubview:showEventasHomepageButton];
            if(isEventChosenasdefault)
                homepageSelectionStatusImage.hidden = NO;
            else
                homepageSelectionStatusImage.hidden = YES;
            break;
        case 1:
            for(UIView *view in [cell.contentView subviews])
                [view removeFromSuperview];
            statusSelectionSegmentedControl.frame = frame;
            [cell.contentView addSubview:statusSelectionSegmentedControl];
            attendanceType = [event objectForKey:kAttendanceType];
            if([attendanceType isEqualToString:kGoing])
                [statusSelectionSegmentedControl setSelectedSegmentIndex:0];
            else
                if([attendanceType isEqualToString:kMaybe])
                    [statusSelectionSegmentedControl setSelectedSegmentIndex:1];
            else
                if([attendanceType isEqualToString:kNotGoing])
                    [statusSelectionSegmentedControl setSelectedSegmentIndex:2];
         break;
        case 2:
            for(UIView *view in [cell.contentView subviews])
                [view removeFromSuperview];
            eventNameLable.frame = frame;
            [cell.contentView addSubview:eventNameLable];
         break;   
        case 3:
            for(UIView *view in [cell.contentView subviews])
                [view removeFromSuperview];
            inviteesListLabel.frame = frame;
            [cell.contentView addSubview:inviteesListLabel];
        break;
            
        case 4:
            for(UIView *view in [cell.contentView subviews])
                [view removeFromSuperview];
            startingTimeLabel.frame = frame;
            [cell.contentView addSubview:startingTimeLabel];
        break;
            
        case 5:
            for(UIView *view in [cell.contentView subviews])
                [view removeFromSuperview];
            endingTimeLabel.frame = frame;
            [cell.contentView addSubview:endingTimeLabel];
        break;
            
        case 6:
            for(UIView *view in [cell.contentView subviews])
                [view removeFromSuperview];
            invitationTypeSegmentControl.frame = frame;
            [cell.contentView addSubview:invitationTypeSegmentControl];
        break;
            
        case 7:
            for(UIView *view in [cell.contentView subviews])
                [view removeFromSuperview];
            frame.size.height = notesView.contentSize.height+10;
            notesView.frame = frame;
//            [cell.contentView addSubview:notesView];
            cell.textLabel.text = notesView.text;
            cell.textLabel.numberOfLines = 0;
        default:
            break;
    }
    }
    else
    {
        switch (indexPath.section) {
            
           
            case 0:
                for(UIView *view in [cell.contentView subviews])
                    [view removeFromSuperview];
                eventNameLable.frame = frame;
                [cell.contentView addSubview:eventNameLable];
                break;
            case 1:
                for(UIView *view in [cell.contentView subviews])
                    [view removeFromSuperview];
                inviteesListLabel.frame = frame;
                [cell.contentView addSubview:inviteesListLabel];
                break;
                
            case 2:
                for(UIView *view in [cell.contentView subviews])
                    [view removeFromSuperview];
                startingTimeLabel.frame = frame;
                [cell.contentView addSubview:startingTimeLabel];
                break;
                
            case 3:
                for(UIView *view in [cell.contentView subviews])
                    [view removeFromSuperview];
                endingTimeLabel.frame = frame;
                [cell.contentView addSubview:endingTimeLabel];
                break;
                
            case 4:
                for(UIView *view in [cell.contentView subviews])
                    [view removeFromSuperview];
                invitationTypeSegmentControl.frame = frame;
                [cell.contentView addSubview:invitationTypeSegmentControl];
                break;
                
            case 5:
                for(UIView *view in [cell.contentView subviews])
                    [view removeFromSuperview];
                frame.size.height = notesView.contentSize.height+10;
                notesView.frame = frame;
                //            [cell.contentView addSubview:notesView];
                cell.textLabel.text = notesView.text;
                cell.textLabel.numberOfLines = 0;
            default:
                break;
        }
    }
    return cell;
}




@end
