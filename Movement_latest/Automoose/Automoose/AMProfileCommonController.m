//
//  AMProfileCommonController.m
//  Automoose
//
//  Created by Srinivas on 12/2/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import "AMProfileCommonController.h"
#import "AMAppDelegate.h"
#import "AMConstants.h"
#import "MFSideMenu.h"
//#import "MyLogInViewController.h"
#import "AMFacebookLoginController.h"
#import "AMUtility.h"
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import <Parse/Parse.h>
@interface AMProfileCommonController ()
{
    UIView *titleView;
    UIButton *prevButton;
    
}
@property(nonatomic,strong)MBProgressHUD *hud;;
@end

@implementation AMProfileCommonController
@synthesize hud;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Settings", @"Settings");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Logout " style:UIBarButtonItemStylePlain target:self action:@selector(logout)];
    [self setupMenuBarButtonItems];

    
    profileImage = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 40, 40)];
    [profileImage.layer setCornerRadius:20];
    profileImage.clipsToBounds = YES;
    
    nameLabel = [AMUtility getLabelforTableHeader];
    sinceLabel = [AMUtility getLabelforTableHeader];
    facebookLink = [AMUtility getLabelforTableHeader];
    discoverable = [AMUtility getLabelforTableHeader];
    autoUpdate = [AMUtility getLabelforTableHeader];
    
    discoverableSwitch = [[RCSwitchOnOff alloc]initWithFrame:CGRectMake(200, 10, 80, 27)];
    discoverableSwitch.on = YES;
    [discoverableSwitch addTarget:self action:@selector(locationDiscoverablePermissionsValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    autoUpdateSwitch = [[RCSwitchOnOff alloc]initWithFrame:CGRectMake(200, 10, 80, 27)];
    autoUpdateSwitch.on = YES;
    [autoUpdateSwitch addTarget:self action:@selector(allowAutoupdateValueChanged:) forControlEvents:UIControlEventValueChanged];

    nameLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    sinceLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11];
    facebookLink.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    discoverable.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    autoUpdate.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    
    nameLabel.text = [[PFUser currentUser]objectForKey:kDisplayName];
    profileImage.image = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kProfileImage_small]];
    
    if([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
        facebookLink.text = @"Already linked with facebook";
    else
        facebookLink.text = @"Link with facebook";
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    int index = [[userDefaults objectForKey:kAllowLocationTracking]intValue];
    discoverableSwitch.on = index;
    
    if(!index)
        autoUpdateSwitch.enabled = NO;
    index = [[userDefaults objectForKey:kAllowAutoUpdate]intValue];
    autoUpdateSwitch.on = index;
    discoverable.text =@"Discoverable";
    autoUpdate.text = @"Auto-update";
    UIView *bgView = [[UIView alloc]initWithFrame:profileTableview.frame];
    bgView.backgroundColor = [UIColor whiteColor];
    profileTableview.backgroundView = bgView;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    profileImage.image = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kProfileImage_small]];
    [titleView addSubview:prevButton];
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [prevButton removeFromSuperview];
    
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

-(void)logout
{
    [(AMAppDelegate *)[[UIApplication sharedApplication]delegate] logout];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)editButtonTapped:(UIButton *)sender
{
    switch (sender.tag) {
        case 100:
            nameField.enabled = YES;
            [nameField becomeFirstResponder];
            [editButton setTitle:@"Done" forState:UIControlStateNormal];
            sender.tag = 101;
            break;
        case 101:
            [[PFUser currentUser] setObject:nameField.text forKey:kDisplayName];
            [[PFUser currentUser]saveInBackground];
            nameField.enabled = NO;
            [nameField resignFirstResponder];
            [editButton setTitle:@"Edit" forState:UIControlStateNormal];
            sender.tag = 100;
            break;
        default:
            break;
    }
    
}

