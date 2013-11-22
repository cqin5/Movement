//
//  AMCreateEventController.m
//  Automoose
//
//  Created by Srinivas on 12/4/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import "AMCreateEventController.h"
#import <QuartzCore/QuartzCore.h>
#import "AMUtility.h"
#import "AMFriendsViewController.h"
#import "AMPlacePickerViewController.h"
#import "MBProgressHUD.h"
#import "AMEventObject.h"
#import "AMConstants.h"
#import "AMEvent.h"
#import "AMTimelineEntity.h"
#import <QuartzCore/QuartzCore.h>
#import "TPKeyboardAvoidingTableView.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import "UIImage+ResizeAdditions.h"
#import "PECropViewController.h"
#import "AMEventImageViewer.h"
@interface AMCreateEventController ()
{
    MBProgressHUD *hud;
//    NSArray  *eventsArray;
    NSString *finalNotesString;
    BOOL isUserDataLoaded;
}
@end

@implementation AMCreateEventController

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

    self.title = @"Quick Create";
    

    [table setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    notesHeight = 35;
   
    typeSelector = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"Public",@"Invite-only", nil]];
    [typeSelector setFrame:CGRectMake(19, 10, 280, 30)];
    [typeSelector setSegmentedControlStyle:UISegmentedControlStylePlain];
    [typeSelector addTarget:self action:@selector(valueofSegmentControlChanged:) forControlEvents:UIControlEventValueChanged];

    [typeSelector setTintColor:[UIColor whiteColor]];


    UIImage *unselectedBackgroundImage = [[UIImage imageNamed:@"unselectedBg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [typeSelector setBackgroundImage:unselectedBackgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    UIImage *selectedBackgroundImage = [[UIImage imageNamed:@"selectedBg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [typeSelector setBackgroundImage:selectedBackgroundImage forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
    UIColor *buttonColor = [UIColor blackColor];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                buttonColor,UITextAttributeTextColor,
                                [UIFont fontWithName:@"HelveticaNeue-Light" size:13],UITextAttributeFont,
                                nil];
    
    [typeSelector setTitleTextAttributes:attributes forState:UIControlStateNormal];
    
    UIImage *divider1 = [[UIImage imageNamed:@"right_selected_divider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [typeSelector setDividerImage:divider1 forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    
     UIImage *divider2 = [[UIImage imageNamed:@"left_selected_divider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
    [typeSelector setDividerImage:divider2 forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    nameofTheEvent = [self getTextfield];
    invitees = [self getTextfield];
    places = [self getTextfield];
    startingTime = [self getTextfield];
    endingTime = [self getTextfield];
    specificsField = [self getTextfield];
    
    goDetailedButton = [self getButton];
    [goDetailedButton setFrame:CGRectMake(19, 8, 280, 33)];
    [goDetailedButton setTitle:@"More Details" forState:UIControlStateNormal];
    [goDetailedButton addTarget:self action:@selector(goDetailedTapped:) forControlEvents:UIControlEventTouchUpInside];
    
    addPoster = [self getButton];
    [addPoster setFrame:CGRectMake(19, 8, 280, 33)];
    [addPoster setTitle:@"Add Poster" forState:UIControlStateNormal];
    [addPoster addTarget:self action:@selector(addPosterAction) forControlEvents:UIControlEventTouchUpInside];
    
    viewPoster = [self getButton];
    [viewPoster setFrame:CGRectMake(19, 8, 280, 33)];
    [viewPoster setTitle:@"View Poster" forState:UIControlStateNormal];
    [viewPoster addTarget:self action:@selector(viewPosterAction) forControlEvents:UIControlEventTouchUpInside];
    
    removePoster = [self getButton];
    [removePoster setFrame:CGRectMake(19, 50, 135, 33)];
    [removePoster setTitle:@"Remove Poster" forState:UIControlStateNormal];
    [removePoster addTarget:self action:@selector(removePosterAction) forControlEvents:UIControlEventTouchUpInside];
    
    reselectPoster = [self getButton];
    [reselectPoster setFrame:CGRectMake(165, 50, 135, 33)];
    [reselectPoster setTitle:@"Reselect Poster" forState:UIControlStateNormal];
    [reselectPoster addTarget:self action:@selector(reselectPosterAction) forControlEvents:UIControlEventTouchUpInside];

    notes = [[UITextView alloc]initWithFrame:CGRectMake(19, 8, 280, 130)];
    [notes setDelegate:self];
    [notes setFont:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:15.0]];
    notes.keyboardType = UIKeyboardTypeDefault;
    notes.returnKeyType = UIReturnKeyDefault;

    [notes.layer setCornerRadius:10];
    notes.textColor = [AMUtility getColorwithRed:94 green:94 blue:94];
    notes.backgroundColor = [AMUtility getColorwithRed:236 green:236 blue:236];
    notes.text = @"Description";
    
    eventTypeSwitch = [[UISwitch alloc]initWithFrame:CGRectMake(200, 10, 80, 27)];
    
    UIButton *cancelButton = [AMUtility getButton];
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [cancelButton setFrame:CGRectMake(0, 0, 60, 30)];
    
    UIButton *doneButton = [AMUtility getButton];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [doneButton setFrame:CGRectMake(0, 0, 60, 30)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(doneButtonTapped)];

    [typeSelector setSelectedSegmentIndex:0];
    eventTypeString= @"Open";
    
    yearArray = [[NSMutableArray alloc]init];
    monthArray = [[NSMutableArray alloc]initWithObjects:@"Jan",@"Feb",@"Mar",@"Apr",@"May",@"Jun",@"Jul",@"Aug",@"Sep",@"Oct",@"Nov",@"Dec", nil];
    dateArray = [[NSMutableArray alloc]init];
    hourArray = [[NSMutableArray alloc]init];
    minutesArray = [[NSMutableArray alloc]init];
    
    int year = 2013;
    for(int i = 0; i < 20; i++)
    {
        [yearArray addObject:[NSNumber numberWithInt:year]];
         year++;
    }
    for (int i = 1 ; i<= 31; i++) {
        [dateArray addObject:[NSNumber numberWithInt:i]];
    }
    
    for (int i = 0; i<24; i++) {
        [hourArray addObject:[NSNumber numberWithInt:i]];
    }
    
    for (int i = 0; i < 60; i = i+5) {
        [minutesArray addObject:[NSNumber numberWithInt:i]];
    }
    
    customDatePicker = [[UIPickerView alloc]initWithFrame:CGRectMake(0,[UIScreen mainScreen].bounds.size.height - 280 , 320, 216)];
    customDatePicker.delegate = self;
    customDatePicker.dataSource = self;
    customDatePicker.showsSelectionIndicator = YES;
    
    datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0,[UIScreen mainScreen].bounds.size.height - 280 , 320, 216)];
    [datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    [datePicker setMinimumDate:[NSDate date]];

    datePickerToolbar = [[UIToolbar alloc]initWithFrame:CGRectMake(0, customDatePicker.frame.origin.y-40, 320, 40)];
    [datePickerToolbar setBackgroundImage:[UIImage imageNamed:@"titlebar.png"] forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    
    UIBarButtonItem *hideBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Hide" style:UIBarButtonItemStyleBordered target:self action:@selector(toolbarClearButtonTapped)];
    
    UIBarButtonItem *doneBarButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(toolbarDoneButtonTapped)];
    
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:selectedBackgroundImage action:nil];
    
    [datePickerToolbar setItems:[NSArray arrayWithObjects:hideBarButton,flexibleSpace,doneBarButton,nil]];
    
    [nameofTheEvent setPlaceholder:@"Name of the event"];
    [invitees setPlaceholder:@"Invitees"];
    [places setPlaceholder:@"Venue"];
    [startingTime setHidden:NO];
    [endingTime setHidden:YES];
    [notes setHidden:YES];
    [typeSelector setHidden:YES];
    [startingTime setPlaceholder:@"Date & Time"];
    [endingTime setPlaceholder:@"Ending time"];
    [specificsField setPlaceholder:@"Specifics: room, reservation"];

    startingTime.inputView = customDatePicker;
    startingTime.inputAccessoryView= datePickerToolbar;
    
    endingTime.inputView = customDatePicker;
    endingTime.inputAccessoryView= datePickerToolbar;
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if ([self.parentViewController.presentingViewController.modalViewController isEqual:self.parentViewController]) {
        [self.navigationItem setHidesBackButton:YES];
         self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonTapped)];
    }
    else
    {
      [self.navigationItem setHidesBackButton:NO];
    }
}
-(void)viewWillDisappear:(BOOL)animated
{
    [[table superview]endEditing:YES];
    [super viewWillDisappear:animated];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    table.frame = CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height);;
}



