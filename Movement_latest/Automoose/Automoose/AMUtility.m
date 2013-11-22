//
//  AMUtility.m
//  Automoose
//
//  Created by Srinivas on 12/2/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import "AMUtility.h"
#import "AMConstants.h"
#import "AMEventObject.h"
#import "AMPlaceObject.h"
#import "AMProfileViewerCusotmObject.h"
#import "AMEvent.h"
#import "AMTimelineEntity.h"

#import "NSDataAdditions.h"
#import <QuartzCore/QuartzCore.h>

@implementation AMUtility

static AMUtility *amUtility = nil;

//@synthesize friendsArray;
//@synthesize eventsArray;
+(id) sharedInstance
{
    @synchronized(self) {
        if (!amUtility)
            amUtility = [[self alloc] init];
    }
    return amUtility;
}

+(void)initLocationManager
{
    if(!locationManager)
    {
        locationManager = [[CLLocationManager alloc] init];
        locationManager.delegate = self;
        locationManager.distanceFilter = kCLDistanceFilterNone;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [locationManager startUpdatingLocation];
    }
}

+(UIButton *)getButton{
    UIButton *button;
    button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(19, 8, 280, 33)];
    [button.layer setBorderWidth:0.5];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    UIColor *buttonColor = [self getColorwithRed:154 green:154 blue:154];
    [button.layer setBorderColor:buttonColor.CGColor];
    [button setBackgroundColor:[self getColorwithRed:249 green:249 blue:249]];
    [button.layer setCornerRadius:6];
    [button.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    return button;
}

+(UITextField *)getTextfield{
    UITextField *textfield = [[UITextField alloc]init];
    textfield.font = [UIFont fontWithName:@"HelveticaNeue-LightItalic" size:15];
    textfield.backgroundColor = [self getColorwithRed:154 green:154 blue:154];
    textfield.borderStyle = UITextBorderStyleNone;
    textfield.textAlignment = NSTextAlignmentLeft;
    textfield.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textfield.leftViewMode = UITextFieldViewModeAlways;
    textfield.textColor = [self getColorwithRed:94 green:94 blue:94];
    return textfield;
}
+(UILabel *)getLabelforTableHeader{
    UILabel *label = [[UILabel alloc]init];
    label.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:14];
    label.textColor = [self getColorwithRed:61 green:61 blue:61];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentLeft;
    return label;
}

+(UIView *)getLeftviewforview:(UIView *)targetView
{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 8, targetView.frame.size.height)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}
+ (BOOL)userHasValidFacebookData:(PFUser *)user {
    NSString *facebookId = [user objectForKey:kFacebookId];
    return (facebookId && facebookId.length > 0);
}
+ (void)saveCustomObject:(AMEventObject *)obj {
    NSData *myEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:obj];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:myEncodedObject forKey:kDefaultEvent];
    [defaults synchronize];
}

//+ (AMEventObject *)loadCustomObjectWithKey:(NSString *)key {
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSData *myEncodedObject = [defaults objectForKey:key];
//    AMEventObject *obj = (AMEventObject *)[NSKeyedUnarchiver unarchiveObjectWithData: myEncodedObject];
//    return obj;
//}

+(void)removeCustomObjectwithKey:(NSString *)key
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:key];
    [defaults synchronize];
}
+ (void)followUserInBackground_justFollow:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:@"Activity"];
    [followActivity setObject:[[PFUser currentUser]objectId] forKey:@"fromUser"];
    [followActivity setObject:[user objectId] forKey:@"toUser"];
    [followActivity setObject:@"follow" forKey:@"type"];
    
    [followActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completionBlock) {
            completionBlock(succeeded, error);
        }
    }];
}
+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock {
    if ([[user objectId] isEqualToString:[[PFUser currentUser] objectId]]) {
        return;
    }
    
    PFObject *followActivity = [PFObject objectWithClassName:@"Activity"];
    [followActivity setObject:[[PFUser currentUser]objectId] forKey:@"fromUser"];
    [followActivity setObject:[user objectId] forKey:@"toUser"];
    [followActivity setObject:@"follow" forKey:@"type"];

    [followActivity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (completionBlock) {
            completionBlock(succeeded, error);
        }
        
        PFObject *followActivity2 = [PFObject objectWithClassName:@"Activity"];
        [followActivity2 setObject:[user objectId] forKey:@"fromUser"];
        [followActivity2 setObject:[[PFUser currentUser]objectId] forKey:@"toUser"];
        [followActivity2 setObject:@"follow" forKey:@"type"];
        

        
        [followActivity2 saveInBackgroundWithBlock:^(BOOL succeeded,NSError *error){
            if(completionBlock){
                completionBlock(succeeded,error);
            }
        }
         ];
         
    }];
}
+(void)unfollowUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded,NSError *error))completionBlock {
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"fromUser" equalTo:[[PFUser currentUser]objectId]];
    [query whereKey:@"toUser" equalTo:[user objectId]];
    [query whereKey:@"type" equalTo:@"follow"];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject *object,NSError *error)
     {
         if(!error)
         {
             [object deleteInBackgroundWithBlock:^(BOOL success,NSError *error1) {
                if(completionBlock)
                {
                    completionBlock(success,error1);
                }
             }];
         }
         else
         {
             if(completionBlock)
             {
                 completionBlock(NO,error);
             }
         }
     }];
    /*
    [object setObject:[[PFUser currentUser]objectId] forKey:@"fromUser"];
    [object setObject:[user objectId] forKey:@"toUser"];
    [object setObject:@"follow" forKey:@"type"];
     */
//    [object deleteInBackgroundWithBlock:^(BOOL success,NSError *error) {
//        if(completionBlock)
//        {
//            completionBlock(success,error);
//        }
//    }];
}
+(NSArray *)fetchPeopleFromParseWithString:(NSString *)searchString
{
    PFQuery *query = [PFUser query];
    [query whereKey:kLowerCaseDisplayName containsString:searchString];
    [query whereKey:kObjectId notEqualTo:[[PFUser currentUser]objectId]];
    NSArray *objects = [query findObjects];
    return objects;
}

+(NSArray *)fetchEventsofFriendsWithString:(NSString *)searchString
{
    NSArray *friends = [NSArray arrayWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:kFollowing]];
    NSMutableArray *friendsObecjtId = [[NSMutableArray alloc]init];
    for (int i=0; i<friends.count; i++) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:[friends objectAtIndex:i]];
        [friendsObecjtId addObject:[dictionary objectForKey:kObjectId]];
    }
    
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query whereKey:kFromUser containedIn:friendsObecjtId];
    [query whereKey:kTypeofEvent equalTo:@"Open"];
    [query whereKey:kLowerCaseEventName containsString:searchString];
    NSArray *objects = [query findObjects];
    
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    for(int i=0;i<objects.count;i++)
    {
        PFObject *object = [objects objectAtIndex:i];
        AMEventObject *event = [[AMEventObject alloc]init] ;
        event.eventId = [object objectId];
        event.nameoftheEvent = [object objectForKey:kNameofEvent];
        event.invitees = [object objectForKey:kInvitees];
//        event.attendanceType = [object objectForKey:kAttendanceType];
        event.typeofEvent = [object objectForKey:kTypeofEvent];
        event.notes = [object objectForKey:kNotes];
        event.createdDate = [object objectForKey:kCreatedDate];
        event.ownerObjectId = [object objectForKey:kFromUser];
        event.startingTime = [object objectForKey:kStartingTime];
        event.endingTime = [object objectForKey:kEndingTime];
        NSData *iconData = [[object objectForKey:KPlace]objectForKey:kImage];
        UIImage *image = [UIImage imageWithData:iconData];
        event.eventImage = image;
        [returnArray addObject:event];
    }
    return returnArray;
 }
//+(void )fetchtimeLineofUserwithObjectId:(NSString *)objectId block:(void (^)(BOOL succeeded, NSError *error,NSArray *array1))completionBlock
//+(void)fetchFriends block:(void (^)(BOOL succeeded, NSError *error,NSArray *array1))completionBlock

+(void)fetchFollowing:(void (^)(NSError *error))completionBlock
{
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"fromUser" equalTo:[[PFUser currentUser]objectId]];
    [query whereKey:@"type" equalTo:@"follow"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array,NSError *error){
        if(!error && array.count)
        {
           
            NSMutableArray *friendsArray = [[NSMutableArray alloc]init];
            for(int i =0; i < array.count ; i++)
            {
                PFObject *object = [array objectAtIndex:i];
                PFQuery *query = [PFUser query];
                [query whereKey:kObjectId equalTo:[object objectForKey:kToUser]];
                
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *friend,NSError *error){
                    if(!error) {
                        PFFile *profileImage = [friend objectForKey:kProfileImage];
                        if(profileImage)
                        {
                            [profileImage getDataInBackgroundWithBlock:^(NSData *imgData,NSError *error){
                                NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[friend objectForKey:kDisplayName],kDisplayName,[friend objectForKey:kChannel],kChannel,[friend objectId],kObjectId,imgData,kProfileImage,[friend objectForKey:kFacebookId],kFacebookId, nil];
                                [friendsArray addObject:dictionary];
                                
                                [[NSUserDefaults standardUserDefaults]setObject:friendsArray forKey:kFollowing];
                                [[NSUserDefaults standardUserDefaults]synchronize];
                                [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:friendsArray.count] forKey:kFollowingCount];
                                [[NSUserDefaults standardUserDefaults]synchronize];
                                [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationUpdatePeopleCount object:nil];
                            }];
                        }
                        else{
                            
                            NSData *imageData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"person_icon" ofType:@"png"]];
                            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[friend objectForKey:kDisplayName],kDisplayName,[friend objectForKey:kChannel],kChannel,[friend objectId],kObjectId,imageData,kProfileImage,[friend objectForKey:kFacebookId],kFacebookId, nil];
                                [friendsArray addObject:dictionary];
                                
                            [[NSUserDefaults standardUserDefaults]setObject:friendsArray forKey:kFollowing];
                            [[NSUserDefaults standardUserDefaults]synchronize];
                            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:friendsArray.count] forKey:kFollowingCount];
                            [[NSUserDefaults standardUserDefaults]synchronize];
                            [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationUpdatePeopleCount object:nil];
                        }
                    }
                    else
                    {
                        if(completionBlock)
                            completionBlock(error);
                    }
                }];
            }
        }
        else
        {
            if(completionBlock)
                completionBlock(error);
        }
    }];
        [self fetchFollowers:^(NSError *error){
    }];
            
}

