//
//  AMRequestViewController.m
//  Automoose
//
//  Created by LAVANYA  on 08/02/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import "AMRequestViewController.h"
#import "AMAppDelegate.h"
#import "AMRequestTableCell.h"
#import "AMConstants.h"
#import "AMEventObject.h"
@interface AMRequestViewController ()

@end

@implementation AMRequestViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Invitations";
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.clearsSelectionOnViewWillAppear = NO;
    dataArray = [[NSMutableArray alloc]init];
    NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:kEventsList];
    NSArray  *eventsArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    for (int i=0;i<eventsArray.count; i++) {
        AMEventObject *evntObj = [eventsArray objectAtIndex:i];

        if([evntObj.attendanceType isEqualToString:@"Waiting"]&&[evntObj.isParticipant isEqualToString:@"YES"])
        {
                [dataArray addObject:evntObj];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)valueChanged:(UISegmentedControl *)sender
{
    AMEventObject *eventObject = [dataArray objectAtIndex:sender.tag];
    self.title = @"Updating...";
    NSString *selectedStatus ;
    switch (sender.selectedSegmentIndex) {
        case 0:
            selectedStatus= kGoing;
            eventObject.attendanceType = kGoing;
            break;
        case 1:
            selectedStatus = kMaybe;
            eventObject.attendanceType = kMaybe;
            break;
        case 2:
            selectedStatus = kNotGoing;
            eventObject.attendanceType = kNotGoing;
            break;
        default:
            break;
    }
    PFQuery *query = [PFQuery queryWithClassName:kEventActivity];
    [query whereKey:kFromUser equalTo:[[PFUser currentUser] objectId]];
    [query whereKey:kEventId equalTo:eventObject.eventId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array,NSError *error)
     {
         if(!error)
         {
             PFObject *object  = [array objectAtIndex:0];
             [object setObject:selectedStatus forKey:kAttendanceType];
             [object saveInBackgroundWithBlock:^(BOOL done,NSError *error)
              {
//                   self.title = @"Invitations";
                  if(done)
                  {
                      [dataArray removeObjectAtIndex:sender.tag];
                      [self.tableView reloadData];
                      self.title = @"Invitations";
                      NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                      [userDefaults setObject:[NSNumber numberWithInt:dataArray.count] forKey:kBadgeNumber];
                      [userDefaults synchronize];
                      [(AMAppDelegate *)[[UIApplication sharedApplication]delegate] setInvitationBadgeNumber];
                      NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:kEventsList];
                      NSMutableArray *eventsArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                      int indexofObjectToBeReplaced = 0;
                      for (int i=0;i < eventsArray.count ; i++) {
                          AMEventObject *evntObject = [eventsArray objectAtIndex:i];
                          if([evntObject.eventId isEqualToString:eventObject.eventId])
                          {
                              indexofObjectToBeReplaced = i;
                              break;
                          }
                      }
                      
                      [eventsArray replaceObjectAtIndex:indexofObjectToBeReplaced withObject:eventObject];
                      NSData *data2 = [NSKeyedArchiver archivedDataWithRootObject:eventsArray];
                      [[NSUserDefaults standardUserDefaults]setObject:data2 forKey:kEventsList];
                      [[NSUserDefaults standardUserDefaults]synchronize];
                      [[NSNotificationCenter defaultCenter]postNotificationName:kReloadtableData object:nil];
                  }
                  else
                  {
                      NSLog(@"Save failed: %@",error.localizedDescription);
                       self.title = @"Invitations";
                  }
              }];
         }
         else
             NSLog(@"%@",error.localizedDescription);
     }];

}
#pragma mark - Table view data source

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return dataArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    AMRequestTableCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    //    AMEventCustomCell *cell = [[AMEventCustomCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    if (cell == nil) {
        cell = (AMRequestTableCell *) [[AMRequestTableCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    AMEventObject *evntObject = [dataArray objectAtIndex:indexPath.row];
    cell.invitorName.text = evntObject.displayName;
    cell.staticLabel.text = @"invited you to ";
    cell.eventName.text = evntObject.nameoftheEvent;
    cell.eventName.numberOfLines = 0;
    cell.profileImage.image = evntObject.profileImage;
    cell.segmentedControl.tag = indexPath.row;
    [cell.segmentedControl addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(void)fetchPendingEventListandUpdate
{
    
}
//[(AMAppDelegate *)[[UIApplication sharedApplication]delegate] presentTabBarController];

@end
