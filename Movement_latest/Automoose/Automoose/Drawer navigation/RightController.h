//
//  RightController.h
//  DDMenuController
//
//  Created by Devin Doty on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFSideMenu.h"
@interface RightController : UIViewController
{
    UIButton *goingButton;
    UIButton *mayBeButton;
    UIButton *allButton;
    UIImageView *bottomImageView;
    NSMutableArray *allEventsArray;
    NSMutableArray *tableDataArray;
    NSArray *eventsArray;
    
    UIView * headerView;
	UIView * topView;
	UILabel * topLabel;
	BOOL refreshing;
    UIActivityIndicatorView *activtyIndicator;
    
}
@property (nonatomic, assign) MFSideMenu *sideMenu;
@property(nonatomic,strong) UITableView *table;

@end
