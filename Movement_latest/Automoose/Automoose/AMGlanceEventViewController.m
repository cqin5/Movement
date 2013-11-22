//
//  AMGlanceEventViewController.m
//  Automoose
//
//  Created by Srinivas on 12/5/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import "AMGlanceEventViewController.h"
#import "AMCreateEventController.h"
#import "AMUtility.h"
#import "AMEventCustomCell.h"
#import "MBProgressHUD.h"
#import "AMEventObject.h"
#import "AMConstants.h"
#import "AMEventViewerController.h"
@interface AMGlanceEventViewController ()
{
    MBProgressHUD *hud;
}
@end

@implementation AMGlanceEventViewController
@synthesize delegate,eventTableView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = NSLocalizedString(@"Glance", @"Glance");
        self.tabBarItem.image = [UIImage imageNamed:@"second"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Glance";
    [self.navigationItem setHidesBackButton:YES];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    addButton.frame = CGRectMake(0, 0, 40, 25);
    [addButton setTitle:@"Add" forState:UIControlStateNormal];
    [addButton addTarget:self action:@selector(addEventClicked:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *addButtonItem = [[UIBarButtonItem alloc]initWithCustomView:addButton];
    self.navigationItem.leftBarButtonItem = addButtonItem;
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    [hud setDimBackground:YES];
    [hud setLabelText:@"Fetching Events"];
    [self performSelectorInBackground:@selector(fetchEvents) withObject:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if([hud isHidden])
        [self performSelectorInBackground:@selector(fetchEvents) withObject:nil];

}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)fetchEvents
{
    AMUtility *utility = [[AMUtility alloc]init];
    eventsArray = [utility fetchEvents];
    [eventTableView reloadData];
    [hud setHidden:YES];
    
}
-(void)addEventClicked:(UIButton *)sender
{
//    if([delegate respondsToSelector:@selector(CreateEvent)])
//        [delegate CreateEvent];
    createEvent = [[AMCreateEventController alloc]init];
    [self.navigationController pushViewController:createEvent animated:YES];
}

#pragma mark table view methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Count:%d",eventsArray.count);
    
    return eventsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    AMEventCustomCell *cell = [tableView1 dequeueReusableCellWithIdentifier:CellIdentifier];
//    AMEventCustomCell *cell = [[AMEventCustomCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
    if (cell == nil) {
        cell = (AMEventCustomCell *) [[AMEventCustomCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier];
    }
    
    AMEventObject *eventObject = [[AMEventObject alloc]init];
    eventObject = [eventsArray objectAtIndex:indexPath.row];
    cell.displayNameLabel.text = eventObject.displayName;
    cell.actionLabel.text = eventObject.action;
    cell.locationLabel.text = [eventObject.placeofEvent objectForKey:kNameofthePlace];
    cell.nameoftheEventLabel.text = eventObject.nameoftheEvent;
    NSDate *todayDate = [NSDate date];
    NSDateFormatter *dateFormatter  = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMM-DD-YY HH:MM"];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit
                                               fromDate:[dateFormatter dateFromString:eventObject.createdDate]
                                                 toDate:todayDate
                                                options:0];
//    NSLog(@"Difference in date components: %i/%i/%i", components.day, components.month, components.year);
    cell.timeLabel.text = [NSString stringWithFormat:@"%ih",components.hour];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AMEventViewerController *eventViewerViewController = [[AMEventViewerController alloc]init];
    eventViewerViewController.eventObject = [eventsArray objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:eventViewerViewController animated:YES];
}
@end
