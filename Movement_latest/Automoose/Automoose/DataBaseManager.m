
#import "DataBaseManager.h"

//private methods
@interface DataBaseManager(PRIVATE)

- (BOOL)executeStatament:(sqlite3_stmt *)stmt;
- (BOOL)prepareSql:(NSString *)sql inStatament:(sqlite3_stmt **)stmt;
- (void) bindObject:(id)obj toColumn:(int)idx inStatament:(sqlite3_stmt *)stmt;

- (BOOL)hasData:(sqlite3_stmt *)stmt;
- (id)columnData:(sqlite3_stmt *)stmt columnIndex:(NSInteger)index;
- (NSString *)columnName:(sqlite3_stmt *)stmt columnIndex:(NSInteger)index;

@end

@implementation DataBaseManager

@synthesize dbFileName;


- (id)init{
	
	if(self = [super init]){
		dbFileName = nil;
		database = nil;
	}
	return self;
}

- (id)initDBWithFileName:(NSString *)file{

	if(self=[super init]){
		database = nil;
		[self open:file];
	}
	return self;
}

- (BOOL)open:(NSString *)file{
	[self close];
	
	if (sqlite3_open([file fileSystemRepresentation], &database) != SQLITE_OK) {
		NSLog(@"SQLite Opening Error: %s", sqlite3_errmsg(database));
		return NO;
	}
	
	//dbFileName = [file retain];
	return YES;
}

- (void)close {
	if (database == nil) return;
	
	int rc;
	rc = sqlite3_close(database);
	if (rc != SQLITE_OK)
		NSLog(@"SQLite %@ Closing Error: %s", dbFileName, sqlite3_errmsg(database));
	//[dbFileName release];
	dbFileName = nil;
	database = nil;
}

- (NSString *)errorMsg {
	return [NSString stringWithFormat:@"%s", sqlite3_errmsg(database)];
}

//parses the number of arguments passed and calls execute
- (NSInteger)executeScalar:(NSString *)sql, ... {
	va_list args;
	va_start(args, sql);
	
	NSMutableArray *argsArray = [[NSMutableArray alloc] init];
	NSUInteger i;
	for (i = 0; i < [sql length]; ++i) {
		if ([sql characterAtIndex:i] == '?')
			[argsArray addObject:va_arg(args, id)];
	}
	
	va_end(args);
	NSInteger result = [self executeScalar:sql arguments:argsArray];
	//[argsArray release];
	return result;
}

//actually executes the query passed along with the parametres to bind
- (NSInteger)executeScalar:(NSString *)sql arguments:(NSArray *)args {
	
	sqlite3_stmt *sqlStmt;
	
	if (![self prepareSql:sql inStatament:(&sqlStmt)])	//prepare the sql query
		return 0;
	
	int i = 0;
	int queryParamCount = sqlite3_bind_parameter_count(sqlStmt);	//gives the ? count in a sql statement
	while (i++ < queryParamCount)
		[self bindObject:[args objectAtIndex:(i - 1)] toColumn:i inStatament:sqlStmt];	//bind objects to ? mark
	
	NSInteger ret = 0;
	int columnCount = sqlite3_column_count(sqlStmt);		//gives the number  of columns in an sql query statement
	if ([self hasData:sqlStmt] && columnCount > 0) 
	{	
		NSNumber *result = (NSNumber *)[self columnData:sqlStmt columnIndex:0];
		ret = [result intValue];
	}
	
	sqlite3_finalize(sqlStmt);	//free resources
	
	return ret;
}


//parses the number of arguments passed and calls execute
- (NSArray *)executeQuery:(NSString *)sql, ... {
//	va_list args;
//	va_start(args, sql);
//	
	NSMutableArray *argsArray = [[NSMutableArray alloc] init];
//	NSUInteger i;
//	for (i = 0; i < [sql length]; ++i) {
//		if ([sql characterAtIndex:i] == '?')
//			[argsArray addObject:va_arg(args, id)];
//	}
//	
//	va_end(args);
	NSArray *result = [self executeQuery:sql arguments:argsArray];
	return result;
}

//actually executes the query passed along with the parametres to bind
- (NSArray *)executeQuery:(NSString *)sql arguments:(NSArray *)args {
	sqlite3_stmt *sqlStmt;
	
	if (![self prepareSql:sql inStatament:(&sqlStmt)])	//prepare the sql query
		return nil;
	
	int i = 0;
	int queryParamCount = sqlite3_bind_parameter_count(sqlStmt);	//gives the ? count in a sql statement
	while (i++ < queryParamCount)
		[self bindObject:[args objectAtIndex:(i - 1)] toColumn:i inStatament:sqlStmt];	//bind objects to ? mark
	
	NSMutableArray *arrayList = [[NSMutableArray alloc] init];
	int columnCount = sqlite3_column_count(sqlStmt);		//gives the number  of columns in an sql query statement
	while ([self hasData:sqlStmt]) {	//do sql_step to fetch more row data
		NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
		for (i = 0; i < columnCount; ++i) {
			id columnName = [self columnName:sqlStmt columnIndex:i];	//fetch column name
			id columnData = [self columnData:sqlStmt columnIndex:i];
            if (columnData == nil ) {
                [dictionary setObject:[NSNull null] forKey:columnName];
            }
            else
            {
            //fetch column data
			[dictionary setObject:columnData forKey:columnName];
            }
		}
		[arrayList addObject:dictionary];
	}
	
	sqlite3_finalize(sqlStmt);	//free resources
	
	return arrayList;
}

