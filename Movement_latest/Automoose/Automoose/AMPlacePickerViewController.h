//
//  AMPlacePickerViewController.h
//  Automoose
//
//  Created by Srinivas on 12/11/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AMGridView;
@class AMCreateEventController;
@protocol AMPlacePickerViewDelegate <NSObject>
-(void)placeSelectionDone:(NSArray *)selectedPlace;
@end
@interface AMPlacePickerViewController : UIViewController<AMPlacePickerViewDelegate,UISearchBarDelegate>
{
    NSMutableArray *placeData;
    AMGridView *gridView;
    NSMutableArray *selectedPlace;
    BOOL isControllerDismissed;
    NSMutableData *responseData;
    NSURLConnection *theConnection;
    NSOperationQueue *queue;
    IBOutlet UISearchBar *searchBar1;
    
}
@property(nonatomic,strong)id<AMPlacePickerViewDelegate> delegate;
@end
