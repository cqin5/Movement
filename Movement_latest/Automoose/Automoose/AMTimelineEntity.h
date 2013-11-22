//
//  AMTimelineEntity.h
//  Automoose
//
//  Created by Srinivas on 21/03/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMTimelineEntity : NSObject
@property(nonatomic,strong)NSString *eventId;
@property(nonatomic,strong)NSString *attendanceType;
@property(nonatomic,strong)NSString *ownership;
@property(nonatomic,strong)NSString *activityType2;
@property(nonatomic,strong)NSString *isParticipant;
@property(nonatomic,strong)NSString *ownerObjectId;
@property(nonatomic,strong)NSString *activityCreatedDate;
- (id)mutableCopyWithZone:(NSZone *)zone;
@end
