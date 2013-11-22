//
//  AMSearchController.h
//  Automoose
//
//  Created by Srinivas on 12/2/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AMEventObject;
@class AMPlaceObject;
@interface AMSearchController : UIViewController<UISearchBarDelegate,NSURLConnectionDelegate>
{
    IBOutlet UISearchBar *searchBar1;
    IBOutlet UISegmentedControl *segmentControl;
    
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
-(IBAction)segmentedControlValueChanged:(UISegmentedControl *)segmentedControl;
-(void)tappedonGridCellWithIndex:(int )index;
@end