+(void)fetchFollowers:(void (^)(NSError *error))completionBlock
{
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"toUser" equalTo:[[PFUser currentUser]objectId]];
    [query whereKey:@"type" equalTo:@"follow"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *array,NSError *error){
        if(!error && array.count)
        {
            NSMutableArray *friendsArray = [[NSMutableArray alloc]init];
            for(int i =0; i < array.count ; i++)
            {
                PFObject *object = [array objectAtIndex:i];
                PFQuery *query = [PFUser query];
                [query whereKey:kObjectId equalTo:[object objectForKey:kFromUser]];
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *friend,NSError *error){
                    if(!error) {
                        PFFile *profileImage = [friend objectForKey:kProfileImage];
                        [profileImage getDataInBackgroundWithBlock:^(NSData *imgData,NSError *error){
                            NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:[friend objectForKey:kDisplayName],kDisplayName,[friend objectForKey:kChannel],kChannel,[friend objectId],kObjectId,imgData,kProfileImage,[friend objectForKey:kFacebookId],kFacebookId, nil];
                            [friendsArray addObject:dictionary];
                            
                            NSString *imageString =[imgData base64Encoding];
                            
//                            NSString *valuesString = [NSString stringWithFormat:@"'%@','%@','%@','%@','%@'",[dictionary objectForKey:kObjectId],[dictionary objectForKey:kDisplayName],[dictionary objectForKey:kChannel],[dictionary objectForKey:kFacebookId],imageString];
                            [[NSUserDefaults standardUserDefaults]setObject:friendsArray forKey:kFollowers];
                            [[NSUserDefaults standardUserDefaults]synchronize];
                            [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithInt:friendsArray.count] forKey:kFollowersCount];
                            [[NSUserDefaults standardUserDefaults]synchronize];
                            [[NSNotificationCenter defaultCenter]postNotificationName:kNotificationUpdatePeopleCount object:nil];
                        }];
                    }
                    else
                    {
                        if(completionBlock)
                        {
                            [self showAlertwithTitle:@"Error" andMessage:error.localizedDescription];
                            completionBlock(error);
                        }
                    }
                }];
            }
        }
        else
        {
            if(completionBlock)
                completionBlock(error);
        }
    }];
}

+(void)reloadEventsData:(void(^)(NSError *error))completionBlock {
    NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:kEventsList];
    NSArray *events =[NSArray arrayWithArray: [NSKeyedUnarchiver unarchiveObjectWithData:data]];
    NSArray *followers = [[NSUserDefaults standardUserDefaults]objectForKey:kFollowers];
    NSArray *following = [[NSUserDefaults standardUserDefaults]objectForKey:kFollowing];
    NSMutableDictionary *searchableFollwingDictionary = [[NSMutableDictionary alloc]init];
    [following enumerateObjectsUsingBlock:^(id obj,NSUInteger indx,BOOL *stop){
        NSDictionary *entry = (NSDictionary *)obj;
        [searchableFollwingDictionary setObject:[entry objectForKey:kProfileImage] forKey:[entry objectForKey:kObjectId]];
    }];
    [followers enumerateObjectsUsingBlock:^(id obj,NSUInteger indx,BOOL *stop){
        NSDictionary *entry = (NSDictionary *)obj;
        [searchableFollwingDictionary setObject:[entry objectForKey:kProfileImage] forKey:[entry objectForKey:kObjectId]];
    }];
    
    NSMutableArray *finalArray  = [NSMutableArray arrayWithArray:events];
    [events enumerateObjectsUsingBlock:^(id obj,NSUInteger indx,BOOL *stop){
        AMEventObject *eventObject = (AMEventObject *)obj;
        NSArray *allKeys = [searchableFollwingDictionary allKeys];
        if([allKeys containsObject:eventObject.ownerObjectId])
        {
            eventObject.profileImage =[UIImage imageWithData:[searchableFollwingDictionary objectForKey:eventObject.ownerObjectId]] ;
            [finalArray replaceObjectAtIndex:indx withObject:eventObject];
        }
        if([eventObject.ownerObjectId isEqualToString:[[PFUser currentUser] objectId]])
        {
            eventObject.profileImage = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults]objectForKey:kProfileImage_small]];
            [finalArray replaceObjectAtIndex:indx withObject:eventObject];
        }
        
    }];
    
    
    NSData *eventsData = [NSKeyedArchiver archivedDataWithRootObject:finalArray];
    [[NSUserDefaults standardUserDefaults]setObject:eventsData forKey:kEventsList];
    [[NSUserDefaults standardUserDefaults]synchronize];
    if(completionBlock)
    {
        completionBlock(NO);
    }
}
/*
+(AMProfileViewerCusotmObject *)fetchTimelineofUser:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error,AMProfileViewerCusotmObject *object))completionBlock
{
    
    
//    [self fetchtimeLineofUserwithObjectId:[user objectId] block:^(BOOL success,NSError *error,NSArray *array){
//        PFQuery *followerQuery = [PFQuery queryWithClassName:@"Activity"];
//        [followerQuery whereKey:kFromUser equalTo:[user objectId]];
//        [followerQuery countObjectsInBackgroundWithBlock:^(int followers,NSError *error){
//            
//            PFQuery *followingQuery = [PFQuery queryWithClassName:@"Activity"];
//            [followingQuery whereKey:kToUser equalTo:[user objectId]];
//            [followingQuery countObjectsInBackgroundWithBlock:^(int following,NSError *error){
//                AMProfileViewerCusotmObject *profileObject = [[AMProfileViewerCusotmObject alloc]init];
//                profileObject.objectId = [user objectId];
//                profileObject.followingCount = [NSString stringWithFormat:@"%d",following];
//                profileObject.follwersCount = [NSString stringWithFormat:@"%d",followers];
//                profileObject.eventsCount = [NSString stringWithFormat:@"%d",array.count];
//                profileObject.eventTimelineArray = [NSArray arrayWithArray:array];
//                profileObject.nameofProfile =  [user objectForKey:kDisplayName];
//                profileObject.facebookID = [user objectForKey:kFacebookId];
//                profileObject.profileImageData = [user objectForKey:kProfileImage];
//                if (completionBlock) {
//                    completionBlock(YES, error,profileObject);
//                }
//            }];
//        }];
//    }];
    
   
    PFFile *profImage = [user objectForKey:kProfileImage];
     [profImage getDataInBackgroundWithBlock:^(NSData *data, NSError *error){
          NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:[user objectId],kObjectId,[user objectForKey:kDisplayName],kDisplayName,[user objectForKey:kFacebookId],kFacebookId,data,kProfileImage,nil];
         [self fetchTimelineofUserwithData:dict block:^(BOOL success,NSError *error, AMProfileViewerCusotmObject *object){
             if(completionBlock)
                 completionBlock(success,error,object);
         }];

    }];
   
       
   /*
    NSArray *array;
//    =  [self fetchtimeLineofUserwithObjectId:[user objectId]]; //Modified
    
    PFQuery *followerQuery = [PFQuery queryWithClassName:@"Activity"];
    [followerQuery whereKey:kFromUser equalTo:[user objectId]];
    NSInteger followers = [followerQuery countObjects];
    
    PFQuery *followingQuery = [PFQuery queryWithClassName:@"Activity"];
    [followingQuery whereKey:kToUser equalTo:[user objectId]];
    NSInteger following = [followerQuery countObjects];
    profileObject.objectId = [user objectId];
    profileObject.followingCount = [NSString stringWithFormat:@"%d",following];
    profileObject.follwersCount = [NSString stringWithFormat:@"%d",followers];
    profileObject.eventsCount = [NSString stringWithFormat:@"%d",array.count];
    profileObject.eventTimelineArray = [NSArray arrayWithArray:array];
    profileObject.nameofProfile = [user objectForKey:kDisplayName];
    PFFile *profImage = [user objectForKey:kProfileImage];
    NSData *data = [profImage getData];
    profileObject.profileImageData = data;
    return profileObject;
    * /

}
*/

+(void)fetchTimelineofUserwithData:(NSDictionary *)data block:(void (^)(BOOL succeeded, NSError *error,AMProfileViewerCusotmObject *object))completionBlock
{
    
    AMProfileViewerCusotmObject *profileObject = [[AMProfileViewerCusotmObject alloc]init];
    

//    =  [self fetchtimeLineofUserwithObjectId:[data objectForKey:kObjectId]]; //Modified
    [self fetchtimeLineofUserwithObjectId:[data objectForKey:kObjectId] block:^(BOOL success,NSError *error,NSArray *array){
        PFQuery *followerQuery = [PFQuery queryWithClassName:@"Activity"];
        [followerQuery whereKey:kFromUser equalTo:[data objectForKey:kObjectId]];
        [followerQuery countObjectsInBackgroundWithBlock:^(int followers,NSError *error){
            
            PFQuery *followingQuery = [PFQuery queryWithClassName:@"Activity"];
            [followingQuery whereKey:kToUser equalTo:[data objectForKey:kObjectId]];
             [followingQuery countObjectsInBackgroundWithBlock:^(int following,NSError *error){
                 profileObject.objectId = [data objectForKey:kObjectId];
                 profileObject.followingCount = [NSString stringWithFormat:@"%d",following];
                 profileObject.follwersCount = [NSString stringWithFormat:@"%d",followers];
                 profileObject.eventsCount = [NSString stringWithFormat:@"%d",array.count];
                 profileObject.eventTimelineArray = [NSArray arrayWithArray:array];
                 profileObject.nameofProfile = [data objectForKey:kDisplayName];
                 profileObject.facebookID = [data objectForKey:kFacebookId];
                 profileObject.profileImageData = [data objectForKey:kProfileImage];;
                 if (completionBlock) {
                     completionBlock(YES, error,profileObject);
                 }
             }];
        }];
    }];
    }

