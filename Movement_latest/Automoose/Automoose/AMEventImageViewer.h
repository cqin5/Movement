//
//  AMEventImageViewer.h
//  Automoose
//
//  Created by Srinivas on 26/06/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMEventImageViewer : UIViewController
@property(nonatomic,strong)PFImageView *imageview;
-(void)loadImage:(UIImage *)image;
-(void)loadFileinBackground:(PFFile *)file;
@end
