//
//  PECropViewController.h
//  PhotoCropEditor
//
//  Created by kishikawa katsumi on 2013/05/19.
//  Copyright (c) 2013 kishikawa katsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MBProgressHUD;
@interface PECropViewController : UIViewController
{
        MBProgressHUD *hud;
}
@property (nonatomic) id delegate;
@property (nonatomic) UIImage *image;
@property(nonatomic,strong)NSString *typeOfController;
-(void)setRatio;
@end

@protocol PECropViewControllerDelegate <NSObject>

- (void)cropViewController:(PECropViewController *)controller didFinishCroppingImage:(UIImage *)croppedImage;
- (void)cropViewControllerDidCancel:(PECropViewController *)controller;


@end
