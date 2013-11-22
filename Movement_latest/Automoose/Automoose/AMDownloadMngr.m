//
//  AMDownloadMngr.m
//  Automoose
//
//  Created by Srinivas on 31/01/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import "AMDownloadMngr.h"

@implementation AMDownloadMngr
-(id)initwithUrlString:(NSString *)urlString withIndex:(NSInteger)index
{
    if (![super init]) return nil;
    indexofImage = index;
    responseData = [[NSMutableData alloc]init];
    [self downloadFile:urlString];
    return self;
}

-(void)downloadFile:(NSString *)urlString
{
    NSURLRequest *urlRequest = [[NSURLRequest alloc]initWithURL:[NSURL URLWithString:urlString]];
    NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:urlRequest delegate:self];
    if(!connection)
        NSLog(@"Network connection failed!");
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"%@",error.localizedDescription);
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [responseData setLength:0];
}
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [responseData appendData:data];
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:responseData,@"imageData",[NSNumber numberWithInt:indexofImage],@"index", nil];
    [[NSNotificationCenter defaultCenter]postNotificationName:@"ImageDownloaded" object:dictionary];
}
@end