#pragma mark location preferences
-(void)locationDiscoverablePermissionsValueChanged:(RCSwitchOnOff *)segmentedControl
{
    BOOL value= segmentedControl.on;
   
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:kAllowLocationTracking];
    [userDefaults synchronize];
    if (!value) {
//        locationAutoupdate.enabled = NO;
        autoUpdateSwitch.enabled = NO;
        autoUpdateSwitch.alpha = 0.5;
        [profileTableview reloadRowsAtIndexPaths: [NSArray arrayWithObject:[NSIndexPath indexPathForRow:1 inSection:1]] withRowAnimation:UITableViewRowAnimationNone];
        [[(AMAppDelegate *)[UIApplication sharedApplication].delegate locationTimer]invalidate];;
    }
    else
    {
         [(AMAppDelegate *)[[UIApplication sharedApplication]delegate] scheduleLocationUpdate];
//        locationAutoupdate.enabled =YES;
        autoUpdateSwitch.enabled = YES;
        autoUpdateSwitch.alpha = 1.0;
    }
    
}
-(void)allowAutoupdateValueChanged:(RCSwitchOnOff *)segmentedControl
{
    BOOL value= segmentedControl.on;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:value forKey:kAllowAutoUpdate];
    [userDefaults synchronize];
}
#pragma mark text field
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    nameString = textField.text;
    return YES;
}
#pragma mark tableview delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0 || section == 1)
        return 2;
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0 || section == 1)
        return 33;
    return 0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 300, 33)];
    UILabel *headerViewLabel = [AMUtility getLabelforTableHeader];
    headerViewLabel.frame = CGRectMake(15, 0, 200, 33);
    if(section == 0)
        headerViewLabel.text =@"Accounts";
    else if (section == 1)
        headerViewLabel.text =@"Location Preferences";
    else
        headerViewLabel.text = @"";
    [headerView addSubview:headerViewLabel];
    return headerView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0)
        return 80;
    else if (indexPath.section == 1)
        return 44;
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    UIView *hightlightBackground = [[UIView alloc]init];
   
    nameLabel.frame = CGRectMake(85, 18, 210, 30);
    sinceLabel.frame = CGRectMake(85, 37, 210, 30);
    sinceLabel.text =[NSString stringWithFormat: @"Since %@",[[PFUser currentUser] objectForKey:kAccountCreatedDate]];
    
    facebookLink.frame = CGRectMake(85, 25, 210, 30);
    UIImageView *facebookImage = [[UIImageView alloc]initWithFrame:CGRectMake(20, 20, 40, 40)];
    facebookImage.image = [UIImage imageNamed:@"facebookImage.png"];
    
    discoverable.frame = CGRectMake(10, 5, 100, 34);
    autoUpdate.frame =CGRectMake(10, 5, 100, 34);
    cell.backgroundColor =    [AMUtility getColorwithRed:236 green:236 blue:236];
    
    cell.selectionStyle =UITableViewCellSelectionStyleNone;
   
    if(indexPath.section == 0){
        if(indexPath.row == 0)
        {
            [cell.contentView addSubview:profileImage];
            [cell.contentView addSubview:nameLabel];
            [cell.contentView addSubview:sinceLabel];
            nameLabel.text = [[PFUser currentUser]objectForKey:kDisplayName];
            profileImage.image = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] objectForKey:kProfileImage_small]];
        }
        else
        {
            [cell.contentView addSubview:facebookLink];
            [cell.contentView addSubview:facebookImage];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.selectedBackgroundView = hightlightBackground;
            hightlightBackground.backgroundColor = [AMUtility getColorwithRed:67 green:67 blue:67];
            facebookLink.highlightedTextColor = [AMUtility getColorwithRed:240 green:240 blue:240];
            hightlightBackground.frame = CGRectMake(0, 0, 303, 80);
            [self setMaskforHighlightedBackground:hightlightBackground byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight];
            if([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
                facebookLink.text = @"Already linked with facebook";
            else
                facebookLink.text = @"Link with facebook";
        }
    }
    else if (indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            [cell.contentView addSubview:discoverable];
            [cell.contentView addSubview:discoverableSwitch];
        }
        else
        {

            [cell.contentView addSubview:autoUpdate];
            [cell.contentView addSubview:autoUpdateSwitch];
        }

    }
    else if (indexPath.section == 2)
    {
        cell.textLabel.text =@"Log out";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.selectedBackgroundView = hightlightBackground;
        hightlightBackground.backgroundColor = [AMUtility getColorwithRed:67 green:67 blue:67];
        cell.textLabel.highlightedTextColor = [AMUtility getColorwithRed:240 green:240 blue:240];
        hightlightBackground.frame = CGRectMake(0, 0, 303, 44);
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        [self setMaskforHighlightedBackground:hightlightBackground byRoundingCorners:UIRectCornerAllCorners];
       
    }
    else
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 300, 44);
        [button setBackgroundImage:[UIImage imageNamed:@"redColorBg.png"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"whiteBg"] forState:UIControlStateHighlighted];
        [cell.contentView  addSubview:button];
        [button setTitle:@"Permanently delete my account" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
        cell.backgroundView = [UIView new];
        cell.backgroundColor = [UIColor clearColor];
        [button.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
        [button addTarget:self action:@selector(permanentlyDeleteButtonAction) forControlEvents:UIControlEventTouchUpInside];
        button.clipsToBounds = YES;
        button.layer.cornerRadius = 10;
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
//        [self setMaskforHighlightedBackground:button byRoundingCorners:UIRectCornerAllCorners];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 0 && indexPath.row == 1)
    {
        [self linkUsertoFacebook];
    }
    else if (indexPath.section == 2)
    {
     [(AMAppDelegate *)[[UIApplication sharedApplication]delegate] logout];   
    }
    else if (indexPath.section == 3)
    {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Are you sure? Your data can never be retrieved!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
//        alert.tag = 3000;
//        [alert show];
    }
    
}
-(void)permanentlyDeleteButtonAction{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Are you sure? Your data can never be retrieved!" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Yes", nil];
    alert.tag = 3000;
    [alert show];

}