//Fill the screen with details provided in the argument to edit the event.
-(void)updateDetailstoEditforEvent:(PFObject *)event
{
    eventToUpdate = event;
    if([event objectForKey:kPosterImage])
    {
        isPosterSelected = YES;
        PFFile *posterFile = [event objectForKey:kPosterImage];
        updatedPosterFile = posterFile;
        [posterFile getDataInBackgroundWithBlock:^(NSData *data,NSError *err){
            if(!err)
                posterImageData = data;
        }];
    }
    else
        isPosterSelected = NO;
    
    locationIconFile = [[event objectForKey:kPlaceDetails] objectForKey:kImage];
    
//    self.navigationItem.leftBarButtonItem = nil;
//    [self.navigationItem setHidesBackButton:NO];
    
    [self goDetailedTapped:goDetailedButton];
    self.title = @"Event";
    specificsField.text = [event objectForKey:kSpecifics];
    isEditingModeOpen = YES;
    nameofTheEvent.text = [event objectForKey:kNameofEvent];
    places.text = [[event objectForKey:kPlaceDetails] objectForKey:kName];
    startingTime.text = [event objectForKey:kStartingTime];
    endingTime.text = [event objectForKey:kEndingTime];
    notes.text = [event objectForKey:kNotes];
    NSString *text = notes.text;
    CGSize maxSize = CGSizeMake(280, 999); 
    CGSize newSize = [text sizeWithFont:[UIFont fontWithName:@"Helvetica" size:15.0f] constrainedToSize:maxSize lineBreakMode:UIViewAutoresizingFlexibleHeight];
    
    notesHeight = newSize.height + 10;
    if(notesHeight < 44)
        notesHeight = 44;

    CGRect frame = notes.frame;
    frame.size.height = notesHeight;
    
    notes.frame = frame;
    
    [table reloadData];
    
    if([[event objectForKey:kTypeofEvent] isEqualToString:@"Open"])
       [typeSelector setSelectedSegmentIndex:0];
    else
        [typeSelector setSelectedSegmentIndex:1];
    
    NSMutableDictionary *placeDetails = [[NSMutableDictionary alloc]init];
    placeDetails = [event objectForKey:kPlaceDetails];
    selectedPlaceDetails  = [NSArray arrayWithObject:placeDetails];
    inviteesArray = [event objectForKey:kInvitees];
    
    finalInviteesArray = [[NSMutableArray alloc]initWithArray:inviteesArray];
    
    NSMutableString *inviteesLabelString = [[NSMutableString alloc]init];
    [inviteesLabelString appendString:[NSString stringWithFormat:@"%d people are invited",inviteesArray.count]];
    invitees.text = inviteesLabelString;
//    self.navigationItem.leftBarButtonItem = nil;
//    [self.navigationItem setHidesBackButton:NO];
}
-(void)touchDetectedonScrollview
{
    [nameofTheEvent resignFirstResponder];
    [places resignFirstResponder];
    [invitees resignFirstResponder];
    [notes resignFirstResponder];
    [datePickerToolbar setHidden:YES];
}
-(void)cancelButtonTapped
{
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}


