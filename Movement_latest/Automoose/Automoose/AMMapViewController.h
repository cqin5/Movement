//
//  AMMapViewController.h
//  Automoose
//
//  Created by Srinivas on 12/15/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@protocol MapViewControllerDelegate <NSObject>
-(void)showMapView;
-(void)inviteeStatusFromEventLocation:(NSInteger )indexofUser withStatus:(NSString *)status;

@end

@interface AMMapViewController : UIViewController<MKMapViewDelegate, CLLocationManagerDelegate,MapViewControllerDelegate>
{
    IBOutlet MKMapView *mapView;
    
}
-(void)setMapViewtoPointEventLocation:(NSArray *)locationDetails;

@property(nonatomic,assign)id<MapViewControllerDelegate> delegate;

@end
