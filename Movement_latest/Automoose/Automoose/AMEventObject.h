//
//  AMEventObject.h
//  Automoose
//
//  Created by Srinivas on 12/17/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMEventObject : NSObject

@property(nonatomic,strong)NSString *eventId;
@property(nonatomic,strong)NSString *nameoftheEvent;
@property(nonatomic,strong)NSString *startingTime;
@property(nonatomic,strong)NSString *endingTime;
@property(nonatomic,strong)NSString *attendanceType;
@property(nonatomic,strong)NSString *ownership;
@property(nonatomic,strong)NSMutableArray *invitees;
@property(nonatomic,strong)NSMutableDictionary *placeofEvent;
@property(nonatomic,strong)NSString *typeofEvent;
@property(nonatomic,strong)NSString *notes;
@property(nonatomic,strong)NSString *activityType2;
@property(nonatomic,strong)NSString *displayName;
@property(nonatomic,strong)NSString *createdDate;
@property(nonatomic,strong)NSString *ownerObjectId;
@property(nonatomic,strong)NSString *typeofEventtoBeCarriedOut;
@property(nonatomic,strong)UIImage *eventImage;
@property(nonatomic,strong)UIImage *profileImage;
@property(nonatomic,strong)NSString *isParticipant;

@property(nonatomic,strong)NSString *modifiedDate;

- (id)mutableCopyWithZone:(NSZone *)zone;

@end