//Do appropriate action(create or update event) when done is tapped
-(void)doneButtonTapped
{
    [self.view endEditing:YES];
    [notes resignFirstResponder];
    [nameofTheEvent resignFirstResponder];
    [datePickerToolbar setHidden:YES];
    [customDatePicker setHidden:YES];
    NSString *nameofTheEventString=@"" ;
    NSString *startingTimeString ;
    NSString *endingTimeString ;
    NSString *notesString=@"";
    NSString *specificsText=@"";
    
    if(!isDetailedModeOpen)
    {
        nameofTheEventString = [NSString stringWithFormat:@"Event at %@",places.text];
        startingTimeString = startingTime.text;
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
        NSDate *date = [dateFormatter dateFromString:startingTime.text];
        NSDate *finalDate = [date dateByAddingTimeInterval:3600];
        endingTimeString = [dateFormatter stringFromDate:finalDate];
        notesString = @"";
    }
    else
    {
        nameofTheEventString = nameofTheEvent.text;
        startingTimeString = startingTime.text;
        endingTimeString = endingTime.text;
        if([notes.text isEqualToString:@"Description"])
            notesString = @"";
        else
            notesString = notes.text;
        if(specificsField.text.length)
            specificsText = specificsField.text;
        else
            specificsText = @"";
    }
    
    finalNotesString = notesString?notesString:@"";;
    if( nameofTheEventString.length!= 0 && startingTimeString.length !=0 && endingTimeString.length != 0 && inviteesArray.count)
    {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
        [hud setDimBackground:YES];
        if(!isEditingModeOpen)
        {
            [hud setLabelText:@"Creating Event"];
            if(isPosterSelected)
            {
                NSArray *data = [NSArray arrayWithObjects:nameofTheEventString,startingTimeString,endingTimeString,finalNotesString,specificsText,updatedPosterFile ,nil];
                [self performSelectorInBackground:@selector(createEvent:) withObject:data];
            }
            else{
                NSArray *data = [NSArray arrayWithObjects:nameofTheEventString,startingTimeString,endingTimeString,finalNotesString,specificsField.text?specificsField.text:@"",nil];
                [self performSelectorInBackground:@selector(createEvent:) withObject:data];
            }
        }
        else
        {
            [hud setLabelText:@"Updating Event"];
            [self performSelectorInBackground:@selector(updateEvent) withObject:nil];
        }
//        NSLog(@"%@",updatedPosterFile.url);
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"Alert!" message:@"Please fill all the fields to create an event" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertView show];
    }
}


//Create event after done button is tapped
-(void)createEvent:(NSArray *)data
{
    
    NSString *nameofTheEventString = [data objectAtIndex:0];
    NSString *startingTimeString = [data objectAtIndex:1];
    NSString *endingTimeString = [data objectAtIndex:2];
    NSString *notesString = [data objectAtIndex:3];
    
    NSDate *todaysDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:todaysDate];

    
//    NSMutableArray *finalInviteesArray = [[NSMutableArray alloc]init];
//    for(int i=0;i<inviteesArray.count;i++) {
//        NSDictionary *dict = [inviteesArray objectAtIndex:i];
//        PFUser *user = [PFQuery getUserObjectWithId:[dict objectForKey:kObjectId]];
//        [finalInviteesArray addObject:user];
//    }
    if(!isUserDataLoaded)
        [self getUserData:^(BOOL succeeded){}];
    
    NSMutableDictionary *placeData = [NSMutableDictionary dictionaryWithDictionary:[selectedPlaceDetails objectAtIndex:0]];
