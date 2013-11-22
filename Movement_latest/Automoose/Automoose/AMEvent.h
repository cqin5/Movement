//
//  AMEvent.h
//  Automoose
//
//  Created by Srinivas on 21/03/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMEvent : NSObject
@property(nonatomic,strong)NSString *eventId;
@property(nonatomic,strong)NSString *nameoftheEvent;
@property(nonatomic,strong)NSString *startingTime;
@property(nonatomic,strong)NSString *endingTime;
@property(nonatomic,strong)NSMutableArray *invitees;
@property(nonatomic,strong)NSMutableDictionary *placeofEvent;
@property(nonatomic,strong)NSString *typeofEvent;
@property(nonatomic,strong)NSString *notes;
@property(nonatomic,strong)NSString *createdDate;
@property(nonatomic,strong)NSString *modifiedDate;
@property(nonatomic,strong)UIImage *eventImage;
@property(nonatomic,strong)UIImage *profileImage;
@property(nonatomic,strong)NSString *displayName;

- (id)mutableCopyWithZone:(NSZone *)zone;
 @end
