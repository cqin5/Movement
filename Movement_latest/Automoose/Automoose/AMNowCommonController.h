//
//  AMNowCommonController.h
//  Automoose
//
//  Created by Srinivas on 12/2/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AMMapViewController;

@interface AMNowCommonController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    AMMapViewController *mapViewController;
    IBOutlet UIView *eventNameView;
    IBOutlet UIView *participantCountView;
    IBOutlet UIButton *arrivedButton;
    IBOutlet UIButton *enrouteButton;
    IBOutlet UIButton *notesButton;
    IBOutlet UIButton *detailsButton;
    IBOutlet UIButton *timeButton;
    
    IBOutlet UILabel *arrivedCountLabel;
    IBOutlet UILabel *enrouteCoutLabel;
    IBOutlet UILabel *nameoftheEventLabel;
    IBOutlet UILabel *locationofEventLabel;
    UILabel *typeofEvent;
    UILabel *goingPeopleList;
    UILabel *addressLabel;
//    UILabel *startingTime;
//    UILabel *endingTime;
    
    UITextView *notes;
    
    UIButton *cancelButton;
    UITextView *notesView;
    UIView *overlayView;
    NSTimer *timer;
    UITableView *eventDetailsTable;
    
    UIView *topView;
    NSMutableArray *goingPeopleData, *mayBePeopleData;
}
//-(IBAction)arrivedButtonTapped:(id)sender;
//-(IBAction)enrouteButtonTapped:(id)sender;
//-(IBAction)notesButtonTapped:(id)sender;
//-(IBAction)detailsButtonTapped:(id)sender;
//-(IBAction)timeButtonTapped:(id)sender;
-(void)showMapView;
-(void)inviteeStatusFromEventLocation:(NSInteger )indexofUser withStatus:(NSString *)status;
-(void)LogoutTapped;

@end