- (BOOL)executeNonQuery:(NSString *)sql, ... {
	va_list args;
	va_start(args, sql);
	
	NSMutableArray *argsArray = [[NSMutableArray alloc] init];
	NSUInteger i;
	for (i = 0; i < [sql length]; ++i) {
		if ([sql characterAtIndex:i] == '?')
			[argsArray addObject:va_arg(args, id)];
	}
	
	va_end(args);
	
	BOOL success = [self executeNonQuery:sql arguments:argsArray];
	
	return success;
}


- (BOOL)executeNonQuery:(NSString *)sql arguments:(NSArray *)args {
	sqlite3_stmt *sqlStmt;
	
	if (![self prepareSql:sql inStatament:(&sqlStmt)])	//first prepare the sql statement
		return NO;
	
	int i = 0;
	int queryParamCount = sqlite3_bind_parameter_count(sqlStmt);	//get the parametere count
	while (i++ < queryParamCount)
		[self bindObject:[args objectAtIndex:(i - 1)] toColumn:i inStatament:sqlStmt];	//bind parametres
	
	BOOL success = [self executeStatament:sqlStmt];	//execute the statement
	
	sqlite3_finalize(sqlStmt); //free resources
	return success;	
}

//Returns the last inserted Row Id from the specified table
- (NSInteger) lastInsertRowId
{
	return sqlite3_last_insert_rowid(database);
}

- (BOOL)prepareSql:(NSString *)sql inStatament:(sqlite3_stmt **)stmt {
	int rc;
	rc = sqlite3_prepare_v2(database, [sql UTF8String], -1, stmt, NULL);	//prepare the statement
	//NSLog(@" - Query: %@", sql);
	if (rc == SQLITE_OK)
		return YES;
	NSLog(@"SQLite Prepare Failed: %s", sqlite3_errmsg(database));
	//NSLog(@" - Query: %@", sql);
	return NO;
}

- (BOOL)executeStatament:(sqlite3_stmt *)stmt {
	int rc;
	rc = sqlite3_step(stmt);	//execute the statement
	if (rc == SQLITE_OK || rc == SQLITE_DONE)
		return YES;
	NSLog(@"SQLite Step Failed: %s", sqlite3_errmsg(database));
	return NO;
}

- (void)bindObject:(id)obj toColumn:(int)idx inStatament:(sqlite3_stmt *)stmt {
	if (obj == nil) {
		sqlite3_bind_null(stmt, idx);	//null object
	} else if ([obj isKindOfClass:[NSData class]]) {
		sqlite3_bind_blob(stmt, idx, [obj bytes], [obj length], SQLITE_STATIC);	//blob data
	} else if ([obj isKindOfClass:[NSDate class]]) {	
		sqlite3_bind_double(stmt, idx, [obj timeIntervalSince1970]);	//timestamp
	} else if ([obj isKindOfClass:[NSNumber class]]) {					//if integer
		if (!strcmp([obj objCType], @encode(BOOL))) {					// boolean
			sqlite3_bind_int(stmt, idx, [obj boolValue] ? 1 : 0);
		} else if (!strcmp([obj objCType], @encode(int))) {
			sqlite3_bind_int64(stmt, idx, [obj longValue]);
		} else if (!strcmp([obj objCType], @encode(long))) {
			sqlite3_bind_int64(stmt, idx, [obj longValue]);
		} else if (!strcmp([obj objCType], @encode(float))) {
			sqlite3_bind_double(stmt, idx, [obj floatValue]);
		} else if (!strcmp([obj objCType], @encode(double))) {
			sqlite3_bind_double(stmt, idx, [obj doubleValue]);
		} else {
			sqlite3_bind_text(stmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);	//sql binding
		}
	} else {
		sqlite3_bind_text(stmt, idx, [[obj description] UTF8String], -1, SQLITE_STATIC);
	}
}

- (BOOL)hasData:(sqlite3_stmt *)stmt {
	int rc;
	rc = sqlite3_step(stmt);	//got data
	if (rc == SQLITE_ROW)
		return YES;
	//NSString *err = [self errorMsg];
	if (rc != SQLITE_DONE)
		NSLog(@"SQLite Prepare Failed: %s", sqlite3_errmsg(database));
	return NO;
}

//returns the column data given the index
- (id)columnData:(sqlite3_stmt *)stmt columnIndex:(NSInteger)index {
	int columnType = sqlite3_column_type(stmt, index);	//gets the coloumn type given the index
	
	if (columnType == SQLITE_INTEGER)
		return [NSNumber numberWithInt:sqlite3_column_int(stmt, index)];
	
	if (columnType == SQLITE_FLOAT)
		return [NSNumber numberWithDouble:sqlite3_column_double(stmt, index)];
	
	if (columnType == SQLITE_TEXT) {
		const unsigned char *text = sqlite3_column_text(stmt, index);
//		return [NSString stringWithFormat:@"%s", text];
		return [NSString stringWithUTF8String:(const char *)text];
	}
	
	if (columnType == SQLITE_BLOB) {
		int nbytes = sqlite3_column_bytes(stmt, index);
		const char *bytes = sqlite3_column_blob(stmt, index);
		return [NSData dataWithBytes:bytes length:nbytes];
	}
	
	return nil;
}

//returns the column name given the index
- (NSString *)columnName:(sqlite3_stmt *)stmt columnIndex:(NSInteger)index {
	return [NSString stringWithUTF8String:sqlite3_column_name(stmt, index)] ;
}

- (void)dealloc {
	[self close];
}

@end
