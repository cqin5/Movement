//
//  AMRequestTableCell.h
//  Automoose
//
//  Created by Srinivas on 11/02/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMRequestTableCell : UITableViewCell
@property(nonatomic,strong)UIImageView *profileImage;
@property(nonatomic,strong)UILabel *invitorName;
@property(nonatomic,strong)UILabel *eventName;
@property(nonatomic,strong)UISegmentedControl *segmentedControl;
@property(nonatomic,strong)UILabel *staticLabel;
@end