/*
+(AMProfileViewerCusotmObject *)fetchTimelineofUserwithData:(NSDictionary *)data
{
    AMProfileViewerCusotmObject *profileObject = [[AMProfileViewerCusotmObject alloc]init];
    
    NSArray *array =  [self fetchtimeLineofUserwithObjectId:[data objectForKey:kObjectId]];
    
    PFQuery *followerQuery = [PFQuery queryWithClassName:@"Activity"];
    [followerQuery whereKey:kFromUser equalTo:[data objectForKey:kObjectId]];
    NSInteger followers = [followerQuery countObjects];
    
    PFQuery *followingQuery = [PFQuery queryWithClassName:@"Activity"];
    [followingQuery whereKey:kToUser equalTo:[data objectForKey:kObjectId]];
    NSInteger following = [followerQuery countObjects];
    profileObject.objectId = [data objectForKey:kObjectId];
    profileObject.followingCount = [NSString stringWithFormat:@"%d",following];
    profileObject.follwersCount = [NSString stringWithFormat:@"%d",followers];
    profileObject.eventsCount = [NSString stringWithFormat:@"%d",array.count];
    profileObject.eventTimelineArray = [NSArray arrayWithArray:array];
    profileObject.nameofProfile = [data objectForKey:kDisplayName];
//    PFFile *profImage = [user objectForKey:kProfileImage];
    profileObject.profileImageData = [data objectForKey:kProfileImage];;
    return profileObject;
}
 */
/*
+(void)fetchFriendsTimeline:(NSArray *)friendsData
{
    NSMutableArray *friendsTimeLine = [[NSMutableArray alloc]init];
    for(int i=0;i<friendsData.count;i++)
    {
      NSArray *array =  [self fetchtimeLineofUserwithObjectId:[friendsData objectAtIndex:i]];
        
        PFQuery *followerQuery = [PFQuery queryWithClassName:@"Activity"];
        [followerQuery whereKey:kFromUser equalTo:[friendsData objectAtIndex:i]];
        NSInteger followers = [followerQuery countObjects];
        
        PFQuery *followingQuery = [PFQuery queryWithClassName:@"Activity"];
        [followingQuery whereKey:kToUser equalTo:[friendsData objectAtIndex:i]];
        NSInteger following = [followerQuery countObjects];
     
        AMProfileViewerCusotmObject *profileObject = [[AMProfileViewerCusotmObject alloc]init];
        profileObject.objectId = [friendsData objectAtIndex:i];
        
        profileObject.followingCount = [NSString stringWithFormat:@"%d",following];
        profileObject.follwersCount = [NSString stringWithFormat:@"%d",followers];
        profileObject.eventsCount = [NSString stringWithFormat:@"%d",array.count];
        profileObject.eventTimelineArray = [NSArray arrayWithArray:array];
        
        NSArray *friends = [[NSUserDefaults standardUserDefaults]objectForKey:kFriends];
        if(!friends.count)
        {
            [self fetchFriends];
            friends = [[NSUserDefaults standardUserDefaults]objectForKey:kFriends];
        }
        for(int j=0;j<friends.count;j++)
        {
            NSDictionary *dictionary = [friends objectAtIndex:j];
            if([[dictionary objectForKey:kObjectId] isEqualToString:[friendsData objectAtIndex:i]])
            {
                profileObject.nameofProfile = [dictionary objectForKey:kDisplayName];
                profileObject.profileImageData = [dictionary objectForKey:kProfileImage];
                break;
            }
        }
        [friendsTimeLine addObject:profileObject];
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:friendsTimeLine];
    [[NSUserDefaults standardUserDefaults]setObject:data forKey:kFriendTimeLineList];
    [[NSUserDefaults standardUserDefaults]synchronize];
}
*/
+(void )fetchtimeLineofUserwithObjectId:(NSString *)objectId block:(void (^)(BOOL succeeded, NSError *error,NSArray *array1))completionBlock
{
    
//    NSMutableArray *eventsArray;
//    if(!eventsArray)
//        eventsArray = [[NSMutableArray alloc]init];
//    [eventsArray removeAllObjects];
   
    PFQuery *query = [PFQuery queryWithClassName:@"EventActivity"];
    [query whereKey:@"fromUser" equalTo:objectId];
    [query whereKey:@"EventActivityType" notEqualTo:@"ReceivedInviation"];
    [query orderByDescending:@"updatedAt"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array,NSError *error){
        NSMutableArray *eventsArray = [[NSMutableArray alloc]init];
            for(int i=0; i< array.count;i++)
             {
                 AMEventObject *eventObject = [[AMEventObject alloc]init];
                 PFObject *object_temp = [array objectAtIndex:i];
                 [object_temp fetchIfNeededInBackgroundWithBlock:^(PFObject *object,NSError *error){
                     PFQuery *query = [PFQuery queryWithClassName:@"Event"];
                     [query whereKey:@"objectId" equalTo:[object objectForKey:kEventId]];
                      [query getFirstObjectInBackgroundWithBlock:^(PFObject *event,NSError *error){
                          
                          eventObject.eventId = [object objectForKey:kEventId];
                          eventObject.nameoftheEvent = [event objectForKey:kNameofEvent];
                          eventObject.invitees = [event objectForKey:kInvitees];
                          eventObject.attendanceType = [object objectForKey:kAttendanceType];
                          eventObject.typeofEvent = [event objectForKey:kTypeofEvent];
                          eventObject.notes = [event objectForKey:kNotes];
                          eventObject.ownership = [object objectForKey:kOwnership];
                          eventObject.createdDate = [object objectForKey:kCreatedDate];
                          eventObject.ownerObjectId = [event objectForKey:@"fromUser"];
                          //                PFUser *l_user  = [object objectForKey:kOwner];
                          //                [l_user fetch];
                          if([[object objectForKey:kEventActivityType] isEqualToString:kCreated] || [[object objectForKey:kEventActivityType] isEqualToString:kReceivedInviation])
                          {
                              eventObject.displayName = [event objectForKey:kDisplayName];
                              eventObject.activityType2 = @"Created an event at";
                          }
                          else
                          {
                              eventObject.displayName = [event objectForKey:kDisplayName];
                              eventObject.activityType2 = @"Attended";
                          }
                          
                          eventObject.startingTime = [event objectForKey:kStartingTime];
                          eventObject.endingTime = [event objectForKey:kEndingTime];
                          
                          NSArray *friendsArray = [[NSUserDefaults standardUserDefaults]objectForKey:kFollowing];
                          if([eventObject.ownerObjectId isEqualToString:[[PFUser currentUser]objectId]]) {
                              eventObject.profileImage = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults]objectForKey:kProfileImage_small]];
                          }
                          else
                              for(int i=0;i<friendsArray.count;i++)
                              {
                                  NSDictionary *dictionary = [friendsArray objectAtIndex:i];
                                  if([[dictionary objectForKey:kObjectId] isEqualToString:eventObject.ownerObjectId])
                                  {
                                      eventObject.profileImage = [UIImage imageWithData:[dictionary objectForKey:kProfileImage]];
                                      break;
                                  }
                              }

                          
                          CLLocationCoordinate2D coordinate ;
                          coordinate.latitude = [[[[event objectForKey:KPlace]objectForKey:kLocation]objectForKey:kLatitude]floatValue];
                          coordinate.longitude = [[[[event objectForKey:KPlace]objectForKey:kLocation]objectForKey:kLongitude]floatValue];
                          NSData *iconData = [[event objectForKey:KPlace]objectForKey:kImage];
                          UIImage *iconImage  = [[UIImage alloc]initWithData:iconData];
                          
                          [eventObject.placeofEvent setObject:[NSNumber numberWithFloat:[[[[event objectForKey:KPlace]objectForKey:kLocation]objectForKey:kLatitude]floatValue]] forKey:kLatitude];
                          [eventObject.placeofEvent setObject:[NSNumber numberWithFloat:[[[[event objectForKey:KPlace]objectForKey:kLocation]objectForKey:kLongitude]floatValue]] forKey:kLongitude];
                          [eventObject.placeofEvent setObject:[[event objectForKey:KPlace]objectForKey:kName] forKey:kNameofthePlace];
                          [eventObject.placeofEvent setObject:[[[event objectForKey:KPlace]objectForKey:kLocation]objectForKey:KPlace] forKey:kAddress];
                          [eventObject.placeofEvent setObject:iconImage forKey:kPlaceIcon];
                          [eventsArray addObject:eventObject];
                    }];
                 }];
            }
        if(completionBlock){
            completionBlock(YES,error,eventsArray);
        }
        }];
}
/*
+(NSArray *)fetchRestaurantswithString:(NSString *)searchString
{
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude);
    NSLog(@"Location : %f %f",location.latitude,location.longitude);
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/textsearch/json?query=%@&sensor=true&location=%f,%f&radius=1000&types=%@&key=%@",searchString,location.latitude, location.longitude, @"food|cafe|hotel",kGOOGLE_API_KEY];
    NSURL *googleRequestURL=[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:data
                          
                          options:kNilOptions
                          error:&error];
    NSArray *places = [json objectForKey:@"results"];

    for (int i=0; i<[places count]; i++)
    {
        NSDictionary* place = [places objectAtIndex:i];
        NSDictionary *geo = [place objectForKey:@"geometry"];
        UIImage *iconofRestaurant = [UIImage imageNamed:@"place.png"];
        NSString *name=[place objectForKey:@"name"];
//        NSString *vicinity=[place objectForKey:@"vicinity"];
        NSDictionary *loc = [geo objectForKey:@"location"];
        CLLocationCoordinate2D placeCoord;
        placeCoord.latitude=[[loc objectForKey:@"lat"] doubleValue];
        placeCoord.longitude=[[loc objectForKey:@"lng"] doubleValue];
        
        NSString *iconUrl = [place objectForKey:@"icon"];
        NSString *placeId = [place objectForKey:@"reference"];
//        NSArray *photosArray = [place objectForKey:@"photos"];
        NSString *rating = [place objectForKey:kRating];
        NSString *address = [place objectForKey:@"formatted_address"];

        
        AMPlaceObject *placeObject = [[AMPlaceObject alloc]init];
        placeObject.nameofPlace = name;
        placeObject.placeIcon = iconofRestaurant;
        placeObject.latitude = placeCoord.latitude;
        placeObject.longitude = placeCoord.longitude;
        placeObject.placeId = placeId;
        placeObject.rating = rating;
        placeObject.iconUrl = iconUrl;
        placeObject.isImageDownloaded = 0;
        placeObject.address = address;
        [returnArray addObject:placeObject];
    }
    return returnArray;
}
 */

