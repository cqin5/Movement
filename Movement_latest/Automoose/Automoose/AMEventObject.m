//
//  AMEventObject.m
//  Automoose
//
//  Created by Srinivas on 12/17/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import "AMEventObject.h"
#import "AMConstants.h"
@implementation AMEventObject

@synthesize invitees,placeofEvent,eventId,nameoftheEvent,startingTime,endingTime,attendanceType,ownership,typeofEvent,notes,activityType2,displayName,createdDate,ownerObjectId,eventImage,profileImage,isParticipant;
@synthesize modifiedDate;
-(id)init{
    
    self = [super init];
    if(self)
    {
        invitees = [[NSMutableArray alloc]init];
        placeofEvent = [[NSMutableDictionary alloc]init];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.eventId forKey:kEventId];
    [encoder encodeObject:self.nameoftheEvent forKey:kNameofEvent];
    [encoder encodeObject:self.startingTime forKey:kStartingTime];
    [encoder encodeObject:self.endingTime forKey:kEndingTime];
    [encoder encodeObject:self.attendanceType forKey:kAttendanceType];
    [encoder encodeObject:self.ownership forKey:kOwnership];
    [encoder encodeObject:self.invitees forKey:kInvitees];
    [encoder encodeObject:self.placeofEvent forKey:KPlace];
    [encoder encodeObject:self.typeofEvent forKey:kTypeofEvent];
    [encoder encodeObject:self.notes forKey:kNotes];
    [encoder encodeObject:self.activityType2 forKey:kAction];
    [encoder encodeObject:self.displayName forKey:kDisplayName];
    [encoder encodeObject:self.createdDate forKey:kCreatedDate];
    [encoder encodeObject:self.ownerObjectId forKey:kOwner];
    [encoder encodeObject:self.eventImage forKey:kImage];
    [encoder encodeObject:self.typeofEventtoBeCarriedOut forKey:kTypeofEventtoBecarriedOut];
    [encoder encodeObject:self.profileImage forKey:kProfileImage];
    [encoder encodeObject:self.isParticipant forKey:kIsParticipant];
    [encoder encodeObject:self.modifiedDate forKey:kModifiedDate];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.eventId = [decoder decodeObjectForKey:kEventId];
        self.nameoftheEvent = [decoder decodeObjectForKey:kNameofEvent];
        self.startingTime = [decoder decodeObjectForKey:kStartingTime];
        self.endingTime = [decoder decodeObjectForKey:kEndingTime];
        self.attendanceType = [decoder decodeObjectForKey:kAttendanceType];
        self.ownership = [decoder decodeObjectForKey:kOwnership];
        self.invitees = [decoder decodeObjectForKey:kInvitees];
        self.placeofEvent = [decoder decodeObjectForKey:KPlace];
        self.typeofEvent = [decoder decodeObjectForKey:kTypeofEvent];
        self.notes = [decoder decodeObjectForKey:kNotes];
        self.activityType2 = [decoder decodeObjectForKey:kAction];
        self.displayName = [decoder decodeObjectForKey:kDisplayName];
        self.createdDate = [decoder decodeObjectForKey:kCreatedDate];
        self.ownerObjectId = [decoder decodeObjectForKey:kOwner];
        self.eventImage = [decoder decodeObjectForKey:kImage];
        self.typeofEventtoBeCarriedOut = [decoder decodeObjectForKey:kTypeofEventtoBecarriedOut];
        self.profileImage = [decoder decodeObjectForKey:kProfileImage];
        self.isParticipant = [decoder decodeObjectForKey:kIsParticipant];
        self.modifiedDate = [decoder decodeObjectForKey:kModifiedDate];
    }
    return self;
}

//- (id) mutableCopy					{ return [self mutableCopyWithZone:NSDefaultMallocZone()]; }

- (id)mutableCopyWithZone:(NSZone *)zone {
    
    id instance = nil;
    
    if ((instance = [[[self class] alloc] init])) {
        
        [instance setEventId:[self.eventId mutableCopyWithZone:zone]];
        [instance setNameoftheEvent:[self.nameoftheEvent mutableCopyWithZone:zone]];
        [instance setStartingTime:[self.startingTime mutableCopyWithZone:zone]];
        [instance setEndingTime:[self.endingTime mutableCopyWithZone:zone]];
        [instance setAttendanceType:[self.attendanceType mutableCopyWithZone:zone]];
        [instance setOwnership:[self.ownerObjectId mutableCopyWithZone:zone]];
        [instance setInvitees:[self.invitees mutableCopyWithZone:zone]];
        [instance setPlaceofEvent:[self.placeofEvent mutableCopyWithZone:zone]];
        [instance setTypeofEvent:[self.typeofEvent mutableCopyWithZone:zone]];
        [instance setNotes:[self.notes mutableCopyWithZone:zone]];
        [instance setActivityType2:[self.activityType2 mutableCopyWithZone:zone]];
        [instance setDisplayName:[self.displayName mutableCopyWithZone:zone]];
        [instance setCreatedDate:[self.createdDate mutableCopyWithZone:zone]];
        [instance setOwnerObjectId:[self.ownerObjectId mutableCopyWithZone:zone]];
        [instance setTypeofEventtoBeCarriedOut:[self.typeofEventtoBeCarriedOut mutableCopyWithZone:zone]];
        [instance setEventImage:self.eventImage];
        [instance setProfileImage:self.profileImage];
        [instance setIsParticipant:self.isParticipant];
        [instance setModifiedDate:self.modifiedDate];
    }
    return instance;
}

@end
