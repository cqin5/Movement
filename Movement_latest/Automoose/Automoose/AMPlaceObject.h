//
//  AMPlaceObject.h
//  Automoose
//
//  Created by Srinivas on 2/1/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AMPlaceObject : NSObject
@property(nonatomic,strong)NSString *nameofPlace;
@property(nonatomic,strong)NSString *address;
@property(nonatomic,strong)NSArray *photosArray;
@property(nonatomic,strong)NSArray *photoIdArray;
@property(nonatomic,strong)NSArray *review;
@property(nonatomic,strong)NSString *rating;
@property(nonatomic,assign)CGFloat latitude;
@property(nonatomic,assign)CGFloat longitude;
@property(nonatomic,strong)UIImage *placeIcon;
@property(nonatomic,strong)NSString *placeId;
@property(nonatomic,strong)NSString *iconUrl;
@property(nonatomic,assign)NSInteger isImageDownloaded;
@property(nonatomic,retain)NSString *phoneNumber,*mobileUrl,*categories;
@end