-(void)linkUsertoFacebook {
  
    
    if(![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
    {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [hud setDimBackground:YES];
        [hud setLabelText:@"Linking with facebook"];
        [PFFacebookUtils linkUser:[PFUser currentUser] permissions:[NSArray arrayWithObjects:@"friends_about_me", nil] block:^(BOOL success,NSError *error){
            hud.hidden = YES;
            if(!success && error)
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
            }
            else
            {
                /*
                FBRequest *request = [FBRequest requestForGraphPath:@"me/?fields=name,picture,email"];
//                [request setDelegate:self];
                [request startWithCompletionHandler:NULL];
                */
                
                
                [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    if (!error) {
                        [self facebookRequestDidLoad:result];
                    } else {
                        [self facebookRequestDidFailWithError:error];
                    }
                }];
                
                if ([PFUser currentUser]) {
                    NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", [[PFUser currentUser] objectId]];
                    [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:@"user"];
                    [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:@"channels"];
                    [[PFInstallation currentInstallation] saveEventually];
                    [[PFUser currentUser] setObject:privateChannelName forKey:@"channel"];
                    [[PFUser currentUser] saveInBackground];
                    [profileTableview reloadData];
                    [AMUtility fetchFollowing:^(NSError *error){}];
                    nameField.text = [[PFUser currentUser]objectForKey:kDisplayName];
                }
            }
        }];
    }
    else
    {
        
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Do you want to unlink with facebook?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
        alert.tag = 2000;
        [alert show];
        
        
    }
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 2000){
        if(buttonIndex == 1){
            hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            [hud setDimBackground:YES];
            [hud setLabelText:@"Unlinking with facebook"];
            [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL success, NSError *error){
                [profileTableview reloadData];
                
                if(!success)
                {
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [alert show];
                }
                else{
                    [profileTableview reloadData];
                }
                hud.hidden = YES;
                
            }];
        }
    }
    else if (alertView.tag == 3000){
          if(buttonIndex == 1){
              hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
              [hud setDimBackground:YES];
              if([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]){
                  [self unlinkFromFaceBook];
              }
              else
              {
                  
                  [self permanentlyDeleteAccount];
              }
          }
    }
}
-(void)unlinkFromFaceBook{
    [hud setLabelText:@"Unlinking with facebook"];
    [PFFacebookUtils unlinkUserInBackground:[PFUser currentUser] block:^(BOOL success, NSError *error){
        
        if(!success)
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alert show];
        }
        else{
            [self permanentlyDeleteAccount];
        }
    }];

    /*
    NSArray *permissionsArray =  [NSArray arrayWithObjects:nil];
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser *user , NSError *error){
        if(error)
            [AMUtility showAlertwithTitle:@"Error" andMessage:error.localizedDescription];
        else
        {
        }
    }];
     */
}