/*
+(AMPlaceObject *)fetchDetailsofPlacewithDetails:(AMPlaceObject *)placeObj
{
    AMPlaceObject *returnObj = placeObj;
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/details/json?reference=%@&sensor=true&key=%@",placeObj.placeId, kGOOGLE_API_KEY];
    NSURL *googleRequestURL=[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
    NSError* error;
    NSDictionary* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    NSDictionary *results = [json objectForKey:@"results"];
    NSArray *photosArray = [results objectForKey:@"photos"];
    NSMutableArray *photoIdArray = [[NSMutableArray alloc]init];
    for (int i=0; i<photosArray.count; i++) {
        NSDictionary *dict = [photosArray objectAtIndex:i];
        [photoIdArray addObject:[dict objectForKey:@"photo_reference"]];
    }
    if(photoIdArray.count)
        returnObj.photoIdArray = photoIdArray;
    returnObj.phoneNumber = [results objectForKey:@"formatted_phone_number"];
    NSArray *reviews = [results objectForKey:@"reviews"];
    NSMutableArray *reviewArray = [[NSMutableArray alloc]init];
    for(int i=0;i<reviews.count;i++)
    {
        NSDictionary *review = [reviews objectAtIndex:i];
        NSString *reviewText = [review objectForKey:@"text"];
        NSString *rating = [[review objectForKey:@"aspects"]objectForKey:@"rating"];
        NSDictionary *finalReviewDict = [NSDictionary dictionaryWithObjectsAndKeys:reviewText,@"review",rating,@"rating", nil];
        [reviewArray addObject:finalReviewDict];
    }
    returnObj.review = reviewArray;
    return returnObj;
}
 */
/*
+(NSArray *)fetchNearByRestaurants
{
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude);
    NSLog(@"Location : %f %f",location.latitude,location.longitude);
    NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%d&types=%@&sensor=false&key=%@", location.latitude, location.longitude, 10000, @"food|cafe|hotel",kGOOGLE_API_KEY];
    
    NSURL *googleRequestURL=[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
   
    
//    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
//        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    //        NSArray *groupsArray = [[(NSDictionary*)json objectForKey:@"response"] objectForKey:@"groups"];
    //
    //        NSArray *itemsArray;
    //        if([groupsArray count] > 0){
    //            itemsArray = [[groupsArray objectAtIndex:0] objectForKey:@"items"];
    //
    //            NSMutableArray *resultArray = [NSMutableArray array];
    //            if([itemsArray count] > 0){
    //                for (int i=0; i<[itemsArray count]; i++) {
    //
    //                    NSMutableDictionary *resultDictionary=[[NSMutableDictionary alloc] init];
    //
    //                    NSString *venueId = [[itemsArray objectAtIndex:i] objectForKey:@"id"];
    //                    NSString *venueName = [[itemsArray objectAtIndex:i] objectForKey:@"name"];
    //                    [resultDictionary setObject:venueId forKey:@"venueId"];
    //                    [resultDictionary setObject:venueName forKey:@"venueName"];
    //
    //                    //Get Stats details
    //                    NSDictionary *stats = [[itemsArray objectAtIndex:i] objectForKey:@"stats"];
    //                    NSString *checkinsCount = [stats objectForKey:@"checkinsCount"];
    //                    NSString *tipCount = [stats objectForKey:@"tipCount"];
    //                    NSString *usersCount = [stats objectForKey:@"usersCount"];
    //
    //                    [resultDictionary setObject:checkinsCount forKey:@"checkinsCount"];
    //                    [resultDictionary setObject:tipCount forKey:@"tipCount"];
    //                    [resultDictionary setObject:usersCount forKey:@"usersCount"];
    //
    //                    NSArray *catArray = [[itemsArray objectAtIndex:i] objectForKey:@"categories"];
    //
    //                    if([catArray count]> 0){
    //                        //Get Category List
    //                        NSDictionary *categoryDic = [catArray objectAtIndex:0];
    //                        NSLog(@"categoryDic ----- = %@",categoryDic);
    //
    //                        [resultDictionary setObject:[categoryDic objectForKey:@"icon"] forKey:@"icon"];
    //                        [resultDictionary setObject:[categoryDic objectForKey:@"id"] forKey:@"catId"];
    //                        [resultDictionary setObject:[categoryDic objectForKey:@"name"] forKey:@"catName"];
    //
    //                    }
    //                    //Add dictionary into Array
    //                    [resultArray addObject:resultDictionary];
    //                }
    //
    //
    //                //Use this resultArray for display the Search details
    //                for (int i=0; i<[resultArray count]; i++) {
    //                    NSString *venueName=[[resultArray objectAtIndex:i] objectForKey:@"venueName"];
    //                    NSString *checkins=[[resultArray objectAtIndex:i] objectForKey:@"checkinsCount"];
    //
    //                    NSLog(@"venueName = %@",venueName);
    //                    NSLog(@"checkins = %@",checkins);
    //                    
    //                }
    //            }
    //
    //        return [NSMutableArray array];
    //    }

    
        NSError* error;
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:data
                              
                              options:kNilOptions
                              error:&error];
       NSArray *places = [json objectForKey:@"results"];

    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    
    for (int i=0; i<[places count]; i++)
    {
        NSDictionary* place = [places objectAtIndex:i];
        NSDictionary *geo = [place objectForKey:@"geometry"];
        UIImage *iconofRestaurant = [UIImage imageNamed:@"place.png"];
        NSString *name=[place objectForKey:@"name"];
        NSString *vicinity=[place objectForKey:@"vicinity"];
        NSDictionary *loc = [geo objectForKey:@"location"];
        CLLocationCoordinate2D placeCoord;
        placeCoord.latitude=[[loc objectForKey:@"lat"] doubleValue];
        placeCoord.longitude=[[loc objectForKey:@"lng"] doubleValue];
        
        NSDictionary *locationDictionary = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithFloat:placeCoord.latitude],@"latitude",[NSNumber numberWithFloat:placeCoord.longitude],@"longitude",vicinity,@"Place", nil];
        
        NSString *iconUrl = [place objectForKey:@"icon"];
        NSMutableDictionary *returnDictionary = [[NSMutableDictionary alloc]init];
        [returnDictionary setObject:name forKey:@"Name"];
        [returnDictionary setObject:iconUrl forKey:@"iconUrl"];
        
        [returnDictionary setObject:iconofRestaurant forKey:@"Image"];
        [returnDictionary setObject:locationDictionary forKey:@"location"];
        [returnArray addObject:returnDictionary];
    }
    return returnArray;
}
 */