//    UIImage *placeIcon_PNG = [placeData objectForKey:kImage];
//    PFFile *plaeIcon = [PFFile fileWithData:UIImagePNGRepresentation(placeIcon_PNG)];
//    [plaeIcon save];
    [placeData setObject:locationIconFile forKey:kImage];
    
    PFObject *eventObject = [PFObject objectWithClassName:kEventActivity];
    [eventObject setObject:nameofTheEventString forKey:kNameofEvent];
    [eventObject setObject:startingTimeString forKey:kStartingTime];
    [eventObject setObject:endingTimeString forKey:kEndingTime];
    [eventObject setObject:placeData forKey:kPlaceDetails];
    [eventObject setObject:eventTypeString forKey:kTypeofEvent];
    [eventObject setObject:notesString forKey:kNotes];
    [eventObject setObject:[PFUser currentUser] forKey:kFromUser];
    [eventObject setObject:@"going" forKey:kAttendanceType];
    [eventObject setObject:@"Created" forKey:kEventActivityType];
    [eventObject setObject:[PFUser currentUser] forKey:kToUser];
    [eventObject setObject:finalInviteesArray forKey:kInvitees];
    [eventObject setObject:kOwner forKey:kOwnership];
    [eventObject setObject:dateString forKey:kCreatedDate];
    [eventObject setObject:[nameofTheEventString lowercaseString] forKey:kLowerCaseEventName];
    if(isPosterSelected)
        [eventObject setObject:[data objectAtIndex:5] forKey:kPosterImage];
    [eventObject setObject:[data objectAtIndex:4] forKey:kSpecifics];

    [eventObject saveInBackgroundWithBlock:^(BOOL success,NSError *error){
        [eventObject setObject:[eventObject objectId] forKey:kParent];
        [eventObject saveInBackgroundWithBlock:^(BOOL success,NSError *error){
            [[NSNotificationCenter defaultCenter]postNotificationName:kReloadtableData object:nil];
            [hud hide:YES];
            [AMUtility postEventCreationToFacebook:eventObject];
            [self dismissViewControllerAnimated:YES completion:^{
                
        }];
            
            for(int i=0;i<finalInviteesArray.count;i++){
                PFObject *eventObject1 = [PFObject objectWithClassName:kEventActivity];
                [eventObject1 setObject:nameofTheEventString forKey:kNameofEvent];
                [eventObject1 setObject:startingTimeString forKey:kStartingTime];
                [eventObject1 setObject:endingTimeString forKey:kEndingTime];
                [eventObject1 setObject:placeData forKey:kPlaceDetails];
                [eventObject1 setObject:eventTypeString forKey:kTypeofEvent];
                [eventObject1 setObject:notesString forKey:kNotes];
                [eventObject1 setObject:[PFUser currentUser] forKey:kFromUser];
                [eventObject1 setObject:@"waiting" forKey:kAttendanceType];
                [eventObject1 setObject:@"Created" forKey:kEventActivityType];
                [eventObject1 setObject:[finalInviteesArray objectAtIndex:i] forKey:kToUser];
                [eventObject1 setObject:finalInviteesArray forKey:kInvitees];
                [eventObject1 setObject:kParticipant forKey:kOwnership];
                [eventObject1 setObject:dateString forKey:kCreatedDate];
                [eventObject1 setObject:[eventObject objectId] forKey:kParent];
                [eventObject1 setObject:[nameofTheEventString lowercaseString] forKey:kLowerCaseEventName];
                if(isPosterSelected)
                    [eventObject1 setObject:[data objectAtIndex:5] forKey:kPosterImage];
                [eventObject1 setObject:[data objectAtIndex:4] forKey:kSpecifics];
                
                [eventObject1 saveInBackgroundWithBlock:^(BOOL success,NSError *error){
                
                    NSString *alert = [NSString stringWithFormat:@"%@ invited you to an event!", [[PFUser currentUser] objectForKey:@"displayName"]];
                    if (alert.length > 100) {
                        alert = [alert substringToIndex:99];
                        alert = [alert stringByAppendingString:@"…"];
                    }
                        NSDictionary *notificationData = [NSDictionary dictionaryWithObjectsAndKeys:
                                                          alert,@"alert",
                                                          [eventObject objectId],kEventId,
                                                          dateString,kCreatedDate,
                                                          @"cheering.caf", @"sound",
                                                          nil];
                        
                        PFPush *push = [[PFPush alloc] init];
                        [push setChannel:[[eventObject1 objectForKey:kToUser] objectForKey:kChannel]];
                        [push setData:notificationData];
                        
                        [push setPushToIOS:YES];
                        [push setPushToAndroid:NO];
                        [push sendPushInBackgroundWithBlock:^(BOOL sucess,NSError *error){
                            if(!sucess)
                            {
                                NSLog(@"%@",error.localizedDescription);
                            }
                        }];
                }];
            }
        }];
    }];
        
}

