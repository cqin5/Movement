//
//  AMEventsViewController.m
//  Automoose
//
//  Created by Lavanya on 03/03/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import "AMEventsViewController.h"
#import "AMEventCustomCell.h"
#import "AMEventObject.h"
#import "AMConstants.h"

@interface AMEventsViewController ()

@end

@implementation AMEventsViewController
@synthesize userEvents;
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return userEvents.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    AMEventCustomCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[AMEventCustomCell alloc]initWithFrame:CGRectZero];
    }
    
    AMEventObject *eventObject = [[AMEventObject alloc]init];
    
    eventObject = [userEvents objectAtIndex:indexPath.row];
    cell.photoView.backgroundColor = [UIColor colorWithPatternImage:eventObject.profileImage];
    cell.displayNameLabel.text = eventObject.displayName;
    cell.actionLabel.text = eventObject.activityType2;
    cell.locationLabel.text = [eventObject.placeofEvent objectForKey:kNameofthePlace];
    cell.nameoftheEventLabel.text = eventObject.nameoftheEvent;
    NSDate *todayDate = [NSDate date];
    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMM-DD-YY HH:mm"];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit
                                               fromDate:[dateFormatter dateFromString:eventObject.createdDate]
                                                 toDate:todayDate
                                                options:0];
    cell.timeLabel.text = [NSString stringWithFormat:@"%ih",components.hour];
    
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
    /*
    AMEventViewerController *eventViewerViewController = [[AMEventViewerController alloc]init];
    eventViewerViewController.eventObject = [userEvents objectAtIndex:indexPath.row];
    eventViewerViewController.indexofEvent = indexPath.row;
    [self.navigationController pushViewController:eventViewerViewController animated:YES];
     */
}

@end
