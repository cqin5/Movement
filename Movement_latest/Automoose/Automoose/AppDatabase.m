//
//  AppDatabase.m
//  Automoose
//
//  Created by Srinivas on 26/04/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import "AppDatabase.h"
#import "NSDataAdditions.h"
#import "AMConstants.h"
#define kDatabaseName @"Database.sqlite"

static DataBaseManager *databaseManager = nil;
@interface AppDatabase (PrivateMethods)
- (void)beginTransaction;
- (void)commitTransaction;
- (void)rollbackTransaction;
@end
@implementation AppDatabase
+ (DataBaseManager *)sharedDatabasemanager
{
	if(nil == databaseManager)
	{
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *filepath = [documentsDirectory stringByAppendingPathComponent:kDatabaseName];
		databaseManager = [[DataBaseManager alloc] initDBWithFileName:filepath];
	}
	return databaseManager;
}

+ (void)releaseDatabasemanager
{
}

- (id) init
{
	self = [super init];
	if (self != nil)
	{
	}
	return self;
}

#pragma mark  - Private Methods

- (void)beginTransaction
{
	DataBaseManager *dbManager = [AppDatabase sharedDatabasemanager];
	[dbManager executeNonQuery:@"BEGIN TRANSACTION"];
}

- (void)commitTransaction
{
	DataBaseManager *dbManager = [AppDatabase sharedDatabasemanager];
	[dbManager executeNonQuery:@"COMMIT TRANSACTION"];
}

- (void)rollbackTransaction
{
	DataBaseManager *dbManager = [AppDatabase sharedDatabasemanager];
	[dbManager executeNonQuery:@"ROLLBACK TRANSACTION"];
}


#pragma mark methods
+(void)deleteEntireData{
    NSString *query = @"DELETE FROM Followers";
    DataBaseManager *dbManager = [AppDatabase sharedDatabasemanager];
    [dbManager executeQuery:query];
    
    query = @"DELETE FROM Following";
    [dbManager executeQuery:query];
}
+(void)saveFollowersData:(NSString *)valuesString{
    NSString *query =[NSString stringWithFormat:@"INSERT INTO Followers VALUES (%@)",valuesString];
    DataBaseManager *dbManager = [AppDatabase sharedDatabasemanager];
    [dbManager executeQuery:query];
}

+(void)saveFollowingData:(NSString *)valuesString{
    NSString *query =[NSString stringWithFormat:@"INSERT INTO Following VALUES (%@)",valuesString];
    DataBaseManager *dbManager = [AppDatabase sharedDatabasemanager];
    [dbManager executeQuery:query];
}

+(NSArray *)getEntireFollowerDetails{
    NSString *query = @"SELECT * FROM Followers";
    DataBaseManager *dbManager = [AppDatabase sharedDatabasemanager];
    NSArray *records = [dbManager executeQuery:query];
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];

    [records enumerateObjectsUsingBlock:^(NSMutableDictionary *dict, NSUInteger index, BOOL *stop){
        NSData *dataObj = [NSData dataWithBase64EncodedString:[dict objectForKey:kProfileImage]];
        [dict setObject:dataObj forKey:kProfileImage];
        [returnArray addObject:dict];
        
    }];
    return returnArray;
}

+(NSArray *)getEntireFollowingDetails{
    NSString *query = @"SELECT * FROM Following";
    DataBaseManager *dbManager = [AppDatabase sharedDatabasemanager];
    NSArray *records = [dbManager executeQuery:query];
    NSMutableArray *returnArray = [[NSMutableArray alloc]init];
    
    [records enumerateObjectsUsingBlock:^(NSMutableDictionary *dict, NSUInteger index, BOOL *stop){
        NSData *dataObj = [NSData dataWithBase64EncodedString:[dict objectForKey:kProfileImage]];
        [dict setObject:dataObj forKey:kProfileImage];
        [returnArray addObject:dict];
        
    }];
    return returnArray;
}

+(NSDictionary *)getFollowerDetailsWithObjectId:(NSString *)objectId{
    NSString *query = [NSString stringWithFormat: @"SELECT * FROM Followers WHERE objectId='%@'",objectId];
    DataBaseManager *dbManager = [AppDatabase sharedDatabasemanager];
    NSArray *records = [dbManager executeQuery:query];
    if(records.count){
        NSMutableDictionary *dict = [records objectAtIndex:0];
        NSData *dataObj = [NSData dataWithBase64EncodedString:[dict objectForKey:kProfileImage]];
        [dict setObject:dataObj forKey:kProfileImage];
        return dict;
    }
    
    return nil;
}

+(NSDictionary *)getFollowingDetailsWithObjectId:(NSString *)objectId{
    NSString *query = [NSString stringWithFormat: @"SELECT * FROM Following WHERE objectId='%@'",objectId];
    DataBaseManager *dbManager = [AppDatabase sharedDatabasemanager];
    NSArray *records = [dbManager executeQuery:query];
    if(records.count){
        NSMutableDictionary *dict = [records objectAtIndex:0];
        NSData *dataObj = [NSData dataWithBase64EncodedString:[dict objectForKey:kProfileImage]];
        [dict setObject:dataObj forKey:kProfileImage];
        return dict;
    }
    return nil;
}

@end
