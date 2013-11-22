//
//  AMSignUpController.h
//  Automoose
//
//  Created by Srinivas on 05/07/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMSignUpController : UIViewController<UITextFieldDelegate>
{
    UITextField *username, *password,*email;
    UIButton *singUpButton, *cancelButton;
}
@end
