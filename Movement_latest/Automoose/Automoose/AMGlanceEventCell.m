//
//  AMGlanceEventCell.m
//  Automoose
//
//  Created by Srinivas on 20/06/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import "AMGlanceEventCell.h"

@implementation AMGlanceEventCell
@synthesize eventImageview,userImageview,actionLabel,eventNameLabel,eventTimeLabel,moreButton,eventImageButton;
@synthesize userProfileButton,eventDetailsButton;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        CGFloat height;
        height = kScreenheight-44-20;
            
        eventImageview = [[PFImageView alloc]initWithFrame:CGRectMake(0, 0, 320, height)];
        eventImageview.backgroundColor = [UIColor clearColor];
        eventImageview.clipsToBounds = YES;
        eventImageview.contentMode = UIViewContentModeTop;
        [self.contentView addSubview:eventImageview];
        
        eventImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        eventImageButton.frame = CGRectMake(0, 0, 320, height - 115);
        [self.contentView addSubview:eventImageButton];
        
        UIView *backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, height-115, 320, 115)];
        backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"info.png"]];
        [self.contentView addSubview:backgroundView];
        
        userImageview = [[PFImageView alloc]initWithFrame:CGRectMake(10, 12, 35, 35)];
        userImageview.backgroundColor = [UIColor clearColor];
        [backgroundView addSubview:userImageview];
        
        actionLabel = [[UILabel alloc]initWithFrame:CGRectMake(53, 18, 182, 21)];
        actionLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.5];
        actionLabel.backgroundColor = [UIColor clearColor];
        actionLabel.textColor = [UIColor colorWithRed:47.0/255.0 green:47.0/255.0 blue:47.0/255.0 alpha:1.0];
        [backgroundView addSubview:actionLabel];
        
        eventNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 54, 290, 28)];
        eventNameLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:20];
        eventNameLabel.backgroundColor = [UIColor clearColor];
        [backgroundView addSubview:eventNameLabel];
        
        eventTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 83, 222, 21)];
        eventTimeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.5];
        eventTimeLabel.backgroundColor = [UIColor clearColor];
        eventTimeLabel.textColor = [UIColor colorWithRed:47.0/255.0 green:47.0/255.0 blue:47.0/255.0 alpha:1.0];
        [backgroundView addSubview:eventTimeLabel];
        
        moreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        moreButton.frame = CGRectMake(265, 70, 45, 35);
        [moreButton setBackgroundImage:[UIImage imageNamed:@"morebutton.png"] forState:UIControlStateNormal];
        [moreButton setBackgroundImage:[UIImage imageNamed:@"morebutton-t.png"] forState:UIControlStateHighlighted];
//        [backgroundView addSubview:moreButton];
        
        userProfileButton = [UIButton buttonWithType:UIButtonTypeCustom];
        userProfileButton.frame = userImageview.frame;
        [backgroundView addSubview:userProfileButton];
        
        eventDetailsButton = [UIButton buttonWithType:UIButtonTypeCustom];
        eventDetailsButton.frame = CGRectMake(10, 54, 290, 49);
        [backgroundView addSubview:eventDetailsButton];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier])
	{
		self.target = self;
		self.accessoryType = UITableViewCellAccessoryNone;
    }
    return self;
}
-(void)layoutSubviews{
    [super layoutSubviews];
//    actionLabel.font = [UIFont fontWithName:@"Helvetica Neue Light" size:12.5];
//    eventNameLabel.font = [UIFont fontWithName:@"Helvetica Neue Light" size:20];
//    eventTimeLabel.font = [UIFont fontWithName:@"Helvetica Neue Light" size:40];
//    


}
@end
