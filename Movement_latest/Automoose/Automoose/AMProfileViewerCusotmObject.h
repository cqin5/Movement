//
//  AMProfileViewerCusotmObject.h
//  Automoose
//
//  Created by Srinivas on 1/19/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMProfileViewerCusotmObject : NSObject
@property(nonatomic,strong)NSString *objectId;
@property(nonatomic,strong)NSString *nameofProfile;
@property(nonatomic,strong)NSString *follwersCount;
@property(nonatomic,strong)NSString *followingCount;
@property(nonatomic,strong)NSString *eventsCount;
@property(nonatomic,strong)NSMutableArray *eventTimelineArray;
@property(nonatomic,strong)NSData *profileImageData;
@property(nonatomic,strong)NSString *facebookID;
@end
