//
//  AMGlanceViewController.h
//  Automoose
//
//  Created by Srinivas on 21/12/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol GlanceEventDelegate <NSObject>

//-(void)CreateEvent;

@end
@class AMGlanceCommonController;
@class AMCreateEventController;
@class AMTimelineEntity;
@interface AMGlanceViewController : PFQueryTableViewController<GlanceEventDelegate>
{
    AMCreateEventController *createEvent;
    id<GlanceEventDelegate> delegate;
    NSArray *eventsArray;
    NSArray *events;
}
@property(nonatomic,strong) id<GlanceEventDelegate> delegate;
-(void)loadEventFromNotification:(NSString *)eventId;

-(void)fetchNewEventInvitation:(NSNotification *)notification;
@end