/*
+(BOOL)createEventWithdetailsbyUser:(AMEventObject *)eventObject
{
    NSError *error;
    [[PFUser currentUser] fetchIfNeeded:&error];
    if(error)
    {
        UIAlertView *alertiew = [[UIAlertView alloc]initWithTitle:@"Alert" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertiew show];
    }
    if([eventObject.typeofEventtoBeCarriedOut isEqualToString:kNewEventCreation])
    {
        PFObject *eventCreation = [PFObject objectWithClassName:@"Event"];
        [eventCreation setObject:[[PFUser currentUser]objectId] forKey:kFromUser];
        [eventCreation setObject:eventObject.nameoftheEvent forKey:@"NameofEvent"];
        [eventCreation setObject:eventObject.invitees forKey:@"Invitees"];
        [eventCreation setObject:eventObject.startingTime forKey:@"StartingTime"];
        [eventCreation setObject:eventObject.endingTime forKey:@"EndingTime"];
        [eventCreation setObject:eventObject.typeofEvent forKey:@"TypeofEvent"];
        [eventCreation setObject:eventObject.notes forKey:@"Notes"];
        [eventCreation setObject:eventObject.displayName forKey:kDisplayName];
        
        NSDate *todaysDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
        NSString *dateString = [dateFormatter stringFromDate:todaysDate];
        
        [eventCreation setObject:dateString forKey:kCreatedDate];
        UIImage *iconofPlace = [eventObject.placeofEvent objectForKey:@"Image"];
        NSData *imgData = UIImagePNGRepresentation(iconofPlace);
        PFFile *img = [PFFile fileWithData:imgData];
        [img save];
        NSMutableDictionary *placeDictionary = eventObject.placeofEvent;
        [placeDictionary removeObjectForKey:@"Image"];
        [placeDictionary setObject:imgData forKey:@"Image"];
        [eventCreation setObject:placeDictionary forKey:@"Place"];

        if([eventCreation save])
        {
            [[NSUserDefaults standardUserDefaults]setObject:[eventCreation objectId] forKey:kEventId];
            [[NSUserDefaults standardUserDefaults]setObject:dateString forKey:kCreatedDate];
            [[NSUserDefaults standardUserDefaults]synchronize];
            
            PFObject *eventActivity = [PFObject objectWithClassName:@"EventActivity"];
            [eventActivity setObject:[eventCreation objectId] forKey:@"EventId"];
            [eventActivity setObject:[[PFUser currentUser]objectId] forKey:@"fromUser"];
            [eventActivity setObject:@"Going" forKey:@"AttendanceType"];
            [eventActivity setObject:@"Owner" forKey:@"Ownership"];
            [eventActivity setObject:[PFUser currentUser] forKey:@"Owner"];
            [eventActivity setObject:@"Created" forKey:@"EventActivityType"];
            [eventActivity setObject:dateString forKey:@"CreatedDate"];

//            [eventActivity saveEventually];
            if([eventActivity save])
             {
                 NSLog(@"After");
                 for(int i=0; i < eventObject.invitees.count; i++)
                 {
                     PFObject *eventActivity_participants = [PFObject objectWithClassName:@"EventActivity"];
                     [eventActivity_participants setObject:[eventCreation objectId] forKey:kEventId];
                     [eventActivity_participants setObject:[[eventObject.invitees objectAtIndex:i] objectForKey:kObjectId] forKey:@"fromUser"];
                     [eventActivity_participants setObject:@"Waiting" forKey:kAttendanceType];
                     [eventActivity_participants setObject:@"Participant" forKey:kOwnership];
                     [eventActivity_participants setObject:@"ReceivedInviation" forKey:kEventActivityType];
                     [eventActivity_participants setObject:[PFUser currentUser] forKey:kOwner];
                     [eventActivity_participants setObject:dateString forKey:kCreatedDate];
                     [eventActivity_participants saveInBackground];
                 }
                
                 NSMutableSet *channelSet = [NSMutableSet setWithCapacity:eventObject.invitees.count];
                 for (int i=0; i < eventObject.invitees.count; i++) {
                     NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:[eventObject.invitees objectAtIndex:i]];
                     NSString *privateChannelName = [dictionary objectForKey:kChannel];
                     if (privateChannelName && privateChannelName.length != 0 && ![[dictionary objectForKey:kObjectId] isEqualToString:[[PFUser currentUser] objectId]]) {
                         [channelSet addObject:privateChannelName];
                     }
                 }
                 if (channelSet.count > 0) {
                     NSString *alert = [NSString stringWithFormat:@"%@ invited you to an event!", [[PFUser currentUser] objectForKey:@"displayName"]];
                     if (alert.length > 100) {
                         alert = [alert substringToIndex:99];
                         alert = [alert stringByAppendingString:@"…"];
                     }
                     
                     NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                                           alert,@"alert",
                                           [eventCreation objectId],kEventId,
                                           dateString,kCreatedDate,

                                           [[PFUser currentUser]objectId],kOwnerObjectId,
                                           @"cheering.caf", @"sound",
                                           nil];

                     
                     PFPush *push = [[PFPush alloc] init];
                     [push setChannels :[channelSet allObjects]];
                     [push setData:data];
                     
                     [push setPushToIOS:YES];
                     [push setPushToAndroid:NO];
                     [push sendPushInBackgroundWithBlock:^(BOOL sucess,NSError *error){
                         if(!sucess)
                         {
                             NSLog(@"%@",error.localizedDescription);
                         }
                     }];
                 }
             }
            return YES;
        }
        else
            return NO;
    }
    else
    {
        PFObject *event = [PFObject objectWithoutDataWithClassName:kEvent objectId:eventObject.eventId];
        [event setObject:eventObject.nameoftheEvent forKey:kNameofEvent];
        [event setObject:eventObject.invitees forKey:kInvitees];
        [event setObject:eventObject.startingTime forKey:kStartingTime];
        [event setObject:eventObject.endingTime forKey:kEndingTime];
        [event setObject:eventObject.typeofEvent forKey:kTypeofEvent];
        [event setObject:eventObject.notes forKey:kNotes];
        [event setObject:eventObject.displayName forKey:kDisplayName];
        NSDate *todaysDate = [NSDate date];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
        NSString *dateString = [dateFormatter stringFromDate:todaysDate];
//        [event setObject:dateString forKey:kCreatedDate];
        
        UIImage *iconofPlace = [eventObject.placeofEvent objectForKey:kImage];
        NSData *imgData = UIImagePNGRepresentation(iconofPlace);
        PFFile *img = [PFFile fileWithData:imgData];
        [img save];
        NSMutableDictionary *placeDictionary = eventObject.placeofEvent;
        [placeDictionary removeObjectForKey:kImage];
        [placeDictionary setObject:imgData forKey:kImage];
        [event setObject:placeDictionary forKey:KPlace];
        
       if( [event save])
       {
           PFQuery *query =[PFQuery queryWithClassName:@"EventActivity"];
           [query whereKey:kEventId equalTo:eventObject.eventId];
           [query findObjectsInBackgroundWithBlock:^(NSArray *objects,NSError *error) {
               for(int i=0; i<objects.count;i++) {
                   PFObject *obj  = [objects objectAtIndex:i];
                   [obj setObject:dateString forKey:kCreatedDate];
//                   [obj saveInBackground];
               }
               
//               PFObject *eventActivity = [PFObject objectWithClassName:@"EventActivity"];
//               [eventActivity setObject:[eventCreation objectId] forKey:@"EventId"];
//               [eventActivity setObject:[[PFUser currentUser]objectId] forKey:@"fromUser"];
//               [eventActivity setObject:@"Going" forKey:@"AttendanceType"];
//               [eventActivity setObject:@"Owner" forKey:@"Ownership"];
//               [eventActivity setObject:[PFUser currentUser] forKey:@"Owner"];
//               [eventActivity setObject:@"Created" forKey:@"EventActivityType"];
//               [eventActivity setObject:dateString forKey:@"CreatedDate"];
               
               PFObject *eventActivity_Update = [PFObject objectWithClassName:@"EventActivity"];
               [eventActivity_Update setObject:eventObject.eventId forKey:kEventId];
               [eventActivity_Update setObject:kUpdated forKey:kEventActivityType];
               [eventActivity_Update setObject:dateString forKey:kCreatedDate];
               [eventActivity_Update setObject:[[PFUser currentUser]objectId] forKey:kFromUser];
               [eventActivity_Update setObject:kGoing forKey:kAttendanceType];
               [eventActivity_Update setObject:kOwner forKey:kOwnership];
               [eventActivity_Update setObject:[PFUser currentUser] forKey:kOwner];
               [eventActivity_Update saveInBackground];
           }];
           [[NSUserDefaults standardUserDefaults]setObject:dateString forKey:kCreatedDate];
           [[NSUserDefaults standardUserDefaults]synchronize];
           return YES;
       }
    }
    return NO;
}
*/


