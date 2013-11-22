//
//  AMDownloadMngr.h
//  Automoose
//
//  Created by Srinivas on 31/01/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMDownloadMngr : NSOperation
{
    int indexofImage;
    NSMutableData *responseData;
}
-(id)initwithUrlString:(NSString *)urlString withIndex:(NSInteger)index;
@end
