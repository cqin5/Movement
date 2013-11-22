//
//  AppDatabase.h
//  Automoose
//
//  Created by Srinivas on 26/04/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataBaseManager.h"

@interface AppDatabase : NSObject
+(void)deleteEntireData;
+(void)saveFollowersData:(NSString *)valuesString;
+(void)saveFollowingData:(NSString *)valuesString;
+(NSArray *)getEntireFollowerDetails;
+(NSArray *)getEntireFollowingDetails;
+(NSDictionary *)getFollowerDetailsWithObjectId:(NSString *)objectId;
+(NSDictionary *)getFollowingDetailsWithObjectId:(NSString *)objectId;
@end