//Update event after done button is tapped
-(void)updateEvent
{
    [notes resignFirstResponder];
    [nameofTheEvent resignFirstResponder];
    [datePickerToolbar setHidden:YES];
    [customDatePicker setHidden:YES];
    
    NSMutableDictionary *placeData = [NSMutableDictionary dictionaryWithDictionary:[selectedPlaceDetails objectAtIndex:0]];

    [placeData setObject:locationIconFile forKey:kImage];

    [eventToUpdate setObject:nameofTheEvent.text forKey:kNameofEvent];
    [eventToUpdate setObject:finalInviteesArray forKey:kInvitees];
    [eventToUpdate setObject:startingTime.text forKey:kStartingTime];
    [eventToUpdate setObject:endingTime.text forKey:kEndingTime];
    [eventToUpdate setObject:eventTypeString forKey:kTypeofEvent];
    [eventToUpdate setObject:notes.text forKey:kNotes];
    [eventToUpdate setObject:placeData forKey:kPlaceDetails];
    [eventToUpdate setObject:[nameofTheEvent.text lowercaseString] forKey:kLowerCaseEventName];
    [eventToUpdate setObject:specificsField.text forKey:kSpecifics];
    
    if(isPosterSelected)
    {
        [eventToUpdate setObject:updatedPosterFile forKey:kPosterImage];
    }
    else if([eventToUpdate objectForKey:kPosterImage])
    {
        [eventToUpdate removeObjectForKey:kPosterImage];
    }
    NSDate *todaysDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
    NSString *dateString = [dateFormatter stringFromDate:todaysDate];
    [eventToUpdate saveInBackgroundWithBlock:^(BOOL success, NSError *error)
     {
         PFQuery *query = [PFQuery queryWithClassName:kEventActivity];
         [query whereKey:kParent equalTo:[eventToUpdate objectForKey:kParent]];
         [query whereKey:kObjectId notEqualTo:[eventToUpdate objectId]];
        
         [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error){
             [objects enumerateObjectsUsingBlock:^(PFObject *object, NSUInteger index, BOOL *stop){
                 [object setObject:[eventToUpdate objectForKey:kNameofEvent] forKey:kNameofEvent];
                 [object setObject:[eventToUpdate objectForKey:kInvitees] forKey:kInvitees];
                 [object setObject:[eventToUpdate objectForKey:kStartingTime] forKey:kStartingTime];
                 [object setObject:[eventToUpdate objectForKey:kEndingTime ] forKey:kEndingTime];
                 [object setObject:[eventToUpdate objectForKey:kTypeofEvent] forKey:kTypeofEvent];
                 [object setObject:[eventToUpdate objectForKey:kNotes] forKey:kNotes];
                 [object setObject:[eventToUpdate objectForKey:kPlaceDetails] forKey:kPlaceDetails];
                 [object setObject:[eventToUpdate objectForKey:kLowerCaseEventName] forKey:kLowerCaseEventName];
                 [object setObject:[eventToUpdate objectForKey:kSpecifics] forKey:kSpecifics];
                 if(isPosterSelected)
                 {
                     [object setObject:[eventToUpdate objectForKey:kPosterImage] forKey:kPosterImage];
                 }
                 else if([eventToUpdate objectForKey:kPosterImage])
                 {
                     [eventToUpdate removeObjectForKey:kPosterImage];
                 }
                 [object saveInBackground];
             }];
         }];
     }];
    
    PFObject *newActivity = [[PFObject alloc]initWithClassName:kEventActivity];
    [newActivity setObject:[eventToUpdate objectForKey:kNameofEvent] forKey:kNameofEvent];
    [newActivity setObject:[eventToUpdate objectForKey:kInvitees] forKey:kInvitees];
    [newActivity setObject:[eventToUpdate objectForKey:kStartingTime] forKey:kStartingTime];
    [newActivity setObject:[eventToUpdate objectForKey:kEndingTime ] forKey:kEndingTime];
    [newActivity setObject:[eventToUpdate objectForKey:kTypeofEvent] forKey:kTypeofEvent];
    [newActivity setObject:[eventToUpdate objectForKey:kNotes] forKey:kNotes];
    [newActivity setObject:[eventToUpdate objectForKey:kPlaceDetails] forKey:kPlaceDetails];
    if(isPosterSelected)
        [newActivity setObject:[eventToUpdate objectForKey:kPosterImage] forKey:kPosterImage];
    [newActivity setObject:[eventToUpdate objectForKey:kSpecifics] forKey:kSpecifics];
    [newActivity setObject:[eventToUpdate objectForKey:kParent] forKey:kParent];
    
    [newActivity setObject:kGoing forKey:kAttendanceType];
    [newActivity setObject:[PFUser currentUser] forKey:kFromUser];
    [newActivity setObject:@"Updated" forKey:kEventActivityType];
    [newActivity setObject:[PFUser currentUser] forKey:kToUser];
    [newActivity setObject:kOwner forKey:kOwnership];
    [newActivity setObject:dateString forKey:kCreatedDate];
    [newActivity saveInBackgroundWithBlock:^(BOOL success, NSError *error){
        [[NSNotificationCenter defaultCenter]postNotificationName:kReloadtableData object:nil];
        [hud setHidden:YES];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }];
}

-(void)saveUpdatedEvent{
   
}

#pragma mark button actions
-(IBAction)goDetailedTapped  :(UIButton *)sender
{
    self.title = @"Create Event";
    [self removeDatePicker];

    isDetailedModeOpen = YES;
    goDetailedButton.hidden = YES;

    [startingTime setHidden:NO];
    [endingTime setHidden:NO];
    [typeSelector setHidden:NO];
    [notes setHidden:NO];

  
    if(eventToUpdate)
        self.navigationItem.hidesBackButton = NO;
    else
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(goQuickCreateTapped)];
    [table reloadData];
}

