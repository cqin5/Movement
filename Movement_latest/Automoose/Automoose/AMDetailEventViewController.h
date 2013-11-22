//
//  AMDetailEventViewController.h
//  Automoose
//
//  Created by Srinivas on 09/07/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMDetailEventViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView *table;
    NSMutableArray *goingPeopleData, *mayBePeopleData;
}
@property(nonatomic,strong)PFObject *eventData;
- (void)setupMenuBarButtonItems;
-(void)updateTableDatawithEvent:(PFObject *)event;
@end