-(void)permanentlyDeleteAccount{
    [hud setLabelText:@"Deleting account details"];
    PFQuery *query1 =[PFQuery queryWithClassName:@"Activity"];
    [query1 whereKey:kFromUser equalTo:[[PFUser currentUser] objectId]];
    
    PFQuery *query2 =[PFQuery queryWithClassName:@"Activity"];
    [query2 whereKey:kToUser equalTo:[[PFUser currentUser] objectId]];
    
    PFQuery *combinedActivityQuery = [PFQuery orQueryWithSubqueries:@[query1,query2]];
    [combinedActivityQuery findObjectsInBackgroundWithBlock:^(NSArray *objects,NSError *err){
        if(err)
        {
            [AMUtility showAlertwithTitle:@"Error" andMessage:err.localizedDescription];
        }
        else
        {
            for (int i=0; i<objects.count; i++) {
                PFObject *entry  =[objects objectAtIndex:i];
                NSError *e1;
                [entry delete:&e1];
                if(e1)
                {
                    [AMUtility showAlertwithTitle:@"Error" andMessage:e1.localizedDescription];
                }
            }
            
//            [objects enumerateObjectsUsingBlock:^(PFObject *entry,NSUInteger index, BOOL *stop)
//             {
//
//                 NSError *e1;
//                 [entry delete:&e1];
//                 if(e1)
//                 {
//                        [AMUtility showAlertwithTitle:@"Error" andMessage:e1.localizedDescription];
//                 }
////                 [entry deleteInBackgroundWithBlock:^(BOOL succedded,NSError *err){
////                     NSLog(@"AGAIN: %@",entry);
////                     if(err)
////                     {
////                         [AMUtility showAlertwithTitle:@"Error" andMessage:err.localizedDescription];
////                     }
////                 }];
//             }];
        }
    }];

    
    PFQuery *locationQuery =  [PFQuery queryWithClassName:@"LocationData"];
    [locationQuery whereKey:kFromUser equalTo:[PFUser currentUser]];
    [locationQuery getFirstObjectInBackgroundWithBlock:^(PFObject *object,NSError *error){
        [object deleteEventually];
    }];
    
    PFQuery *eventActivityQuery1 = [PFQuery queryWithClassName:kEventActivity ];
    [eventActivityQuery1 whereKey:kFromUser equalTo:[PFUser currentUser]];
    [eventActivityQuery1 findObjectsInBackgroundWithBlock:^(NSArray *objects,NSError *err){
       if(err)
           [AMUtility showAlertwithTitle:@"Error" andMessage:err.localizedDescription];
        else
        {
            [objects enumerateObjectsUsingBlock:^(PFObject *obj,NSUInteger index, BOOL *stop){
                [obj deleteInBackground];
            }];
        }
    }];
    
    PFQuery *eventActivityQuery2 = [PFQuery queryWithClassName:kEventActivity ];
    [eventActivityQuery2 whereKey:kToUser equalTo:[PFUser currentUser]];
    [eventActivityQuery2 whereKey:kFromUser notEqualTo:[PFUser currentUser]];
    [eventActivityQuery2 findObjectsInBackgroundWithBlock:^(NSArray *objects,NSError *err){
        if(err)
            [AMUtility showAlertwithTitle:@"Error" andMessage:err.localizedDescription];
        else
        {
            [objects enumerateObjectsUsingBlock:^(PFObject *obj,NSUInteger index, BOOL *stop){
                PFQuery *updateQuery = [PFQuery queryWithClassName:kEventActivity];
                [updateQuery whereKey:kParent equalTo:[obj objectForKey:kParent]];
                [updateQuery whereKey:kToUser notEqualTo:[PFUser currentUser]];
                [updateQuery findObjectsInBackgroundWithBlock:^(NSArray *updateObjs,NSError *err1){
                    if(err1)
                        [AMUtility showAlertwithTitle:@"Error" andMessage:err1.localizedDescription];
                    else
                    {
                        [updateObjs enumerateObjectsUsingBlock:^(PFObject *event,NSUInteger index,BOOL *stop){
                            NSMutableArray *invitees = [NSMutableArray arrayWithArray:[event objectForKey:kInvitees]];
                            for(int i=0;i<invitees.count;i++)
                            {
                                PFUser *user = [invitees objectAtIndex:i];
                                if([[user objectId] isEqualToString:[[PFUser currentUser] objectId]])
                                {
                                    [invitees removeObjectAtIndex:i];
                                    [event setObject:invitees forKey:kInvitees];
                                    [event save];
                                    break;
                                }
                            }
                        }];
                        
                    }

                    [obj deleteInBackground];
                }];
               
                
            }];
        }
     
    }];
    
//    [self logout];
    
    
    NSString *privateChannelName = [[PFUser currentUser] objectForKey:@"channel"];
    [[PFInstallation currentInstallation]save];
    [[PFInstallation currentInstallation]saveEventually:^(BOOL status, NSError *err){
        if(status) {
            [[PFInstallation currentInstallation]removeObject:privateChannelName forKey:@"channels"];
            [[PFInstallation currentInstallation]saveEventually:^(BOOL success,NSError *error){
                
                if(success)
                {
                    
                    [[PFUser currentUser]deleteInBackgroundWithBlock:^(BOOL success,NSError *err){
                        if(!err)
                        {
                            [PFQuery clearAllCachedResults];
                            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                            [defaults removeObjectForKey:kDefaultEvent];
                            [defaults removeObjectForKey:kDefaultEventSaved];
                            [defaults removeObjectForKey:kFriends];
                            [defaults removeObjectForKey:kFollowing];
                            [defaults removeObjectForKey:kFollowers];
                            [defaults removeObjectForKey:kFriendTimeLineList];
                            [defaults removeObjectForKey:kCreatedDate];
                            [defaults removeObjectForKey:kEventId];
                            [defaults removeObjectForKey:kEventsList];
                            [defaults removeObjectForKey:kBadgeNumber];
                            [defaults removeObjectForKey:kProfileImage_small];
                            [defaults removeObjectForKey:kBadgeNumber];
                            [defaults removeObjectForKey:kIsAppRunningFirstTime];
                            [defaults removeObjectForKey:kFollowersCount];
                            [defaults removeObjectForKey:kFollowingCount];
                            [defaults removeObjectForKey:kTimeline];
                            [defaults removeObjectForKey:kCoreEventData];
                            [defaults removeObjectForKey:kLastSyncdDate];
                            [defaults removeObjectForKey:kLocationObjectId];
                            [defaults removeObjectForKey:kProfileImage_Big];
                            
                            AMAppDelegate *appDelegate = (AMAppDelegate *)[[UIApplication sharedApplication]delegate];
                            appDelegate.tabBarController = NO;
                            [PFUser logOut];
                            hud.hidden = YES;
                            [[(AMAppDelegate *)[[UIApplication sharedApplication]delegate] navController] popToRootViewControllerAnimated:NO];
                            [(AMAppDelegate *)[[UIApplication sharedApplication]delegate] presentLoginScreen];
                        }
                        else
                        {
                            [AMUtility showAlertwithTitle:@"Error" andMessage:err.localizedDescription];
                        }
                    }];
                     
                    
                }
                else
                {
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert!" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [alertView show];
                }
            }];
        }
        else
        {
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert!" message:err.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alertView show];
        }
    }];

    

    
}