/*
+(NSArray *)fetchEvents {
    
    NSMutableArray *returnArray ;
    NSArray *friendsArray = [[NSArray alloc]init];
    friendsArray = [[NSUserDefaults standardUserDefaults]objectForKey:kFollowing];
    NSMutableArray *friendsObjectId = [[NSMutableArray alloc]init];
    for (int i=0; i<friendsArray.count; i++) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:[friendsArray objectAtIndex:i]];
        [friendsObjectId addObject:[dictionary objectForKey:kObjectId]];
    }
    [friendsObjectId addObject:[[PFUser currentUser]objectId]];
    NSArray *statuses = [[NSArray alloc]initWithObjects:kCreated,kUpdated, nil];

    //Event Activity Fetching
    NSError *error;
    
    NSMutableArray *activityTimelineArray_temp  = [[NSMutableArray alloc]init];
    PFQuery *query = [PFQuery queryWithClassName:@"EventActivity"];
    [query whereKey:@"fromUser" containedIn:friendsObjectId];
    [query whereKey:kEventActivityType containedIn:statuses];
    [query orderByDescending:@"c"];

    NSString *lastSyndDateString = [[NSUserDefaults standardUserDefaults]objectForKey:kLastSyncdDate];
    if(lastSyndDateString)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
        NSDate *lastSyncdDate = [dateFormatter dateFromString:lastSyndDateString];
        
        [dateFormatter setDateFormat:@"MMM dd,yyyy,HH:mm"];
        lastSyndDateString = [dateFormatter stringFromDate:lastSyncdDate];
        lastSyncdDate = [dateFormatter dateFromString:lastSyndDateString];
        
        [query whereKey:@"updatedAt" greaterThan:lastSyncdDate];
    }
    NSArray *array  = [query findObjects:&error];
    
    NSData *timeLine = [[NSUserDefaults standardUserDefaults]objectForKey:kTimeline];
    NSMutableArray *activityTimelineArray = [NSKeyedUnarchiver unarchiveObjectWithData:timeLine];
    if(!activityTimelineArray)
        activityTimelineArray = [[NSMutableArray alloc]init];
    
    
    for(int i=0;i<array.count;i++) {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
        AMTimelineEntity *timeLineEntity = [[AMTimelineEntity alloc]init];
        PFObject *object = [array objectAtIndex:i];
        timeLineEntity.eventId = [object objectForKey:kEventId];
        timeLineEntity.activityCreatedDate = [object objectForKey:kCreatedDate];
        timeLineEntity.ownership = [object objectForKey:kOwnership];
        timeLineEntity.attendanceType = [object objectForKey:kAttendanceType];
        timeLineEntity.activityType2 = [object objectForKey:kEventActivityType];
        timeLineEntity.ownerObjectId = [[object objectForKey:kOwner]objectId];
        BOOL found = NO;
        for(int j=0;j<activityTimelineArray.count;j++){
            AMTimelineEntity *timeLineEntity_temp = [activityTimelineArray objectAtIndex:j];
            if([timeLineEntity_temp.eventId isEqualToString:timeLineEntity.eventId] && [timeLineEntity_temp.activityCreatedDate isEqualToString:timeLineEntity.activityCreatedDate])
            {
                found = YES;
                break;
            }
        }
        if(!found)
            [activityTimelineArray_temp addObject:timeLineEntity];
        
        NSDate *lastSyncdDate =[dateFormatter dateFromString: [[NSUserDefaults standardUserDefaults]objectForKey:kLastSyncdDate]];
        NSDate *eventActivityDate = [dateFormatter dateFromString:timeLineEntity.activityCreatedDate];
        if([eventActivityDate compare:lastSyncdDate] == NSOrderedDescending || !lastSyncdDate ){
            [[NSUserDefaults standardUserDefaults]setObject:timeLineEntity.activityCreatedDate forKey:kLastSyncdDate];
            [[NSUserDefaults standardUserDefaults]synchronize];
        }
        
    }

//    [[NSUserDefaults standardUserDefaults]setObject:lastFetchedDate forKey:kLastSyncdDate];
    
    //Event Data Fetching
    NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:kCoreEventData];
    NSMutableArray *eventsData = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSMutableArray *eventIdArray = [[NSMutableArray alloc]init];
    if(!eventsData)
        eventsData = [[NSMutableArray alloc]init];
    else{
        for(int i=0;i<eventsData.count;i++) {
            AMEvent *event_temp =[ eventsData objectAtIndex:i];
            [eventIdArray addObject:event_temp.eventId];
        }
    }
    for(int i=0;i<activityTimelineArray_temp.count;i++) {
        AMTimelineEntity *timeLineEntity = [activityTimelineArray_temp objectAtIndex:i];
        
        if([eventIdArray containsObject:timeLineEntity.eventId])
        {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
            int indexofEvent = [eventIdArray indexOfObject:timeLineEntity.eventId];
            AMEvent *event = [eventsData objectAtIndex:indexofEvent];
            NSDate *savedEventCreatedDate = [dateFormatter dateFromString:event.createdDate];
            NSDate *timelineEntityCreatedDate = [dateFormatter dateFromString:timeLineEntity.activityCreatedDate];
//            NSLog(@"e: %@ %@ %@ %@",event.nameoftheEvent,timeLineEntity.activityType2,savedEventCreatedDate,timelineEntityCreatedDate);
            if( [timelineEntityCreatedDate compare:savedEventCreatedDate] == NSOrderedDescending){
                AMEvent *event = [self fetchEventwitheventId:timeLineEntity.eventId];
                event.createdDate = timeLineEntity.activityCreatedDate;
                [eventsData replaceObjectAtIndex:indexofEvent withObject:event];
            }
        }
        else {
            AMEvent *event = [self fetchEventwitheventId:timeLineEntity.eventId];
            event.createdDate = timeLineEntity.activityCreatedDate;
            [eventsData addObject:event];
            [eventIdArray addObject:event.eventId];
        }
    }
    
    NSMutableArray *returnArray_temp = [[NSMutableArray alloc]init];
    
    //Preparing event object data
    for(int i=0;i<activityTimelineArray_temp.count;i++) {
        AMTimelineEntity *timeLineEntity = [activityTimelineArray_temp objectAtIndex:i];
        AMEventObject *eventObject = [[AMEventObject alloc]init];
        eventObject.eventId = timeLineEntity.eventId;
        
        if([timeLineEntity.activityType2 isEqualToString:kCreated] )
            eventObject.activityType2 = @"Created an event at";
        else if([timeLineEntity.activityType2 isEqualToString:kUpdated])
            eventObject.activityType2 = @"Updated an event at";
        else if([timeLineEntity.activityType2 isEqualToString:@"Attended"])
            eventObject.activityType2 = @"Attended an event at";
        
        eventObject.ownerObjectId = timeLineEntity.ownerObjectId;
        eventObject.ownership = timeLineEntity.ownership;
        eventObject.createdDate = timeLineEntity.activityCreatedDate;
        for(int j=0;j<eventsData.count;j++){
            AMEvent *event = [eventsData objectAtIndex:j];
            if([event.eventId isEqualToString:timeLineEntity.eventId]){
                eventObject.nameoftheEvent = event.nameoftheEvent;
                eventObject.startingTime = event.startingTime;
                eventObject.endingTime = event.endingTime;
                eventObject.invitees = event.invitees;
                eventObject.placeofEvent = event.placeofEvent;
                eventObject.typeofEvent = event.typeofEvent;
                eventObject.notes = event.notes;
                eventObject.modifiedDate = event.modifiedDate;
                eventObject.eventImage = event.eventImage;
                eventObject.displayName = event.displayName;
                eventObject.isParticipant = @"NO";
                NSArray *friendsArray = [[NSUserDefaults standardUserDefaults]objectForKey:kFollowing];
                if([eventObject.ownerObjectId isEqualToString:[[PFUser currentUser]objectId]]) {
                    eventObject.profileImage = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults]objectForKey:kProfileImage_small]];
                }
                else
                    for(int i=0;i<friendsArray.count;i++)
                    {
                        NSDictionary *dictionary = [friendsArray objectAtIndex:i];
                        if([[dictionary objectForKey:kObjectId] isEqualToString:eventObject.ownerObjectId])
                        {
                            eventObject.profileImage = [UIImage imageWithData:[dictionary objectForKey:kProfileImage]];
                            break;
                        }
                    }
                
                NSMutableArray *temp_inviteesArray = [[NSMutableArray alloc]init];
                for(int i=0;i<eventObject.invitees.count;i++) {
                    NSDictionary *dict = [eventObject.invitees objectAtIndex:i];
                    [temp_inviteesArray addObject:[dict objectForKey:kObjectId]];
                }
                if([eventObject.ownerObjectId isEqualToString:[[PFUser currentUser]objectId]])
                    [temp_inviteesArray addObject:[[PFUser currentUser]objectId]];
                for(int i=0;i<temp_inviteesArray.count;i++)
                {
                    if([[temp_inviteesArray objectAtIndex:i] isEqualToString:[[PFUser currentUser]objectId]]){
                        eventObject.isParticipant = @"YES";
                        break;
                    }
                }
                
                if(eventObject.isParticipant) {
                    if([eventObject.ownerObjectId isEqualToString:[[PFUser currentUser]objectId]])
                        eventObject.attendanceType = timeLineEntity.attendanceType;
                    else {
                        PFQuery *attendanceQuery = [PFQuery queryWithClassName:@"EventActivity"];
                        [attendanceQuery whereKey:kEventId equalTo:eventObject.eventId];
                        [attendanceQuery whereKey:kFromUser equalTo:[[PFUser currentUser]objectId]];
                        PFObject *object = [attendanceQuery getFirstObject];
                        eventObject.attendanceType = [object objectForKey:kAttendanceType];
                        timeLineEntity.attendanceType = [object objectForKey:kAttendanceType];
                    }
                }
                else{
                    eventObject.attendanceType = @"NA";
                    timeLineEntity.attendanceType = @"NA";
                }
                [activityTimelineArray_temp replaceObjectAtIndex:i withObject:timeLineEntity];
                break;
            }
        }
        [returnArray_temp addObject:eventObject];
    }
    
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc]init];
    for(int i=0;i<activityTimelineArray_temp.count;i++){
        [indexSet addIndex:i];
    }
    [activityTimelineArray insertObjects:activityTimelineArray_temp atIndexes:indexSet];
    
    
    NSData *eventsList = [[NSUserDefaults standardUserDefaults]objectForKey:kEventsList];
    returnArray = [NSKeyedUnarchiver unarchiveObjectWithData:eventsList];
    
    if(!returnArray)
        returnArray = [[NSMutableArray alloc]init];
    
    for(int i=0;i<returnArray_temp.count;i++){
        [indexSet addIndex:i];
    }
    
    [returnArray insertObjects:returnArray_temp atIndexes:indexSet];
    
    for (int i=0; i<returnArray.count; i++) {
        for(int j=0;j<returnArray.count - i - 1;j++){
            AMEventObject *evntObj1 = [returnArray objectAtIndex:j];
            AMEventObject *evntObj2 = [returnArray objectAtIndex:j+1];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
            
            NSDate *date1 = [dateFormatter dateFromString:evntObj1.createdDate];
            NSDate *date2 = [dateFormatter dateFromString:evntObj2.createdDate];
            
            if([date1 compare:date2] == NSOrderedAscending) {
                [returnArray replaceObjectAtIndex:j withObject:evntObj2];
                [returnArray replaceObjectAtIndex:j+1 withObject:evntObj1];
            }
        }
    }
    eventsList = [NSKeyedArchiver archivedDataWithRootObject:returnArray];
    timeLine = [NSKeyedArchiver archivedDataWithRootObject:activityTimelineArray];
    NSData *events = [NSKeyedArchiver archivedDataWithRootObject:eventsData];
    [[NSUserDefaults standardUserDefaults]setObject:eventsList forKey:kEventsList];
    [[NSUserDefaults standardUserDefaults]setObject:timeLine forKey:kTimeline];
    [[NSUserDefaults standardUserDefaults]setObject:events forKey:kCoreEventData];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self reloadEventsData:^(NSError *error) {}];
    return returnArray;
}
 */
/*
+(AMEvent *)fetchEventwitheventId:(NSString *)eventId {
    
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query whereKey:@"objectId" equalTo:eventId];
    NSError *error2;
    PFObject *object = [query getFirstObject:&error2];
    
    AMEvent *event = [[AMEvent alloc]init];
    event.eventId = [object objectId];
    event.nameoftheEvent = [object objectForKey:kNameofEvent];
    event.invitees = [object objectForKey:kInvitees];
    event.typeofEvent = [object objectForKey:kTypeofEvent];
    event.notes = [object objectForKey:kNotes];
    event.startingTime = [object objectForKey:kStartingTime];
    event.endingTime = [object objectForKey:kEndingTime];
    event.displayName = [object objectForKey:kDisplayName];
    
    //Place details
    CLLocationCoordinate2D coordinate ;
    coordinate.latitude = [[[[object objectForKey:KPlace]objectForKey:kLocation]objectForKey:kLatitude]floatValue];
    coordinate.longitude = [[[[object objectForKey:KPlace]objectForKey:kLocation]objectForKey:kLongitude]floatValue];
    NSData *iconData = [[object objectForKey:KPlace]objectForKey:kImage];
    UIImage *iconImage  = [[UIImage alloc]initWithData:iconData];
    event.eventImage = iconImage;
    [event.placeofEvent setObject:[NSNumber numberWithFloat:[[[[object objectForKey:KPlace]objectForKey:kLocation]objectForKey:kLatitude]floatValue]] forKey:kLatitude];
    [event.placeofEvent setObject:[NSNumber numberWithFloat:[[[[object objectForKey:KPlace]objectForKey:kLocation]objectForKey:kLongitude]floatValue]] forKey:kLongitude];
    [event.placeofEvent setObject:[[object objectForKey:KPlace]objectForKey:kName] forKey:kNameofthePlace];
    [event.placeofEvent setObject:[[[object objectForKey:KPlace]objectForKey:kLocation]objectForKey:KPlace] forKey:kAddress];
    [event.placeofEvent setObject:iconImage forKey:kPlaceIcon];
    event.eventImage = iconImage;
    return event;
}
*/
/*
+(AMEventObject *)fetchFirstEventtoMakeitDefaultEvent
{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:kFriendTimeLineList];
    [[NSUserDefaults standardUserDefaults]synchronize];
        NSError *error;
        PFObject *object;
        PFQuery *query = [PFQuery queryWithClassName:@"EventActivity"];
        [query whereKey:@"fromUser" equalTo:[[PFUser currentUser]objectId]];
        [query orderByDescending:@"updatedAt"];

        object = [query getFirstObject:&error];
        AMEventObject *eventObject = [[AMEventObject alloc]init];
        if(error)
        {
            return nil;
        }

            [object fetchIfNeeded:&error];
            if(error)
            {
                UIAlertView *alertiew = [[UIAlertView alloc]initWithTitle:@"Alert" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alertiew show];
            }
            
            PFQuery *query2 = [PFQuery queryWithClassName:@"Event"];
            [query2 whereKey:@"objectId" equalTo:[object objectForKey:kEventId]];
            NSError *error2;
            
            PFObject *event = [query2 getFirstObject:&error2];
            if(event)
            {
                eventObject.eventId = [object objectForKey:kEventId];
                eventObject.nameoftheEvent = [event objectForKey:kNameofEvent];
                eventObject.invitees = [event objectForKey:kInvitees];
                eventObject.attendanceType = [object objectForKey:kAttendanceType];
                eventObject.typeofEvent = [event objectForKey:kTypeofEvent];
                eventObject.notes = [event objectForKey:kNotes];
                eventObject.ownership = [object objectForKey:kOwnership];
                eventObject.createdDate = [object objectForKey:kCreatedDate];
                eventObject.ownerObjectId = [event objectForKey:kFromUser];

                if([[object objectForKey:kEventActivityType] isEqualToString:kCreated] || [[object objectForKey:kEventActivityType] isEqualToString:kReceivedInviation])
                {
                    eventObject.displayName = [event objectForKey:kDisplayName];
                    eventObject.activityType2 = @"Created an event at";
                }
                else
                {
                    eventObject.displayName = [event objectForKey:kDisplayName];
                    eventObject.activityType2 = @"Attended";
                }
                
                eventObject.startingTime = [event objectForKey:kStartingTime];
                eventObject.endingTime = [event objectForKey:kEndingTime];
                
                CLLocationCoordinate2D coordinate ;
                coordinate.latitude = [[[[event objectForKey:KPlace]objectForKey:kLocation]objectForKey:kLatitude]floatValue];
                coordinate.longitude = [[[[event objectForKey:KPlace]objectForKey:kLocation]objectForKey:kLongitude]floatValue];
                NSData *iconData = [[event objectForKey:KPlace]objectForKey:kImage];
                UIImage *iconImage  = [[UIImage alloc]initWithData:iconData];
                [eventObject.placeofEvent setObject:[NSNumber numberWithFloat:[[[[event objectForKey:KPlace]objectForKey:kLocation]objectForKey:kLatitude]floatValue]] forKey:kLatitude];
                [eventObject.placeofEvent setObject:[NSNumber numberWithFloat:[[[[event objectForKey:KPlace]objectForKey:kLocation]objectForKey:kLongitude]floatValue]] forKey:kLongitude];
                [eventObject.placeofEvent setObject:[[event objectForKey:KPlace]objectForKey:kName] forKey:kNameofthePlace];
                [eventObject.placeofEvent setObject:[[[event objectForKey:KPlace]objectForKey:kLocation]objectForKey:KPlace] forKey:kAddress];
                [eventObject.placeofEvent setObject:iconImage forKey:kPlaceIcon];
                eventObject.eventImage = iconImage;
            }
    return eventObject;
}
 */

