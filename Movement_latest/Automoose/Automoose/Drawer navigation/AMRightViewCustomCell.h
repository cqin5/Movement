//
//  AMRightViewCustomCell.h
//  Automoose
//
//  Created by Srinivas on 10/03/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMRightViewCustomCell : UITableViewCell
@property(nonatomic,strong)UILabel *eventName;
@property(nonatomic,strong)UILabel *eventTime;
@property(nonatomic,strong)UISegmentedControl *statusControl;
@end
