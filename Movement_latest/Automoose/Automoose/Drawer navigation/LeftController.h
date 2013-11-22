//
//  LeftController.h
//  DDMenuController
//
//  Created by Devin Doty on 11/30/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MFSideMenu.h"
@class AMEventObject;
@class AMPlaceObject;
@interface LeftController : UIViewController<UISearchBarDelegate,NSURLConnectionDelegate,UISearchDisplayDelegate>
{
    NSInteger selectedRow;
    UIButton *createButton;
    UIImageView *addImage;
    UILabel *createEventLabel;
    UIView *overlayView;
    UISegmentedControl *searchTypeSegControl;
    
    NSArray *placesData;
    NSArray *friendsData;
    NSArray *eventsData;
    NSMutableArray *finalData;
    BOOL placeSearchDone;
    BOOL friendsSearchDone;
    BOOL eventsSearchDone;
    BOOL isSearchingHasBegun;
    NSOperationQueue *queue;
    
    NSMutableData *responseData;
    
    //For caching
    NSMutableArray *personDetails;
    NSMutableArray *placeDetails;
    AMPlaceObject *selectedPlaceObj;
}
@property (nonatomic, assign) MFSideMenu *sideMenu;
@property(nonatomic,strong) UISearchBar *searchBar1;
@property(nonatomic,strong)UISearchDisplayController *searchDisplayController1;
@property(nonatomic,strong) UITableView *tableView;

-(IBAction)segmentedControlValueChanged:(UISegmentedControl *)segmentedControl;
-(void)tappedonGridCellWithIndex:(int )index;

@end