//+(AMEventObject *)fetchEventwithId:(NSString *)eventId
//{
//    NSError *error;
//    PFObject *object;
//    PFQuery *query = [PFQuery queryWithClassName:@"EventActivity"];
//    [query whereKey:@"fromUser" equalTo:[[PFUser currentUser]objectId]];
//    [query whereKey:kEventId equalTo:eventId];
//    [query orderByDescending:@"updatedAt"];
//    
//    object = [query getFirstObject:&error];
//    AMEventObject *eventObject = [[AMEventObject alloc]init];
////    if(error)
////    {
////        //            UIAlertView *alertiew = [[UIAlertView alloc]initWithTitle:@"Alert" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
////        //            [alertiew show];
////        return nil;
////    }
//    
//    [object fetchIfNeeded:&error];
//    if(error)
//    {
//        UIAlertView *alertiew = [[UIAlertView alloc]initWithTitle:@"Alert" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
//        [alertiew show];
//    }
//    
//    PFQuery *query2 = [PFQuery queryWithClassName:@"Event"];
//    [query2 whereKey:@"objectId" equalTo:[object objectForKey:kEventId]];
//    NSError *error2;
//    
//    PFObject *event = [query2 getFirstObject:&error2];
//    if(event)
//    {
//        eventObject.eventId = [object objectForKey:kEventId];
//        eventObject.nameoftheEvent = [event objectForKey:kNameofEvent];
//        eventObject.invitees = [event objectForKey:kInvitees];
//        eventObject.attendanceType = [object objectForKey:kAttendanceType];
//        eventObject.typeofEvent = [event objectForKey:kTypeofEvent];
//        eventObject.notes = [event objectForKey:kNotes];
//        eventObject.ownership = [object objectForKey:kOwnership];
//        eventObject.createdDate = [object objectForKey:kCreatedDate];
//        eventObject.ownerObjectId = [event objectForKey:kFromUser];
//        //                PFUser *l_user  = [object objectForKey:kOwner];
//        //                [l_user fetchIfNeeded];
//        if([[object objectForKey:kEventActivityType] isEqualToString:kCreated] || [[object objectForKey:kEventActivityType] isEqualToString:kReceivedInviation])
//        {
//            eventObject.displayName = [event objectForKey:kDisplayName];
//            eventObject.activityType2 = @"Created an event at";
//        }
//        else
//        {
//            eventObject.displayName = [event objectForKey:kDisplayName];
//            eventObject.activityType2 = @"Attended";
//        }
//        
//        eventObject.startingTime = [event objectForKey:kStartingTime];
//        eventObject.endingTime = [event objectForKey:kEndingTime];
//        
//        CLLocationCoordinate2D coordinate ;
//        coordinate.latitude = [[[[event objectForKey:KPlace]objectForKey:kLocation]objectForKey:kLatitude]floatValue];
//        coordinate.longitude = [[[[event objectForKey:KPlace]objectForKey:kLocation]objectForKey:kLongitude]floatValue];
//        NSData *iconData = [[event objectForKey:KPlace]objectForKey:kImage];
//        UIImage *iconImage  = [[UIImage alloc]initWithData:iconData];
//        [eventObject.placeofEvent setObject:[NSNumber numberWithFloat:[[[[event objectForKey:KPlace]objectForKey:kLocation]objectForKey:kLatitude]floatValue]] forKey:kLatitude];
//        [eventObject.placeofEvent setObject:[NSNumber numberWithFloat:[[[[event objectForKey:KPlace]objectForKey:kLocation]objectForKey:kLongitude]floatValue]] forKey:kLongitude];
//        [eventObject.placeofEvent setObject:[[event objectForKey:KPlace]objectForKey:kName] forKey:kNameofthePlace];
//        [eventObject.placeofEvent setObject:[[[event objectForKey:KPlace]objectForKey:kLocation]objectForKey:KPlace] forKey:kAddress];
//        [eventObject.placeofEvent setObject:iconImage forKey:kPlaceIcon];
//        eventObject.eventImage = iconImage;
//    }
//    
//    return eventObject;
////    NSData *data = [[NSUserDefaults standardUserDefaults]objectForKey:kEventsList];
////    NSMutableArray *eventsArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
////    [eventsArray insertObject:eventObject atIndex:0];
////    NSData *data2 = [NSKeyedArchiver archivedDataWithRootObject:eventsArray];
////    [[NSUserDefaults standardUserDefaults]setObject:data2 forKey:kEventsList];
////    [[NSUserDefaults standardUserDefaults]synchronize];
//    
//}


+(void)saveUsersLocationtoServer
{
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude);
//    if(prevLocation.latitude != location.latitude && prevLocation.longitude != location.longitude)
    {
        NSDictionary *locationDict = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithFloat:location.latitude],kLatitude,[NSNumber numberWithFloat:location.longitude],kLongitude, nil];
        if([PFUser currentUser])
        {
            NSString *objectId = [[NSUserDefaults standardUserDefaults]objectForKey:kLocationObjectId];
            if(objectId){
                PFObject *object = [PFObject objectWithoutDataWithClassName:@"LocationData" objectId:objectId];
                [object setObject:locationDict forKey:kLocation];
                [object saveInBackground];
                NSLog(@"Saved location");
            }
            else{
                
                PFQuery *query  = [PFQuery queryWithClassName:@"LocationData"];
                [query whereKey:kFromUser equalTo:[PFUser currentUser]];
                [query getFirstObjectInBackgroundWithBlock:^(PFObject *locationObject,NSError *error) {
                    if(!error && locationObject)
                    {
                        [locationObject setObject:locationDict forKey:kLocation];
                        [locationObject saveInBackground];
                        [[NSUserDefaults standardUserDefaults]setObject:locationObject.objectId forKey:kLocationObjectId];
                        NSLog(@"Fethed and Saved location");
                    }
                    else
                    {
                        PFObject *object = [PFObject objectWithClassName:@"LocationData"];
                        [object setObject:locationDict forKey:kLocation];
                        [object setObject:[PFUser currentUser] forKey:kFromUser];
                        [object saveInBackgroundWithBlock:^(BOOL success,NSError *error){
                            [[NSUserDefaults standardUserDefaults]setObject:object.objectId forKey:kLocationObjectId];
                            NSLog(@"Saved location");
                        }];
                    }
                }];
            
            }
        }
    }
    prevLocation = location;
}

+(NSDictionary *)getUserLocation {
    
    
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude);
    
    NSDictionary *returnDict = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithFloat:location.latitude],kLatitude,[NSNumber numberWithFloat:location.longitude],kLongitude,nil];
    
    return returnDict;
}


