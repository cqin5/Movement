//
//  AMMapViewController.m
//  Automoose
//
//  Created by Srinivas on 12/15/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import "AMMapViewController.h"
#import "AMConstants.h"

@interface AMMapViewController ()
{
    BOOL firstLaunch;
    CLLocationManager *locationManager;
    CLLocationCoordinate2D currentCentre;
    BOOL isCoordinateisPlaceLocation;
}
@end

@implementation AMMapViewController
@synthesize delegate;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    mapView.delegate = self;
//    [mapView setShowsUserLocation:YES];
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    [locationManager setDistanceFilter:kCLDistanceFilterNone];
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    firstLaunch=YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapDetectedonMapView)];
    [mapView addGestureRecognizer:tapGesture];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)setMapViewtoPointEventLocation:(NSArray *)locationDetails
{
    NSMutableArray *toRemove = [NSMutableArray arrayWithCapacity:10];
    for (id annotation in mapView.annotations)
        if (annotation != mapView.userLocation)
            [toRemove addObject:annotation];
    [mapView removeAnnotations:toRemove];
    
    
    //Here we check what sort of co-ordinate is to be loaded on the mapview(place or person) using the key value we passed from now controller. 
    MKCoordinateRegion region;
    int placeIndex;
    for(int i=0; i< locationDetails.count; i++)
    {
        NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:[locationDetails objectAtIndex:i]];
        CLLocationCoordinate2D location = CLLocationCoordinate2DMake([[[dictionary objectForKey:kLocation]objectForKey:kLatitude]floatValue], [[[dictionary objectForKey:kLocation]objectForKey:kLongitude]floatValue]);
        if(location.latitude != 0 && location.longitude != 0)
        {
            MKPointAnnotation *annotationPoint = [[MKPointAnnotation alloc] init];
            
            if([[dictionary objectForKey:kType] isEqualToString:kPlaceType])
            {
                annotationPoint.title = [dictionary objectForKey:kName];
                isCoordinateisPlaceLocation = YES;
                placeIndex = i;
            }
            else
            {
                PFUser *user = [dictionary objectForKey:kFriends];
                [user fetchIfNeededInBackgroundWithBlock:^(PFObject *obj,NSError *err){
                    annotationPoint.title = [obj objectForKey:kDisplayName];
                }];
            }
            annotationPoint.coordinate = location;
            annotationPoint.accessibilityHint = [dictionary objectForKey:kType];
            [mapView addAnnotation:annotationPoint];
        }
        
    }

    [self zoomToFitMapAnnotations:mapView];
    
    [self trackUserArrivalwithData:locationDetails andPlaceIndex:placeIndex]; //Method to check if a user has already reached the venue or not.
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKPinAnnotationView *annView=[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
    annView.canShowCallout = YES;
    if(isCoordinateisPlaceLocation)
    {
        annView.image = [UIImage imageNamed:@"locationMap.png"];
        isCoordinateisPlaceLocation = NO;
    }
    else
        annView.image = [UIImage imageNamed:@"redbubble.png"];
	return annView;
}
-(void)tapDetectedonMapView
{
    [delegate showMapView];
}

-(void)trackUserArrivalwithData:(NSArray *)locationDetails  andPlaceIndex:(NSInteger)placeIndex{
    
   
    NSDictionary *locationData = [locationDetails objectAtIndex:placeIndex];
     CLLocationCoordinate2D eventLocation = CLLocationCoordinate2DMake([[[locationData objectForKey:kLocation]objectForKey:kLatitude]floatValue], [[[locationData objectForKey:kLocation]objectForKey:kLongitude]floatValue]);
    MKCoordinateRegion locationRegion = MKCoordinateRegionMakeWithDistance(eventLocation, 1000, 1000);
    CLLocationCoordinate2D center   = locationRegion.center;
    CLLocationCoordinate2D northWestCorner, southEastCorner;
    
    northWestCorner.latitude  = center.latitude  - (locationRegion.span.latitudeDelta  / 2.0);
    northWestCorner.longitude = center.longitude - (locationRegion.span.longitudeDelta / 2.0);
    southEastCorner.latitude  = center.latitude  + (locationRegion.span.latitudeDelta  / 2.0);
    southEastCorner.longitude = center.longitude + (locationRegion.span.longitudeDelta / 2.0);
    
    for(int i=0;i<locationDetails.count;i++){
        if(i!=placeIndex)
        {
            NSDictionary *userData = [locationDetails objectAtIndex:i];
            CLLocationCoordinate2D userLocation = CLLocationCoordinate2DMake([[[userData objectForKey:kLocation]objectForKey:kLatitude]floatValue], [[[userData objectForKey:kLocation]objectForKey:kLongitude]floatValue]);
//            NSDictionary *dictionary ;
            if (
                userLocation.latitude  >= northWestCorner.latitude &&
                userLocation.latitude  <= southEastCorner.latitude &&
                
                userLocation.longitude >= northWestCorner.longitude &&
                userLocation.longitude <= southEastCorner.longitude
                )
            {
                if([delegate respondsToSelector:@selector(inviteeStatusFromEventLocation:withStatus:)])
                {
                    [delegate inviteeStatusFromEventLocation:i withStatus:kArrived]; //If user has arrived, send the status to now controller.
                }
            }
            else
            {
                if([delegate respondsToSelector:@selector(inviteeStatusFromEventLocation:withStatus:)])
                {
                    [delegate inviteeStatusFromEventLocation:i withStatus:kEnroute];//If user has enroute, send the status to now controller.
                }
            }
        }
    }
}

