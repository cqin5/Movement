//
//  AMEvent.m
//  Automoose
//
//  Created by Srinivas on 21/03/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import "AMEvent.h"
#import "AMConstants.h"

@implementation AMEvent

@synthesize eventId,nameoftheEvent,startingTime,endingTime,notes,invitees,placeofEvent,typeofEvent,createdDate,modifiedDate,eventImage,profileImage,displayName;

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
    [encoder encodeObject:self.invitees forKey:kInvitees];
    [encoder encodeObject:self.placeofEvent forKey:KPlace];
    [encoder encodeObject:self.typeofEvent forKey:kTypeofEvent];
    [encoder encodeObject:self.notes forKey:kNotes];
    [encoder encodeObject:self.displayName forKey:kDisplayName];
    [encoder encodeObject:self.createdDate forKey:kCreatedDate];
    [encoder encodeObject:self.eventImage forKey:kImage];
    [encoder encodeObject:self.profileImage forKey:kProfileImage];
    [encoder encodeObject:self.modifiedDate forKey:kModifiedDate];
}


- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.eventId = [decoder decodeObjectForKey:kEventId];
        self.nameoftheEvent = [decoder decodeObjectForKey:kNameofEvent];
        self.startingTime = [decoder decodeObjectForKey:kStartingTime];
        self.endingTime = [decoder decodeObjectForKey:kEndingTime];
        self.invitees = [decoder decodeObjectForKey:kInvitees];
        self.placeofEvent = [decoder decodeObjectForKey:KPlace];
        self.typeofEvent = [decoder decodeObjectForKey:kTypeofEvent];
        self.notes = [decoder decodeObjectForKey:kNotes];
        self.displayName = [decoder decodeObjectForKey:kDisplayName];
        self.createdDate = [decoder decodeObjectForKey:kCreatedDate];
        self.eventImage = [decoder decodeObjectForKey:kImage];
        self.profileImage = [decoder decodeObjectForKey:kProfileImage];
        self.modifiedDate = [decoder decodeObjectForKey:kModifiedDate];
    }
    return self;
}

- (id)mutableCopyWithZone:(NSZone *)zone {
    
    id instance = nil;
    
    if ((instance = [[[self class] alloc] init])) {
        
        [instance setEventId:[self.eventId mutableCopyWithZone:zone]];
        [instance setNameoftheEvent:[self.nameoftheEvent mutableCopyWithZone:zone]];
        [instance setStartingTime:[self.startingTime mutableCopyWithZone:zone]];
        [instance setEndingTime:[self.endingTime mutableCopyWithZone:zone]];
        [instance setInvitees:[self.invitees mutableCopyWithZone:zone]];
        [instance setPlaceofEvent:[self.placeofEvent mutableCopyWithZone:zone]];
        [instance setTypeofEvent:[self.typeofEvent mutableCopyWithZone:zone]];
        [instance setNotes:[self.notes mutableCopyWithZone:zone]];
        [instance setDisplayName:[self.displayName mutableCopyWithZone:zone]];
        [instance setCreatedDate:[self.createdDate mutableCopyWithZone:zone]];
        [instance setEventImage:self.eventImage];
        [instance setProfileImage:self.profileImage];
        [instance setModifiedDate:self.modifiedDate];
    }
    return instance;
}

@end
