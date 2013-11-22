//
//  AMLoginViewController.h
//  Automoose
//
//  Created by Srinivas on 05/07/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface AMLoginViewController : UIViewController<UITextFieldDelegate,FBRequestDelegate,NSURLConnectionDelegate,FBLoginViewDelegate>
{
    UITextField *username,*password;
    UIButton *logInButton,*signUpButton,*facebookSignIn;
}
@end
