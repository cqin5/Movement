//
//  AMMorePageViewController.h
//  Automoose
//
//  Created by LAVANYA  on 10/02/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMMorePageViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate>
{
    IBOutlet UIImageView *profileImage;
    IBOutlet UIImageView *fbImage;
    IBOutlet UIImageView *twitterImage;
    IBOutlet UILabel *name;
    IBOutlet UILabel *follwingCount;
    IBOutlet UILabel *followersCount;
    IBOutlet UILabel *invitationsCount;
    IBOutlet UILabel *eventsCount;
    

    IBOutlet UILabel *followersNameLabel;
    IBOutlet UILabel *followingNameLabel;
    IBOutlet UILabel *eventsNameLabel;
    
    IBOutlet UITableView *eventListTable;
    
    IBOutlet UIButton *followersButton;
    IBOutlet UIButton *followingButton;
    IBOutlet UIButton *eventsButton;
    IBOutlet UIImageView *profileBar;
    IBOutlet UIView *imageEditorContainer;
    IBOutlet UIView *profileView;
    
}
-(IBAction)followersButtonTapped:(id)sender;
-(IBAction)followingButtonTapped:(id)sender;
-(IBAction)invitationButtonTapped:(id)sender;
-(IBAction)eventButtonTapped:(id)sender;
-(IBAction)settingsButtonTapped:(id)sender;
@end
