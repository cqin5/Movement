//
//  AMConstants.h
//  Automoose
//
//  Created by Srinivas on 12/2/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface Constants : NSObject



#define kTempLatitude 42.9837
#define kTempLongitude -81.2497

typedef enum
{
    kAll,
    kPlaces,
    kPeople,
    kEvents
}SearchType;

typedef enum
{
 kGoingType,
 kMayBeType,
 kAllEventsType
}EventType;

//Device size
#define kScreenheight [UIScreen mainScreen].bounds.size.height
#define kScreenWidth [UIScreen mainScreen].bounds.size.width
//Device orientation related
#define kIsIphone UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone
#define kIsIpad UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define kIsIphone568 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568)
#define kScreenheight [UIScreen mainScreen].bounds.size.height

#define kLastSyncdDate @"lastSyncdDate"
#define kLastFriendsSyncDate @"lastFriendsSyncDate"
#define kLocationObjectId @"locationObejectId"


//#define kEvents @"evenList"
#define kTimeline @"timeline"
#define kCoreEventData @"coreEventData"

#define kRefreshProfile @"refreshProfile"
#define kNotificationUpdatePeopleCount @"updatePeopleCount"

#define isPhone568 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568)

#define kError @"error"
#define kAlert @"Alert"
#define kBadgeNumber @"badgeNumber"
#define kFacebookId @"facebookId"
#define kAllowAutoUpdate @"allowAutoUpdate"
#define kAllowLocationTracking @"allowLocationTracking"
#define kIsAppRunningFirstTime @"isAppRunningFirstTime"
#define kProfileImage_small @"profileImageSmall"
#define kProfileImage_Big @"profileImageBig"
#define kLowerCaseDisplayName @"lowerCaseDisplayName"
#define kAccountCreatedDate @"accountCreatedDate"
#define kFollowingCount @"followingCount"
#define kFollowersCount @"followersCount"

#define kIndex @"index"
#define kEvent @"Event"
#define kGoing @"going"
#define kMaybe @"mayBe"
#define kNotGoing @"notGoing"
#define kEventActivity @"EventActivity"
#define kFromUser @"fromUser"
#define kToUser @"toUser"
#define kUsername @"username"
#define kActivity @"Activity"


#define kNameofEvent @"NameofEvent"
#define kOwnership @"Ownership"
#define kEndingTime @"EndingTime"
#define kStartingTime @"StartingTime"
#define kNotes @"Notes"
#define kInvitees @"Invitees"
#define KPlace @"Place"
#define kImage @"Image"
#define kLocation @"location"
#define kLatitude @"latitude"
#define kLongitude @"longitude"
#define kName @"Name"
#define kTypeofEvent @"TypeofEvent"
#define kEventId @"EventId"
#define kAttendanceType @"AttendanceType"
#define kAddress @"Address"
#define kNameofthePlace @"NameofthePlace"
#define kPlaceIcon @"PlaceIcon"
#define kEventActivityType @"EventActivityType"
#define kOwner @"owner"
#define kParticipant @"participant"
#define kDisplayName @"displayName"
#define kReceivedInviation @"ReceivedInviation"
#define kCreated @"Created"
#define kUpdated @"Updated"
#define kAttended @"attended"
#define kCreatedDate @"CreatedDate"
#define kObjectId @"objectId"
#define kDefaultEvent @"DefaultEvent"
#define kDefaultEventSaved @"defaultEventSaved"
#define kAction @"Action"
#define kTypeofEventtoBecarriedOut  @"typeofEventtoBeCarriedOut"
#define kIsParticipant @"isParticipant"
#define kPosterImage @"posterImage"
#define kSpecifics @"specifics"
#define kUpdatedAt @"updatedAt"
#define kLowerCaseEventName @"lowerCaseEventName"

#define kOwnerObjectId @"ownerObjectId"
#define kActivityCreatedDate @"activityCreatedDate"
#define kModifiedDate @"modifiedDate"

#define kNewEventCreation @"NewEventCreation"
#define kUpdateEvent @"UpdateEvent"

#define kInviteeType @"Invitee"
#define kPlaceType @"Place"
#define kType @"Type"

#define kEventsList @"EventsList"

#define kChannel @"channel"
#define kProfileImage @"profileImage"
#define kFriends @"friends"
#define kFollowers @"followers"
#define kFollowing @"following"

#define kFriendTimeLineList @"friendTimeLineList"
#define kFollowersCount @"followersCount"
#define kFollowingCount @"followingCount"
#define kEventsCount @"eventsCount"
#define kEventsTimeLine @"eventsTimeline"
#define kProfileImageData @"profileImageData"

#define kParent @"parent"

#define kPhotoIdArray @"photoIdArray"
#define kPlaceId @"placeId"
#define kRating @"rating"
#define kIconUrl @"iconUrl"
#define kIsImageDownloaded @"isImageDownloaded"


#define kPlacesFetching @"placesFetching"
#define kPlaceDetails @"placeDetails"

#define kEnroute @"enroute"
#define kArrived @"arrived"


#define kDisplay_phone @"display_phone"
#define kImage_url @"image_url"
#define kDisplay_address @"display_address"
#define kDisplay_phone @"display_phone"
#define kMobile_url @"mobile_url"
#define kRating @"rating"
#define kSnippet_text @"snippet_text"
#define kCoordinate @"coordinate"
#define kPlace_latitude @"latitude" 
#define kPlace_longitude @"longitude"
#define kMobile_url @"mobile_url"
#define kPlace_name @"name"
#define kCategories @"categories"

#define kReloadtableData @"reloadtableData"

#define kLoginTrack @"Login Track"
#define kSingUpTrack @"Sign Up Track"
#define kFacebookSignIn @"Facebook SignIn"
#define KFacebookSignUp @"Facebook SignUp"
#define kUsername @"username"

#define kOpenEventImage @"openEventImage"
#define kInviteOnlyEventImage @"inviteOnlyEvent"

@end
