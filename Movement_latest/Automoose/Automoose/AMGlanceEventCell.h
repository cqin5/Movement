//
//  AMGlanceEventCell.h
//  Automoose
//
//  Created by Srinivas on 20/06/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "AMConstants.h"
@interface AMGlanceEventCell : UITableViewCell
@property(nonatomic,strong) PFImageView *eventImageview;
@property(nonatomic,strong) PFImageView *userImageview;
@property(nonatomic,strong) UILabel *actionLabel;
@property(nonatomic,strong) UILabel *eventNameLabel;
@property(nonatomic,strong) UILabel *eventTimeLabel;
@property(nonatomic,strong) UIButton *moreButton;
@property(nonatomic,strong) UIButton *eventImageButton;

@property(nonatomic,strong) UIButton *userProfileButton,*eventDetailsButton;
@end
