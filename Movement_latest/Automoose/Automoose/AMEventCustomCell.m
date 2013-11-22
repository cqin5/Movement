//
//  AMEventCustomCell.m
//  Automoose
//
//  Created by Srinivas on 14/12/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import "AMEventCustomCell.h"
#import <QuartzCore/QuartzCore.h>
#import "AMUtility.h"
@implementation AMEventCustomCell
@synthesize displayNameLabel;
@synthesize actionLabel;
@synthesize locationLabel;
@synthesize nameoftheEventLabel;
@synthesize photoView;
@synthesize timeLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}
- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithFrame:frame reuseIdentifier:reuseIdentifier])
	{
		self.target = self;
		self.accessoryType = UITableViewCellAccessoryNone;
        
        displayNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		displayNameLabel.backgroundColor = [UIColor clearColor];
		displayNameLabel.opaque = NO;
		displayNameLabel.textColor = [AMUtility getColorwithRed:47 green:47 blue:47];
		displayNameLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18];
        
		[self.contentView addSubview:displayNameLabel];
        
        actionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		actionLabel.backgroundColor = [UIColor clearColor];
		actionLabel.opaque = NO;
		actionLabel.textColor = [UIColor blackColor];
		actionLabel.font = [UIFont systemFontOfSize:12.0];
        actionLabel.textColor = [AMUtility getColorwithRed:141 green:141 blue:141];
		actionLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18];
		[self.contentView addSubview:actionLabel];
        
        locationLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		locationLabel.backgroundColor = [UIColor clearColor];
		locationLabel.opaque = NO;
		locationLabel.textColor = [UIColor blackColor];
		locationLabel.font = [UIFont systemFontOfSize:12.0];
        locationLabel.numberOfLines = 1;
        locationLabel.textColor = [AMUtility getColorwithRed:141 green:141 blue:141];
		locationLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18];
		[self.contentView addSubview:locationLabel];
        
        nameoftheEventLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		nameoftheEventLabel.backgroundColor = [UIColor clearColor];
		nameoftheEventLabel.opaque = NO;
		nameoftheEventLabel.textColor = [UIColor blackColor];
		nameoftheEventLabel.font = [UIFont systemFontOfSize:12.0];
        nameoftheEventLabel.textColor = [AMUtility getColorwithRed:47 green:47 blue:47];
		nameoftheEventLabel.font = [UIFont fontWithName:@"MyriadPro-Regular" size:24];
		[self.contentView addSubview:nameoftheEventLabel];
        
        timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
		timeLabel.backgroundColor = [UIColor clearColor];
		timeLabel.opaque = NO;
		timeLabel.textColor = [UIColor blackColor];
		timeLabel.font = [UIFont systemFontOfSize:12.0];
		[self.contentView addSubview:timeLabel];
        
        backgroundImageview = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"timelineframe.png"]];
        [self.contentView addSubview:backgroundImageview];
        photoView = [[PFImageView alloc]initWithFrame:CGRectZero];
        photoView.backgroundColor = [UIColor clearColor];
        photoView.image = [UIImage imageNamed:@"person_icon.png"];
        [photoView setClipsToBounds:YES];
        [backgroundImageview addSubview:photoView];
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect contentRect = [self.contentView bounds];
    
    CGRect frame = CGRectMake(contentRect.origin.x+6, contentRect.origin.y+15, 71, 71);
    photoView.frame = CGRectMake(1, 1, 69, 69);
    backgroundImageview.frame = frame;
    
    frame = CGRectMake(contentRect.origin.x+88, contentRect.origin.y+8, contentRect.size.width -88, 30);
    displayNameLabel.frame = frame;
    
    frame = CGRectMake(contentRect.origin.x+88, contentRect.origin.y+25, contentRect.size.width-88, 30);
    actionLabel.frame = frame;
    
    frame = CGRectMake(contentRect.origin.x+88, contentRect.origin.y+47, contentRect.size.width-88, 30);
    nameoftheEventLabel.frame = frame;
    
    frame = CGRectMake(contentRect.origin.x+88, contentRect.origin.y+50+17, contentRect.size.width - 88, 30);
    locationLabel.frame = frame;
    
    frame = CGRectMake(contentRect.size.width - 35, contentRect.origin.y+5, contentRect.size.width, 30);
    timeLabel.frame = frame;
    
}
@end
