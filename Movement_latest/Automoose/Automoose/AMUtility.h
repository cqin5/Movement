//
//  AMUtility.h
//  Automoose
//
//  Created by Srinivas on 12/2/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

//Ios key
//#define kGOOGLE_API_KEY @"AIzaSyAMzckvSmg8rU2GVOlejhc4FU-ayM8TCN4-eRnHk8"   

//New key
#define kGOOGLE_API_KEY @"AIzaSyDXTUdvK5PmhOlvtQul4R4xeeXNqkC4mbM"



@class AMEventObject;
@class AMProfileViewerCusotmObject;
@class AMPlaceObject;
@class AMEvent;
CLLocationManager *locationManager;
CLLocationCoordinate2D prevLocation;
@interface AMUtility : NSObject<CLLocationManagerDelegate>
{
   
    
}
//@property(strong,nonatomic) NSMutableArray *friendsArray;
//@property(strong,nonatomic) NSMutableArray *eventsArray;
+(id) sharedInstance;
+(void)initLocationManager;
+ (void)followUserInBackground_justFollow:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock;
+ (void)followUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error))completionBlock ;

//+(BOOL)createEventWithdetailsbyUser:(AMEventObject *)eventObject;
+(void)saveUsersLocationtoServer;

+(void)fetchFollowers:(void (^)(NSError *error))completionBlock;
+(void)fetchFollowing:(void (^)(NSError *error))completionBlock;
//+(NSArray *)fetchNearByRestaurants;
+(NSArray *)fetchEvents;

+(void)saveCustomObject:(AMEventObject *)obj;
//+ (AMEventObject *)loadCustomObjectWithKey:(NSString *)key;
+(void)removeCustomObjectwithKey:(NSString *)key;
//+(void)fetchFriendsTimeline:(NSArray *)friendsData;
//+(AMEventObject *)fetchFirstEventtoMakeitDefaultEvent;
+(NSArray *)fetchPeopleFromParseWithString:(NSString *)searchString;
+(NSArray *)fetchEventsofFriendsWithString:(NSString *)searchString;
//+(AMProfileViewerCusotmObject *)fetchTimelineofUser:(PFUser *)user;
//+(NSArray *)fetchRestaurantswithString:(NSString *)searchString;
//+(AMPlaceObject *)fetchDetailsofPlacewithDetails:(AMPlaceObject *)placeObj;
+ (BOOL)userHasValidFacebookData:(PFUser *)user ;

//+(AMProfileViewerCusotmObject *)fetchTimelineofUserwithData:(NSDictionary *)data;
+(void)fetchTimelineofUserwithData:(NSDictionary *)data block:(void (^)(BOOL succeeded, NSError *error,AMProfileViewerCusotmObject *object))completionBlock;
//+(AMProfileViewerCusotmObject *)fetchTimelineofUser:(PFUser *)user block:(void (^)(BOOL succeeded, NSError *error,AMProfileViewerCusotmObject *object))completionBlock;
+(NSDictionary *)getUserLocation;
//+(AMEvent *)fetchEventwitheventId:(NSString *)eventId;
+(void)unfollowUserInBackground:(PFUser *)user block:(void (^)(BOOL succeeded,NSError *error))completionBlock;
+(void)reloadEventsData:(void(^)(NSError *error))completionBlock;
+(UIColor *)getColorwithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat )blue;

+(UIButton *)getButton;
+(UIView *)getLeftviewforview:(UIView *)targetView;
+(UITextField *)getTextfield;
+(UILabel *)getLabelforTableHeader;
+(void)showAlertwithTitle:(NSString *)title andMessage:(NSString *)message;
+(void)deleteEventWithParentId:(NSString *)parentId;
+(void)postEventCreationToFacebook:(PFObject *)event;
+(void)postAttendedEventToFacebook:(PFObject *)event;

@end