-(void)goQuickCreateTapped{
    self.title = @"Quick Create";
    isDetailedModeOpen = NO;
    goDetailedButton.hidden = NO;
    [startingTime setHidden:NO];
    [endingTime setHidden:YES];
    [typeSelector setHidden:YES];
    [notes setHidden:YES];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(cancelButtonTapped)];
    [table reloadData];
}
-(void)addPosterAction{
    hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    [hud setDimBackground:YES];
    hud.labelText = @"Loading";
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //    UIImagePickerControllerSourceTypePhotoLibrary
    [picker setMediaTypes:[NSArray arrayWithObjects:(NSString *) kUTTypeImage, nil]];
//    picker.allowsEditing = YES;
	[self presentModalViewController:picker animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *image = [[UIImage alloc]init];
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {
        
        image = (UIImage *) [info objectForKey:
                             UIImagePickerControllerOriginalImage];
        [self dismissViewControllerAnimated:YES completion:^{
            PECropViewController *controller = [[PECropViewController alloc] init];
            controller.delegate = self;
            controller.image = image;
            controller.typeOfController = @"EventCreation";
            
//            isPosterSelected = YES;
//            posterImageData = UIImagePNGRepresentation(image);
//            updatedPosterFile = [PFFile fileWithData:posterImageData];
//            [updatedPosterFile saveInBackgroundWithBlock:^(BOOL succeeded,NSError *err){}];
//            [table reloadData];
//            hud.hidden = YES;
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
            [self presentViewController:navigationController animated:NO completion:NULL];
        }];
    }
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissModalViewControllerAnimated:YES];
    hud.hidden = YES;
}
#pragma mark crop view controller delegate

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage
{
    [controller dismissViewControllerAnimated:YES completion:^(void){
        isPosterSelected = YES;
        UIImage *originalImage = croppedImage;
        CGSize destinationSize = CGSizeMake(320, 568);
        UIGraphicsBeginImageContext(destinationSize);
        [originalImage drawInRect:CGRectMake(0,0,destinationSize.width,destinationSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        isPosterSelected = YES;
        posterImageData = UIImagePNGRepresentation(newImage);
        updatedPosterFile = [PFFile fileWithData:posterImageData];
        [updatedPosterFile saveInBackgroundWithBlock:^(BOOL succeeded,NSError *err){}];
        [table reloadData];
        hud.hidden = YES;
    }];
    
}

- (void)cropViewControllerDidCancel:(PECropViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:NULL];
    hud.hidden = YES;
}

-(void)viewPosterAction{
    AMEventImageViewer *controller = [[AMEventImageViewer alloc]init];
    controller.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentModalViewController:controller animated:YES];
    UIImage *posterImage = [UIImage imageWithData:posterImageData];
    [controller loadImage:[UIImage imageWithData:posterImageData]];
//    NSLog(@"%f %f",posterImage.size.width,posterImage.size.height);

}
-(void)removePosterAction{
    posterImageData = nil;
    isPosterSelected = NO;
    [table reloadData];
}
-(void)reselectPosterAction{
    [self addPosterAction];
}
-(void)showDatePickerwithDateString:(NSString *)dateString
{
    
    if(!isDetailedModeOpen){
        [self.view addSubview:datePicker];
        [self.view addSubview:datePickerToolbar];
    }
    else
    {
        {
            if(selectedTimeField == startingTime && !startingTime.text.length) {
                NSDate *todaysDate = [NSDate date];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
                dateString = [dateFormatter stringFromDate:todaysDate];
            }
            else
                if(selectedTimeField == endingTime && !endingTime.text.length) {
                    NSDate *todaysDate = [NSDate date];
                    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
                    [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
                    dateString = [dateFormatter stringFromDate:todaysDate];
                }
        }
        int yearSubString = [[dateString substringWithRange:NSMakeRange(7, 4)]intValue];
        int yearIndex = [yearArray indexOfObject:[NSNumber numberWithInt:yearSubString]];
        [customDatePicker selectRow:yearIndex inComponent:0 animated:YES];
        
        NSString *monthSubString = [dateString substringWithRange:NSMakeRange(0, 3)];
        int monthIndex = [monthArray indexOfObject:[NSString stringWithFormat:@"%@",monthSubString]];
        [customDatePicker selectRow:monthIndex inComponent:1 animated:YES];
        
        int dateSubString = [[dateString substringWithRange:NSMakeRange(4, 2)]intValue];
        int dateIndex = [dateArray indexOfObject:[NSNumber numberWithInt:dateSubString]];
        [customDatePicker selectRow:dateIndex inComponent:2 animated:YES];
        
        int hourSubString = [[dateString substringWithRange:NSMakeRange(12, 2)]intValue];
        int hourIndex = [hourArray indexOfObject:[NSNumber numberWithInt:hourSubString]];
        [customDatePicker selectRow:hourIndex inComponent:3 animated:YES];
        
        int minutesSubString = [[dateString substringWithRange:NSMakeRange(15, 2)]intValue];
        int minutes=     (minutesSubString/5)+1;
        int minutesIndex = [minutesArray indexOfObject:[NSNumber numberWithInt:minutes * 5]];
        if(minutes == 12)
            minutesIndex = 0;
        NSString *finalDateString ;
        NSString *finalHourString;
        NSString *finalMinutesString;
        if(dateSubString < 10)
            finalDateString = [NSString stringWithFormat:@"0%d",dateSubString];
        else
            finalDateString = [NSString stringWithFormat:@"%d",dateSubString];
        
        if(hourSubString < 10)
            finalHourString = [NSString stringWithFormat:@"0%d",hourSubString];
        else
            finalHourString = [NSString stringWithFormat:@"%d",hourSubString];
        
        if(minutesSubString < 10)
            finalMinutesString = [NSString stringWithFormat:@"0%d",minutesSubString];
        else
            finalMinutesString = [NSString stringWithFormat:@"%d",minutesSubString];
        
        
        [customDatePicker selectRow:minutesIndex inComponent:4 animated:YES];
        {
            if(selectedTimeField == startingTime)
                [startingTime setText:[NSString stringWithFormat:@"%@-%@-%d %@:%@",monthSubString,finalDateString,yearSubString,finalHourString,finalMinutesString]];
            else
                [endingTime setText:[NSString stringWithFormat:@"%@-%@-%d %@:%@",monthSubString,finalDateString,yearSubString,finalHourString,finalMinutesString]];
        }
        [self.view addSubview:customDatePicker];
        [self.view addSubview:datePickerToolbar];
    }
}
-(void)removeDatePicker
{
    [datePicker removeFromSuperview];
    [customDatePicker removeFromSuperview];
    [datePickerToolbar removeFromSuperview];
    if(!isDetailedModeOpen)
        [places resignFirstResponder];
    else
    {
        [startingTime resignFirstResponder];
        [endingTime resignFirstResponder];
    }
}
#pragma mark textfield delegate methods
-(void)textFieldDidEndEditing:(UITextField *)textField
{
   
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark text view delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if([notes.text isEqualToString:@"Description"])
        notes.text = @"";
}
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if([notes.text isEqualToString:@""])
        notes.text = @"Description";
}
 
#pragma mark standard date picker methods

-(void)datePickerValueChanged:(UIDatePicker *)datePicker1 {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
    startingTime.text = [dateFormatter stringFromDate:datePicker1.date];
}

