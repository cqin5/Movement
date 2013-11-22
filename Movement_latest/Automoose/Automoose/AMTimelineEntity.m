//
//  AMTimelineEntity.m
//  Automoose
//
//  Created by Srinivas on 21/03/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import "AMTimelineEntity.h"
#import "AMConstants.h"

@implementation AMTimelineEntity
@synthesize eventId,attendanceType,ownerObjectId,ownership,activityType2,isParticipant,activityCreatedDate;

-(id)init{
    
    self = [super init];
    if(self)
    {
        
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.eventId forKey:kEventId];
    [encoder encodeObject:self.attendanceType forKey:kAttendanceType];
    [encoder encodeObject:self.ownership forKey:kOwnership];
    [encoder encodeObject:self.activityType2 forKey:kAction];
    [encoder encodeObject:self.ownerObjectId forKey:kOwner];
    [encoder encodeObject:self.isParticipant forKey:kIsParticipant];
    [encoder encodeObject:self.activityCreatedDate forKey:kActivityCreatedDate];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.eventId = [decoder decodeObjectForKey:kEventId];
        self.attendanceType = [decoder decodeObjectForKey:kAttendanceType];
        self.ownership = [decoder decodeObjectForKey:kOwnership];
        self.activityType2 = [decoder decodeObjectForKey:kAction];
        self.ownerObjectId = [decoder decodeObjectForKey:kOwner];
        self.isParticipant = [decoder decodeObjectForKey:kIsParticipant];
        self.activityCreatedDate = [decoder decodeObjectForKey:kActivityCreatedDate];
    }
    return self;
}

//- (id) mutableCopy					{ return [self mutableCopyWithZone:NSDefaultMallocZone()]; }

- (id)mutableCopyWithZone:(NSZone *)zone {
    
    id instance = nil;
    
    if ((instance = [[[self class] alloc] init])) {
        
        [instance setEventId:[self.eventId mutableCopyWithZone:zone]];
        [instance setAttendanceType:[self.attendanceType mutableCopyWithZone:zone]];
        [instance setOwnership:[self.ownerObjectId mutableCopyWithZone:zone]];
        [instance setActivityType2:[self.activityType2 mutableCopyWithZone:zone]];
        [instance setOwnerObjectId:[self.ownerObjectId mutableCopyWithZone:zone]];
        [instance setIsParticipant:self.isParticipant];
        [instance setActivityCreatedDate:self.activityCreatedDate];
    }
    return instance;
}


@end
