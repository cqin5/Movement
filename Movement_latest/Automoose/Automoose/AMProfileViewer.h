//
//  AMProfileViewer.h
//  Automoose
//
//  Created by Srinivas on 12/15/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMProfileViewer : UIViewController<UITableViewDataSource,UITableViewDelegate,NSURLConnectionDelegate>
{
    IBOutlet UITableView *table;
//    IBOutlet UIView *summaryView;
//    IBOutlet UILabel *name;
//    IBOutlet UIImageView *imageview;
//    
//    IBOutlet UILabel *followersCount;
//    IBOutlet UILabel *followingCount;
//    IBOutlet UILabel *eventsCount;
//    IBOutlet UIButton *followButton;
    
    IBOutlet UIActivityIndicatorView *indicatorView;
    IBOutlet UIImageView *profileImage;
    IBOutlet UIImageView *fbImage;
    IBOutlet UIImageView *twitterImage;
    IBOutlet UILabel *name;
    IBOutlet UILabel *followingCount;
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
    IBOutlet UIView *profileView;
}
@property(nonatomic,strong)NSArray *dataArray;
@property(nonatomic,strong)IBOutlet UIView *summaryView;
@property(nonatomic,strong)IBOutlet UILabel *name;
@property(nonatomic,strong)IBOutlet UIImageView *imageview;

@property(nonatomic,strong)IBOutlet UILabel *followersCount;
@property(nonatomic,strong)IBOutlet UILabel *followingCount;
@property(nonatomic,strong)IBOutlet UILabel *eventsCount;
@property(nonatomic,strong)IBOutlet UIButton *followButton;
@property(nonatomic,strong)IBOutlet UIButton *inviteButton;
@property(nonatomic,strong)PFUser *user;
@property(nonatomic,strong)NSString *facebookID;

-(IBAction)followersButtonTapped:(id)sender;
-(IBAction)followingButtonTapped:(id)sender;
-(IBAction)invitationButtonTapped:(id)sender;
-(IBAction)eventButtonTapped:(id)sender;
-(IBAction)settingsButtonTapped:(id)sender;

-(void)showDetailsofUser:(PFUser *)user;
-(void)showCancelButton;


@end
