//
//  AMPlaceViewController.h
//  Automoose
//
//  Created by Srinivas on 12/2/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
@class AMPlaceObject;
@interface AMPlaceViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    IBOutlet UITableView *placeDetailsTableview;
    NSOperationQueue *queue;
    UIScrollView *photosScrollView;
    IBOutlet UIImageView *placeIcon,*ratingImage;
    IBOutlet UILabel *nameofthePlace;
    IBOutlet MKMapView *placeMapview;
    UILabel *addressLabel;
    UILabel *callLabel;
   IBOutlet UILabel *contactNumber;
    UIImageView *callImage;
    IBOutlet UIView *mapContainer,*phoneNumberContainer;
    IBOutlet UILabel *cateoryLabel;
}
@property(nonatomic,strong)AMPlaceObject *placeObj;
@end