#pragma mark - PF_FBRequestDelegate
- (void)request:(FBRequest *)request didLoad:(id)result {
    // This method is called twice - once for the user's /me profile, and a second time when obtaining their friends. We will try and handle both scenarios in a single method.
    
    NSArray *data = [result objectForKey:@"data"];
    
    if (data) {
        if (![[PFUser currentUser] objectForKey:@"userAlreadyAutoFollowedFacebookFriends"])
        {
            NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:data.count];
            for (NSDictionary *friendData in data) {
                [facebookIds addObject:[friendData objectForKey:@"id"]];
            }
            [self.hud setLabelText:@"Following Friends"];
            
            
            [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"userAlreadyAutoFollowedFacebookFriends"];
            NSError *error = nil;
            
            // find common Facebook friends already using Anypic
            PFQuery *facebookFriendsQuery = [PFUser query];
            [facebookFriendsQuery whereKey:@"facebookId" containedIn:facebookIds];
        
            NSArray *anypicFriends = [facebookFriendsQuery findObjects:&error];
            
            if (!error) {
                [anypicFriends enumerateObjectsUsingBlock:^(PFUser *newFriend, NSUInteger idx, BOOL *stop) {
                    PFObject *joinActivity = [PFObject objectWithClassName:@"Activity"];
                    [joinActivity setObject:[PFUser currentUser] forKey:@"fromUser"];
                    [joinActivity setObject:newFriend forKey:@"toUser"];
                    [joinActivity setObject:@"joined" forKey:@"type"];
                    
                    PFACL *joinACL = [PFACL ACL];
                    [joinACL setPublicReadAccess:YES];
                    joinActivity.ACL = joinACL;
                    
                    [AMUtility followUserInBackground:newFriend block:^(BOOL succeeded, NSError *error) {
                    }];
                }];
            }
       
        }
        
        [[PFUser currentUser] saveInBackground];
        [hud setHidden:YES];

    } else
    {
        [self.hud setLabelText:@"Creating Profile"];
        NSString *facebookId = [result objectForKey:@"id"];
        NSString *facebookName = [result objectForKey:@"name"];
        NSString *urlString = [[[result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        [[NSUserDefaults standardUserDefaults]setObject:imageData forKey:kProfileImage_small];
        [[NSUserDefaults standardUserDefaults]synchronize];
        if (facebookName && facebookName != 0) {
            [[PFUser currentUser] setObject:facebookName forKey:@"displayName"];
            nameField.text = facebookName;
        }
        
        if (facebookId && facebookId != 0) {
            [[PFUser currentUser] setObject:facebookId forKey:@"facebookId"];
        }
        
        if(imageData){
            PFFile *imageFile = [PFFile fileWithData:imageData];
            if([imageFile save])
                [[PFUser currentUser]setObject:imageFile forKey:@"profileImage"];
            else
                NSLog(@"not saved");
        }
        [[PFUser currentUser]saveEventually];
        [profileTableview reloadData];
        
        FBRequest *request = [FBRequest requestForMyFriends];
//        [request setDelegate:self];
        [request startWithCompletionHandler:nil];
    }
}

- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    NSLog(@"Facebook error: %@", error);
    
    if ([PFUser currentUser]) {
        if ([[[[[[[error userInfo] objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectAtIndex:0] objectForKey:@"body"] objectForKey:@"error"] objectForKey:@"type"]
             isEqualToString: @"OAuthException"]) {
            NSLog(@"The facebook token was invalidated");
            [(AMAppDelegate *)[[UIApplication sharedApplication]delegate] logout];
        }
    }
}
-(void) setMaskforHighlightedBackground:(UIView*)view byRoundingCorners:(UIRectCorner)corners
{
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(7.0, 7.0)];
    
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    view.layer.mask = shape;
}

- (void)facebookRequestDidLoad:(id)result {
    // This method is called twice - once for the user's /me profile, and a second time when obtaining their friends. We will try and handle both scenarios in a single method.
    
    NSArray *data = [result objectForKey:@"data"];
    if (data) {
        if (![[PFUser currentUser] objectForKey:@"userAlreadyAutoFollowedFacebookFriends"])
        {
            NSMutableArray *facebookIds = [[NSMutableArray alloc] initWithCapacity:data.count];
            for (NSDictionary *friendData in data) {
                [facebookIds addObject:[friendData objectForKey:@"id"]];
            }
            [self.hud setLabelText:@"Following Friends"];
            
            
            [[PFUser currentUser] setObject:[NSNumber numberWithBool:YES] forKey:@"userAlreadyAutoFollowedFacebookFriends"];
            NSError *error = nil;
            
            // find common Facebook friends already using Anypic
            PFQuery *facebookFriendsQuery = [PFUser query];
            [facebookFriendsQuery whereKey:@"facebookId" containedIn:facebookIds];
            
            NSArray *anypicFriends = [facebookFriendsQuery findObjects:&error];
            
            if (!error) {
                [anypicFriends enumerateObjectsUsingBlock:^(PFUser *newFriend, NSUInteger idx, BOOL *stop) {
                    PFObject *joinActivity = [PFObject objectWithClassName:@"Activity"];
                    [joinActivity setObject:[PFUser currentUser] forKey:@"fromUser"];
                    [joinActivity setObject:newFriend forKey:@"toUser"];
                    [joinActivity setObject:@"joined" forKey:@"type"];
                    
                    PFACL *joinACL = [PFACL ACL];
                    [joinACL setPublicReadAccess:YES];
                    joinActivity.ACL = joinACL;
                    
                    [AMUtility followUserInBackground:newFriend block:^(BOOL succeeded, NSError *error) {
                    }];
                }];
            }
            
        }
        
        [[PFUser currentUser] saveInBackground];
        [hud setHidden:YES];
    }
    else {
        [self.hud setLabelText:@"Creating Profile"];
        NSString *facebookId = [result objectForKey:@"id"];
        
        NSString *facebookName = [result objectForKey:@"name"];
        NSString *urlString = [[[result objectForKey:@"picture"] objectForKey:@"data"] objectForKey:@"url"];
        NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]];
        if(imageData)
        {
            [[NSUserDefaults standardUserDefaults]setObject:imageData forKey:kProfileImage_small];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        if (facebookName && facebookName != 0) {
            [[PFUser currentUser] setObject:facebookName forKey:@"displayName"];
            nameField.text = facebookName;
        }
        
        if(imageData){
            PFFile *imageFile = [PFFile fileWithData:imageData];
            if([imageFile save])
                [[PFUser currentUser]setObject:imageFile forKey:@"profileImage"];
            else
                NSLog(@"not saved");
        }
        
        
        if (facebookId && facebookId != 0) {
            [[PFUser currentUser] setObject:facebookId forKey:@"facebookId"];
        }
        [[PFUser currentUser]saveEventually];
        [profileTableview reloadData];
        
        [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            if (!error) {
                [self facebookRequestDidLoad:result];
            } else {
                [self facebookRequestDidFailWithError:error];
            }
        }];
    }
}

- (void)facebookRequestDidFailWithError:(NSError *)error {
    NSLog(@"Facebook error: %@", error);
    
    if ([PFUser currentUser]) {
        if ([[error userInfo][@"error"][@"type"] isEqualToString:@"OAuthException"]) {
            NSLog(@"The Facebook token was invalidated. Logging out.");
            AMAppDelegate *appDelegate = (AMAppDelegate *) [UIApplication sharedApplication].delegate;
            [appDelegate logout];
        }
    }
}


@end