/*
+(NSArray *)fetchEvents3
{
    NSMutableArray *eventsArray;
    if(!eventsArray)
        eventsArray = [[NSMutableArray alloc]init];
    [eventsArray removeAllObjects];
    NSError *error;
    
    NSMutableArray *savedEventsArray = [[NSMutableArray alloc]init];
    NSData *data1 = [[NSUserDefaults standardUserDefaults]objectForKey:kEventsList];
    if(data1)
        savedEventsArray = [NSKeyedUnarchiver unarchiveObjectWithData:data1];
    NSMutableArray *objectIdArray = [[NSMutableArray alloc]init];
    for(int i=0;i<savedEventsArray.count;i++) {
        AMEventObject *obj = [savedEventsArray objectAtIndex:i];
        [objectIdArray addObject:obj.eventId];
    }
    
    NSArray *friendsArray = [[NSArray alloc]init];
    friendsArray = [[NSUserDefaults standardUserDefaults]objectForKey:kFriends];
    NSMutableArray *finalObjId = [[NSMutableArray alloc]init];
    for (int i=0; i<friendsArray.count; i++) {
        NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:[friendsArray objectAtIndex:i]];
        [finalObjId addObject:[dictionary objectForKey:kObjectId]];
    }
    [finalObjId addObject:[[PFUser currentUser]objectId]];
    
    
    
    NSArray *statuses = [[NSArray alloc]initWithObjects:kCreated,kUpdated, nil];
    NSArray *array ;
    PFQuery *query = [PFQuery queryWithClassName:@"EventActivity"];
    [query whereKey:@"fromUser" containedIn:finalObjId];
    [query whereKey:kEventActivityType containedIn:statuses];
    [query orderByDescending:@"updatedAt"];
    array = [query findObjects:&error];
    if(error)
    {
        UIAlertView *alertiew = [[UIAlertView alloc]initWithTitle:@"Alert" message:error.localizedDescription delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alertiew show];
    }
    
    
    
    
    
    for(int i=0; i< array.count;i++)
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
        
        PFObject *object = [array objectAtIndex:i];
        NSString *objectIdString = [object objectForKey:kEventId];
        
        NSDate *eventDate = [dateFormatter dateFromString:[object objectForKey:kCreatedDate] ];
        {
            PFQuery *query = [PFQuery queryWithClassName:@"Event"];
            [query whereKey:@"objectId" equalTo:[object objectForKey:kEventId]];
            NSError *error2;
            PFObject *event = [query getFirstObject:&error2];
            if(event)
            {
                AMEventObject *eventObject = [[AMEventObject alloc]init];
                eventObject.eventId = [object objectForKey:kEventId];
                eventObject.nameoftheEvent = [event objectForKey:kNameofEvent];
                eventObject.invitees = [event objectForKey:kInvitees];
                
                eventObject.typeofEvent = [event objectForKey:kTypeofEvent];
                eventObject.notes = [event objectForKey:kNotes];
                eventObject.ownership = [object objectForKey:kOwnership];
                eventObject.createdDate = [object objectForKey:kCreatedDate];
                eventObject.modifiedDate = [object objectForKey:kCreatedDate];
                eventObject.ownerObjectId = [event objectForKey:kFromUser];
                eventObject.isParticipant = @"NO";
                
                NSArray *friendsArray = [[NSUserDefaults standardUserDefaults]objectForKey:kFriends];
                if([eventObject.ownerObjectId isEqualToString:[[PFUser currentUser]objectId]]) {
                    eventObject.profileImage = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults]objectForKey:kProfileImage_small]];
                }
                else
                    for(int i=0;i<friendsArray.count;i++)
                    {
                        NSDictionary *dictionary = [friendsArray objectAtIndex:i];
                        if([[dictionary objectForKey:kObjectId] isEqualToString:eventObject.ownerObjectId])
                        {
                            eventObject.profileImage = [UIImage imageWithData:[dictionary objectForKey:kProfileImage]];
                            break;
                        }
                    }
                
                NSMutableArray *temp_inviteesArray = [[NSMutableArray alloc]init];
                
                for(int i=0;i<eventObject.invitees.count;i++) {
                    NSDictionary *dict = [eventObject.invitees objectAtIndex:i];
                    [temp_inviteesArray addObject:[dict objectForKey:kObjectId]];
                }
                if([eventObject.ownerObjectId isEqualToString:[[PFUser currentUser]objectId]])
                    [temp_inviteesArray addObject:[[PFUser currentUser]objectId]];
                
                for(int i=0;i<temp_inviteesArray.count;i++)
                {
                    if([[temp_inviteesArray objectAtIndex:i] isEqualToString:[[PFUser currentUser]objectId]]){
                        eventObject.isParticipant = @"YES";
                        break;
                    }
                }
                
                if(eventObject.isParticipant) {
                    if([eventObject.ownerObjectId isEqualToString:[[PFUser currentUser]objectId]])
                        eventObject.attendanceType = [object objectForKey:kAttendanceType];
                    else {
                        PFQuery *attendanceQuery = [PFQuery queryWithClassName:@"EventActivity"];
                        [attendanceQuery whereKey:kEventId equalTo:eventObject.eventId];
                        [attendanceQuery whereKey:kFromUser equalTo:[[PFUser currentUser]objectId]];
                        PFObject *object = [attendanceQuery getFirstObject];
                        eventObject.attendanceType = [object objectForKey:kAttendanceType];
                    }
                }
                else{
                    eventObject.attendanceType = @"NA";
                }
                eventObject.displayName = [event objectForKey:kDisplayName];
                if([[object objectForKey:kEventActivityType] isEqualToString:kCreated] )
                {
                    
                    eventObject.activityType2 = @"Created an event at";
                }
                else if([[object objectForKey:kEventActivityType] isEqualToString:kUpdated]) {
                    eventObject.activityType2 = @"Updated an event at";
                }
                
                else if([[object objectForKey:kEventActivity ]isEqualToString:@"Attended"])
                {
                    
                    eventObject.activityType2 = @"Attended an event at";
                }
                eventObject.startingTime = [event objectForKey:kStartingTime];
                eventObject.endingTime = [event objectForKey:kEndingTime];
                CLLocationCoordinate2D coordinate ;
                coordinate.latitude = [[[[event objectForKey:KPlace]objectForKey:kLocation]objectForKey:kLatitude]floatValue];
                coordinate.longitude = [[[[event objectForKey:KPlace]objectForKey:kLocation]objectForKey:kLongitude]floatValue];
                NSData *iconData = [[event objectForKey:KPlace]objectForKey:kImage];
                UIImage *iconImage  = [[UIImage alloc]initWithData:iconData];
                eventObject.eventImage = iconImage;
                [eventObject.placeofEvent setObject:[NSNumber numberWithFloat:[[[[event objectForKey:KPlace]objectForKey:kLocation]objectForKey:kLatitude]floatValue]] forKey:kLatitude];
                [eventObject.placeofEvent setObject:[NSNumber numberWithFloat:[[[[event objectForKey:KPlace]objectForKey:kLocation]objectForKey:kLongitude]floatValue]] forKey:kLongitude];
                [eventObject.placeofEvent setObject:[[event objectForKey:KPlace]objectForKey:kName] forKey:kNameofthePlace];
                [eventObject.placeofEvent setObject:[[[event objectForKey:KPlace]objectForKey:kLocation]objectForKey:KPlace] forKey:kAddress];
                [eventObject.placeofEvent setObject:iconImage forKey:kPlaceIcon];
                eventObject.eventImage = iconImage;
                //                    [objectIdArray addObject:eventObject.eventId];
                //                    [savedEventsArray addObject:eventObject];
                [eventsArray addObject:eventObject];
                //                    [savedEventsArray insertObject:eventObject atIndex:0];
            }
        }
    }
    
    
    savedEventsArray = [NSMutableArray arrayWithArray:eventsArray];
    for (int i=0; i<savedEventsArray.count; i++) {
        for(int j=0;j<savedEventsArray.count - i - 1;j++){
            AMEventObject *evntObj1 = [savedEventsArray objectAtIndex:j];
            AMEventObject *evntObj2 = [savedEventsArray objectAtIndex:j+1];
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
            [dateFormatter setDateFormat:@"MMM-dd-yyyy HH:mm"];
            
            NSDate *date1 = [dateFormatter dateFromString:evntObj1.createdDate];
            NSDate *date2 = [dateFormatter dateFromString:evntObj2.createdDate];
            
            if([date1 compare:date2] == NSOrderedAscending) {
                [savedEventsArray replaceObjectAtIndex:j withObject:evntObj2];
                [savedEventsArray replaceObjectAtIndex:j+1 withObject:evntObj1];
            }
        }
    }
    
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:savedEventsArray];
    [[NSUserDefaults standardUserDefaults]setObject:data forKey:kEventsList];
    [[NSUserDefaults standardUserDefaults]synchronize];
    return savedEventsArray;
}
 */

+(UIColor *)getColorwithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat )blue
{
    UIColor *returnColor = [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
    return returnColor;
}
+(void)showAlertwithTitle:(NSString *)title andMessage:(NSString *)message

{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:title message:message delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
    [alert show];
}

+(void)deleteEventWithParentId:(NSString *)parentId {
    PFQuery *query= [PFQuery queryWithClassName:kEventActivity];
    [query whereKey:kParent equalTo:parentId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects,NSError *err) {
        for (int i=0; i<objects.count; i++) {
            PFObject *obj = [objects objectAtIndex:i];
            [obj deleteInBackground];
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:kReloadtableData object:nil];
    }];

}

+(void)postEventCreationToFacebook:(PFObject *)event{
    
    if(![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
        return;
    
    NSString *eventName = [NSString stringWithFormat:@"Created an event '%@'",[event objectForKey:kNameofEvent]];
    NSString *placeAddress = [NSString stringWithFormat:@"at %@,%@",[[event objectForKey:kPlaceDetails] objectForKey:kName],[[event objectForKey:kPlaceDetails] objectForKey:kAddress]];
    
    NSString *notes = [event objectForKey:kNotes];
    PFFile *posterImage ;
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   eventName, @"name",
                                   placeAddress, @"caption",
                                   nil];
    if(notes.length)
        [params setObject:notes forKey:@"description"];
    
    if([event objectForKey:kPosterImage])
    {
        posterImage = [event objectForKey:kPosterImage];
        
    }
    else
    {
        if([[event objectForKey:kTypeofEvent] isEqualToString:@"Open"])
        {
            posterImage = [[PFUser currentUser]objectForKey:kOpenEventImage];
        }
        else
        {
            posterImage = [[PFUser currentUser]objectForKey:kInviteOnlyEventImage];
        }
    }
    [params setObject:posterImage.url forKey:@"Link"];
    [params setObject:posterImage.url forKey:@"picture"];
    FBRequest *req = [[FBRequest alloc] initWithSession:[PFFacebookUtils session] graphPath:@"me/feed" parameters:params HTTPMethod:@"POST"];
    
    [req startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(error)
            NSLog(@"Facebook Post: Error: %@",error);
        else
            NSLog(@"Facebook Resut:%@", result);
    }];
}

+(void)postAttendedEventToFacebook:(PFObject *)event{
    if(![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]])
        return;
    
    NSString *eventName = [NSString stringWithFormat:@"Attended an event '%@'",[event objectForKey:kNameofEvent]];
    NSString *placeAddress = [NSString stringWithFormat:@"at %@,%@",[[event objectForKey:kPlaceDetails] objectForKey:kName],[[event objectForKey:kPlaceDetails] objectForKey:kAddress]];
    
    NSString *notes = [event objectForKey:kNotes];
    PFFile *posterImage ;
    
    
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   eventName, @"name",
                                   placeAddress, @"caption",
                                   nil];
    if(notes.length)
        [params setObject:notes forKey:@"description"];
    
    if([event objectForKey:kPosterImage])
    {
        posterImage = [event objectForKey:kPosterImage];
        
    }
    else
    {
        if([[event objectForKey:kTypeofEvent] isEqualToString:@"Open"])
        {
            posterImage = [[PFUser currentUser]objectForKey:kOpenEventImage];
        }
        else
        {
            posterImage = [[PFUser currentUser]objectForKey:kInviteOnlyEventImage];
        }
    }
    [params setObject:posterImage.url forKey:@"Link"];
    [params setObject:posterImage.url forKey:@"picture"];
    FBRequest *req = [[FBRequest alloc] initWithSession:[PFFacebookUtils session] graphPath:@"me/feed" parameters:params HTTPMethod:@"POST"];
    
    [req startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if(error)
            NSLog(@"Facebook Post: Error: %@",error);
        else
            NSLog(@"Facebook Resut:%@", result);
    }];
}

@end
