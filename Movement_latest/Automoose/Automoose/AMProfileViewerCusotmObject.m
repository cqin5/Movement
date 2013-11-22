//
//  AMProfileViewerCusotmObject.m
//  Automoose
//
//  Created by Srinivas on 1/19/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import "AMProfileViewerCusotmObject.h"
#import "AMConstants.h"
@implementation AMProfileViewerCusotmObject
@synthesize objectId,nameofProfile,followingCount,follwersCount,eventsCount,eventTimelineArray,profileImageData,facebookID;

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.objectId forKey:kObjectId];
    [encoder encodeObject:self.nameofProfile forKey:kName];
    [encoder encodeObject:self.followingCount forKey:kFollowingCount];
    [encoder encodeObject:self.follwersCount forKey:kFollowersCount];
    [encoder encodeObject:self.eventsCount forKey:kEventsCount];
    [encoder encodeObject:self.eventTimelineArray forKey:kEventsTimeLine];
    [encoder encodeObject:self.profileImageData forKey:kProfileImageData];
    [encoder encodeObject:self.facebookID forKey:kFacebookId];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        self.objectId = [decoder decodeObjectForKey:kObjectId];
        self.nameofProfile = [decoder decodeObjectForKey:kName];
        self.followingCount = [decoder decodeObjectForKey:kFollowingCount];
        self.follwersCount = [decoder decodeObjectForKey:kFollowersCount];
        self.eventsCount = [decoder decodeObjectForKey:kEventsCount];
        self.eventTimelineArray = [decoder decodeObjectForKey:kEventsTimeLine];
        self.profileImageData = [decoder decodeObjectForKey:kProfileImageData];
        self.facebookID = [decoder decodeObjectForKey:kFacebookId];
    }
    return self;
}

@end
