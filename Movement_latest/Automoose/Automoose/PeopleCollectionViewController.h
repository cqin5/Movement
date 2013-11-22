//
//  PeopleCollectionViewController.h
//  Automoose
//
//  Created by Srinivas on 10/06/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>
//@class AMGridView;
#import "AMGridView.h"
@interface PeopleCollectionViewController : UIViewController<AMGridViewDelegate>
{
    IBOutlet UIActivityIndicatorView *indicator;
}
@property(nonatomic,strong)IBOutlet AMGridView *gridview;
@property(nonatomic,strong)NSMutableArray *peopleArray;
-(void)loadFollowers;
-(void)loadFollowing;

-(void)loadFollowingofUser:(PFUser *)user;
-(void)loadFollowersofUser:(PFUser *)user;
@end
