//
//  AMEventViewerController.h
//  Automoose
//
//  Created by Srinivas on 19/12/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AMEventObject;
@interface AMEventViewerController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView *eventTableView;
    IBOutlet UIScrollView *scrollView;
    NSArray *titleHeaders;
    BOOL istheUserParticipant;
    
}
@property(nonatomic,strong)AMEventObject *eventObject;
@property(nonatomic,assign)NSInteger indexofEvent;
@property(nonatomic,assign)BOOL isEventEditingAllowed;
@property(nonatomic,strong)PFObject *event;
- (void)setupMenuBarButtonItems;
@end
