//
//  AMAuthenticationViewController.h
//  Automoose
//
//  Created by Srinivas on 12/2/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
@interface AMAuthenticationViewController : UIViewController <FBRequestDelegate,NSURLConnectionDelegate>
{
    BOOL isParseLogin;
    
}
-(void)retrieveDataofUserifAlreadyLoggedin;

@end
