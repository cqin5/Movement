//
//  AMProfileCommonController.h
//  Automoose
//
//  Created by Srinivas on 12/2/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCSwitchOnOff.h"
#import <FacebookSDK/FacebookSDK.h>
@interface AMProfileCommonController : UIViewController<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,FBRequestDelegate,UIAlertViewDelegate>
{
    IBOutlet UITableView *profileTableview;
    UIButton *addAnother;
    UISegmentedControl *locationDiscoverablePermissions;
    UISegmentedControl *locationAutoupdate;
    UIButton *editButton;
    UITextField *nameField;
    NSString *nameString;
    
    
    UILabel *nameLabel,*sinceLabel,*facebookLink,*discoverable,*autoUpdate;
    RCSwitchOnOff *discoverableSwitch,*autoUpdateSwitch;
    
    UIImageView *profileImage;
}

@end