#pragma mark pickerview delegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 64;
}
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title;
    switch (component) {
        case 0:
            title = [NSString stringWithFormat:@"%d",[[yearArray objectAtIndex:row]intValue]];
            break;
        case 1:
            title = [monthArray objectAtIndex:row];
            break;
        case 2:
            title =  [NSString stringWithFormat:@"%d",[[dateArray objectAtIndex:row]intValue]];
            break;
        case 3:
            title = [NSString stringWithFormat:@"%d",[[hourArray objectAtIndex:row]intValue]];
            break;
        case 4:
            title = [NSString stringWithFormat:@"%d",[[minutesArray objectAtIndex:row]intValue] ];
            break;
            
        default:
            break;
    }
    return title;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 5;
}
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    int numberofRows = 0;
    switch (component) {
        case 0:
            numberofRows = [yearArray count];
            break;
        case 1:
            numberofRows = [monthArray count];
            break;
        case 2:
            numberofRows = [dateArray count];
            break;
        case 3:
            numberofRows = [hourArray count];
            break;
        case 4:
            numberofRows = [minutesArray count];
            break;
        
        default:
            break;
    }
    return numberofRows;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *stringtobePlaced;
    NSRange range;
    NSMutableString *stringtobeModified = [[NSMutableString alloc]init];;
    switch (component) {
        case 0:
            stringtobePlaced = [[yearArray objectAtIndex:row]stringValue];
            range = NSMakeRange(7, 4);
            break;
        case 1:
            stringtobePlaced = [monthArray objectAtIndex:row];
            range = NSMakeRange(0, 3);
            break;
        case 2:
            stringtobePlaced = [[dateArray objectAtIndex:row]stringValue];
            if([stringtobePlaced intValue] < 10)
                stringtobePlaced  = [NSString stringWithFormat:@"0%@",stringtobePlaced];
            range = NSMakeRange(4, 2);
            break;
        case 3:
            stringtobePlaced = [[hourArray objectAtIndex:row]stringValue];
            if([stringtobePlaced intValue] < 10)
                stringtobePlaced  = [NSString stringWithFormat:@"0%@",stringtobePlaced];
            range = NSMakeRange(12, 2);
            break;
        case 4:
            stringtobePlaced = [[minutesArray objectAtIndex:row]stringValue];
            if([stringtobePlaced intValue] < 10)
                stringtobePlaced  = [NSString stringWithFormat:@"0%@",stringtobePlaced];
            range = NSMakeRange(15, 2);
            break;
        default:
            break;
    }
    if(!isDetailedModeOpen)
    {
        stringtobeModified = [places.text mutableCopy];
        [stringtobeModified replaceCharactersInRange:range withString:stringtobePlaced];
        places.text = stringtobeModified;
    }
    else
    {
        if(selectedTimeField == startingTime)
        {
            stringtobeModified = [startingTime.text mutableCopy];
            [stringtobeModified replaceCharactersInRange:range withString:stringtobePlaced];
            startingTime.text = stringtobeModified;
        }
        else
        {
            stringtobeModified = [endingTime.text mutableCopy];
            [stringtobeModified replaceCharactersInRange:range withString:stringtobePlaced];
            endingTime.text = stringtobeModified;
        }
    }
    stringtobeModified = nil;
}

#pragma mark datePicker toolbar methods
-(void)toolbarClearButtonTapped
{
    [self removeDatePicker];
}
-(void)toolbarDoneButtonTapped
{
    [self removeDatePicker];
}



#pragma mark segment control
-(IBAction)valueofSegmentControlChanged:(UISegmentedControl *)sender
{
    if(sender.selectedSegmentIndex)
        eventTypeString = @"Invite-Only";
    else
        eventTypeString = @"Open";
}


#pragma mark friend selection delegate method
-(void)friendSelectionDone:(NSArray *)selectedFriends
{
    inviteesArray = selectedFriends;
    
    [finalInviteesArray removeAllObjects];
    [self getUserData:^(BOOL succeeded){
        isUserDataLoaded = succeeded;
        NSLog(@"Done");
    }];

    NSMutableString *selectedInvitees = [[NSMutableString alloc]init];
    NSDictionary *object = [NSDictionary dictionaryWithDictionary:[selectedFriends objectAtIndex:0]];
    [selectedInvitees appendString:[NSString stringWithFormat:@"%@",[object objectForKey:kDisplayName]]];
    for(int i=1; i < selectedFriends.count; i++)
    {
        object = [selectedFriends objectAtIndex:i];
        if(selectedFriends.count < 2)
            [selectedInvitees appendString:[NSString stringWithFormat:@", %@",[object objectForKey:@"displayName"]]];
        else
        {
            if(i < 2)
                [selectedInvitees appendString:[NSString stringWithFormat:@", %@",[object objectForKey:@"displayName"]]];
            else
            {
                [selectedInvitees appendString:[NSString stringWithFormat:@" & %d other people",selectedFriends.count - 2]];
                break;
            }
        }
    }
    invitees.text = selectedInvitees;
}
-(void)getUserData:(void (^)(BOOL succeeded))completionBlock{
    
    if(!finalInviteesArray)
        finalInviteesArray = [[NSMutableArray alloc]init];
    [finalInviteesArray removeAllObjects];
    NSMutableArray *objectIdArray  = [[NSMutableArray alloc]init];
    for(int i=0;i<inviteesArray.count;i++){
        NSDictionary *dict = [inviteesArray objectAtIndex:i];
        [objectIdArray addObject:[dict objectForKey:kObjectId]];
    }
    PFQuery *query  = [PFUser query];
    [query whereKey:kObjectId containedIn:objectIdArray];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects,NSError *err){
        if(!err)
        {
            [finalInviteesArray addObjectsFromArray:objects];
            if(completionBlock)
                completionBlock(YES);
        }
        else
            if(completionBlock)
                completionBlock(NO);
    }];
}
#pragma mark place selection delegate method
-(void)placeSelectionDone:(NSArray *)selectedPlace
{
    NSDictionary *dictionary = [selectedPlace objectAtIndex:0];
    selectedPlaceDetails = selectedPlace;

    places.text = [dictionary objectForKey:@"Name"];
    UIImage *placeIcon_PNG = [dictionary objectForKey:kImage];
    locationIconFile = [PFFile fileWithData:UIImagePNGRepresentation(placeIcon_PNG)];
    [locationIconFile saveInBackgroundWithBlock:^(BOOL succeeded,NSError *err){}];
}


