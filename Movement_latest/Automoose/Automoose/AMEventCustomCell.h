//
//  AMEventCustomCell.h
//  Automoose
//
//  Created by Srinivas on 14/12/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMEventCustomCell : UITableViewCell
{
    UIImageView *backgroundImageview;
}
@property(strong,nonatomic)   PFImageView *photoView;
@property(strong,nonatomic)    UILabel *displayNameLabel;
@property(strong,nonatomic)   UILabel *actionLabel;
@property(strong,nonatomic)   UILabel *locationLabel;
@property(strong,nonatomic)   UILabel *nameoftheEventLabel;
@property(strong,nonatomic)  UILabel *timeLabel;


@end
