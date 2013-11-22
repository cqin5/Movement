//
//  AMGlanceEventViewController.h
//  Automoose
//
//  Created by Srinivas on 12/5/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GlanceEventDelegate <NSObject>

-(void)CreateEvent;

@end
@class AMGlanceCommonController;
@class AMCreateEventController;
@interface AMGlanceEventViewController : UIViewController<GlanceEventDelegate,UITableViewDataSource,UITableViewDelegate>
{
    AMCreateEventController *createEvent;
    id<GlanceEventDelegate> delegate;
    NSArray *eventsArray;
}
@property(nonatomic,strong) id<GlanceEventDelegate> delegate;
@property(nonatomic,strong) IBOutlet UITableView *eventTableView;
@end
