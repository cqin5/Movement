//
//  AMCreateEventController.h
//  Automoose
//
//  Created by Srinivas on 12/4/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TPKeyboardAvoidingTableView.h"
@class AMFriendsViewController;
@class AMEventObject;
@interface AMCreateEventController : UIViewController<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextViewDelegate,UITableViewDataSource,UITableViewDelegate>
{

    IBOutlet TPKeyboardAvoidingTableView *table;
    
    UITextField *invisibleTextfield;
    UITextField *nameofTheEvent;
    UITextField *places;
    UITextField *invitees;
    UITextField *startingTime;
    UITextField *endingTime;
    UITextField *specificsField;
    UITextView *notes;
    UISwitch *eventTypeSwitch;
    UIButton *viewPoster, *reselectPoster,*removePoster,*addPoster;
    BOOL isPosterSelected;
    
    UISegmentedControl *typeSelector;
    UIButton *goDetailedButton;
    UIPickerView *customDatePicker;
    UIToolbar *datePickerToolbar;
    
    UIDatePicker *datePicker;

    NSMutableArray *yearArray;
    NSMutableArray *monthArray;
    NSMutableArray *dateArray;
    NSMutableArray *hourArray;
    NSMutableArray *minutesArray;

    BOOL isDetailedModeOpen;
    
    CGFloat notesHeight;
    
    UITextField *selectedTimeField;
    AMFriendsViewController *friendsViewController;
    NSArray *inviteesArray;
    NSArray *selectedPlaceDetails;
    
    BOOL isEditingModeOpen;
    NSString *eventTobeUpdated;
    
    NSString *eventTypeString;
    NSInteger l_indexofEvent;
    
    PFObject *eventToUpdate;
    NSData *posterImageData;
    
    PFFile *updatedPosterFile;
    PFFile *locationIconFile;
    NSMutableArray *finalInviteesArray;
}
-(IBAction)goDetailedTapped  :(UIButton *)sender;
-(void)friendSelectionDone:(NSArray *)selectedFriends;
-(void)placeSelectionDone:(NSArray *)selectedPlace;
-(void)updateDetailstoEditforEvent:(PFObject *)event;

@end