#pragma mark tableview methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
        if(isDetailedModeOpen && indexPath.row == 8)
        {
            return 150;
        }
    if(indexPath.row == 0 && isDetailedModeOpen && isPosterSelected)
        return 88;
    return 44;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(!isDetailedModeOpen)
        return 4;
    else
        return 9;
}
-(UITableViewCell *)tableView:(UITableView *)tableView1 cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
	UITableViewCell *cell = [tableView1 dequeueReusableCellWithIdentifier:CellIdentifier];
    UILabel *openEventLabel;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if(!openEventLabel)
        openEventLabel = [self getLabel];
    openEventLabel.text = @"Open Event";
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    for(UIView *view in [cell.contentView subviews])
    {
        [view removeFromSuperview];
    }
    if(!isDetailedModeOpen)
    {
    switch (indexPath.row) {
        case 0:
            [cell.contentView addSubview:invitees];
            break;
        case 1:
            [cell.contentView addSubview:places];
            break;
        case 2:
            [cell.contentView addSubview:startingTime];
            break;
        case 3:
            [cell.contentView addSubview:goDetailedButton];
            break;
        default:
            break;
    }
    }
    else
    {
        switch (indexPath.row) {
            case 0:
                if(isPosterSelected)
                {
                    [cell.contentView addSubview:viewPoster];
                    [cell.contentView addSubview:removePoster];
                    [cell.contentView addSubview:reselectPoster];
                }
                else
                {
                    [cell.contentView addSubview:addPoster];
                }
                break;
            case 1:
                [cell.contentView addSubview:nameofTheEvent];
                break;
            case 2:
                [cell.contentView addSubview:invitees];
                break;
            case 3:
                [cell.contentView addSubview:places];
                break;
            case 4:
                [cell.contentView addSubview:specificsField];
                break;
            case 5:
                [cell.contentView addSubview:startingTime];
                break;
            case 6:
                [cell.contentView addSubview:endingTime];
                break;
            case 7:

                [cell.contentView addSubview:typeSelector];
                break;
             case 8:
                [cell.contentView addSubview:notes];
                break;
            default:
                break;
        }
    }
        
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    tableView.frame = CGRectMake(0, 0, 320, [UIScreen mainScreen].bounds.size.height);;
    [notes resignFirstResponder];
    AMPlacePickerViewController *placePickerViewController;
    if(!isDetailedModeOpen)
    {
        switch (indexPath.row) {
            case 0:
                friendsViewController = [[AMFriendsViewController alloc]init];
                friendsViewController.delegate = self;
                [self.navigationController pushViewController:friendsViewController animated:YES];
                break;
            case 1:
                 placePickerViewController = [[AMPlacePickerViewController alloc]init];
                placePickerViewController.delegate = self;
                [self.navigationController pushViewController:placePickerViewController animated:YES];
                break;
            case 2:
                [self showDatePickerwithDateString:places.text];
                break;
            case 3:
                break;
            default:
                break;
        }
    }
    else
    {
        
        switch (indexPath.row) {
            case 1:
                [nameofTheEvent setUserInteractionEnabled:YES];
                [nameofTheEvent becomeFirstResponder];
                break;
            case 2:
                friendsViewController = [[AMFriendsViewController alloc]init];
                friendsViewController.delegate = self;
                [self.navigationController pushViewController:friendsViewController animated:YES];
                break;
            case 3:
                placePickerViewController = [[AMPlacePickerViewController alloc]init];
                placePickerViewController.delegate = self;
                [self.navigationController pushViewController:placePickerViewController animated:YES];

                break;
            case 4:
                [specificsField setUserInteractionEnabled:YES];
                [specificsField becomeFirstResponder];
                break;
            case 5:
                [nameofTheEvent resignFirstResponder];
                [notes resignFirstResponder];
                selectedTimeField = startingTime;
                [self showDatePickerwithDateString:startingTime.text];
                break;
            case 6:
                [nameofTheEvent resignFirstResponder];
                [notes resignFirstResponder];
                selectedTimeField = endingTime;
                [self showDatePickerwithDateString:endingTime.text];
                break;
            case 7:

                break;
            case 8:

                
                break;
            default:
                break;
        }
    }
}

-(UITextField *)getTextfield{
    UITextField *textfield = [[UITextField alloc]initWithFrame:CGRectMake(19, 12, 280, 30)];
    [textfield.layer setCornerRadius:5];
    [textfield.layer setBorderColor:[UIColor blackColor].CGColor];
    [textfield.layer setBorderWidth:0.0f];
    [textfield setBorderStyle:UITextBorderStyleNone];
    [textfield setTextAlignment:NSTextAlignmentLeft ];
    [textfield setDelegate:self];
    [textfield setFont:[UIFont fontWithName:@"HelveticaNeue-LightItalic" size:15.0]];
    textfield.keyboardType = UIKeyboardTypeDefault;
    textfield.returnKeyType = UIReturnKeyDone;
    textfield.clearsOnBeginEditing = NO;
    textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textfield.userInteractionEnabled = NO;
    textfield.textColor = [AMUtility getColorwithRed:94 green:94 blue:94];
    textfield.backgroundColor = [AMUtility getColorwithRed:236 green:236 blue:236];
    textfield.leftView = [AMUtility getLeftviewforview:nameofTheEvent];
    textfield.leftViewMode = UITextFieldViewModeAlways;
    return textfield;
}
-(UIButton *)getButton{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button.layer setBorderWidth:0.5];
    UIColor *buttonColor = [AMUtility getColorwithRed:154 green:154 blue:154];
    [button.layer setBorderColor:buttonColor.CGColor];
    [button setBackgroundColor:[AMUtility getColorwithRed:249 green:249 blue:249]];
    [button.layer setCornerRadius:10];
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

@end
