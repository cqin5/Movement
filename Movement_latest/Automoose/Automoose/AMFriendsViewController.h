//
//  AMFriendsViewController.h
//  Automoose
//
//  Created by Srinivas on 12/9/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AMCreateEventController;
@protocol AMFriendsViewControllerDelegate <NSObject>

-(void)friendSelectionDone:(NSArray *)selectedFriends;

@end
@interface AMFriendsViewController : UIViewController<UISearchBarDelegate>
{
    IBOutlet UISearchBar *searchBar1;
    IBOutlet UIScrollView *scrollView;
    NSInteger yValueCount;
    NSInteger xValueCount;
    NSMutableArray *selectedFriends;
    NSArray *friendsArray;
    NSMutableArray *friendsDataArray; //With username
    IBOutlet UILabel *selectedFriendsLable;
    BOOL isControllerDismissed;
    NSMutableArray *finalFriendArray;
}
@property(nonatomic,strong)id<AMFriendsViewControllerDelegate> delegate;
@end