-(void)zoomToFitMapAnnotations:(MKMapView*)mapView1 //Method to fit all the co-ordinated on the view available. 
{
    if([mapView.annotations count] == 0)
        return;
    
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(MKPointAnnotation* annotation in mapView.annotations)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, annotation.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, annotation.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, annotation.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, annotation.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
    
    region = [mapView regionThatFits:region];
    [mapView setRegion:region animated:YES];
}


-(void)setRegionwithData:(NSArray *)locationDetails {
    
    MKCoordinateRegion finalRegion;

    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.02);
    
    NSDictionary *location1 = [locationDetails objectAtIndex:0];
    NSDictionary *location2 = [locationDetails objectAtIndex:1];
    
    CLLocationCoordinate2D loc1,loc2;
    
    loc1 = CLLocationCoordinate2DMake([[[location1 objectForKey:kLocation]objectForKey:kLatitude]floatValue], [[[location1 objectForKey:kLocation]objectForKey:kLongitude]floatValue]);
    
    loc2 = CLLocationCoordinate2DMake([[[location2 objectForKey:kLocation]objectForKey:kLatitude]floatValue], [[[location2 objectForKey:kLocation]objectForKey:kLongitude]floatValue]);
    
    MKCoordinateRegion region1 = MKCoordinateRegionMake(loc1, span);
    MKCoordinateRegion region2 = MKCoordinateRegionMake(loc2, span);

    MKMapRect mapRect1 = [self mapRectForCoordinateRegion:region1];
    MKMapRect mapRect2 = [self mapRectForCoordinateRegion:region2];
    MKMapRect mapRectUnion = MKMapRectUnion(mapRect1, mapRect2);
    
    finalRegion = MKCoordinateRegionForMapRect(mapRectUnion);
    for(int i=2;i<locationDetails.count;i++){
        
         NSDictionary *location = [locationDetails objectAtIndex:i];
            loc1 = CLLocationCoordinate2DMake([[[location objectForKey:kLocation]objectForKey:kLatitude]floatValue], [[[location objectForKey:kLocation]objectForKey:kLongitude]floatValue]);
        MKCoordinateRegion region = MKCoordinateRegionMake(loc1, span);
        
        MKMapRect mapRect1 = [self mapRectForCoordinateRegion:finalRegion];
        MKMapRect mapRect2 = [self mapRectForCoordinateRegion:region];
        MKMapRect mapRectUnion = MKMapRectUnion(mapRect1, mapRect2);
        
        finalRegion = MKCoordinateRegionForMapRect(mapRectUnion);
    }
    
    [mapView setRegion:finalRegion animated:YES];
}
- (MKMapRect)mapRectForCoordinateRegion:(MKCoordinateRegion)coordinateRegion
{
    CLLocationCoordinate2D topLeftCoordinate =
    CLLocationCoordinate2DMake(coordinateRegion.center.latitude
                               + (coordinateRegion.span.latitudeDelta/2.0),
                               coordinateRegion.center.longitude
                               - (coordinateRegion.span.longitudeDelta/2.0));
    
    MKMapPoint topLeftMapPoint = MKMapPointForCoordinate(topLeftCoordinate);
    
    CLLocationCoordinate2D bottomRightCoordinate =
    CLLocationCoordinate2DMake(coordinateRegion.center.latitude
                               - (coordinateRegion.span.latitudeDelta/2.0),
                               coordinateRegion.center.longitude
                               + (coordinateRegion.span.longitudeDelta/2.0));
    
    MKMapPoint bottomRightMapPoint = MKMapPointForCoordinate(bottomRightCoordinate);
    
    MKMapRect mapRect = MKMapRectMake(topLeftMapPoint.x,
                                      topLeftMapPoint.y,
                                      fabs(bottomRightMapPoint.x-topLeftMapPoint.x),
                                      fabs(bottomRightMapPoint.y-topLeftMapPoint.y));
    
    return mapRect;
}

@end
