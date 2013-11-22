//
//  AMRightViewCustomCell.m
//  Automoose
//
//  Created by Srinivas on 10/03/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import "AMRightViewCustomCell.h"

@implementation AMRightViewCustomCell
@synthesize eventName,eventTime,statusControl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        eventName = [[UILabel alloc] initWithFrame:CGRectZero];
		eventName.backgroundColor = [UIColor clearColor];
		eventName.opaque = NO;
		eventName.textColor = [UIColor whiteColor];
		eventName.font = [UIFont fontWithName:@"MyriadPro-Semibold" size:22];
		[self.contentView addSubview:eventName];
        
        eventTime = [[UILabel alloc] initWithFrame:CGRectZero];
		eventTime.backgroundColor = [UIColor clearColor];
		eventTime.opaque = NO;
		eventTime.textColor = [UIColor whiteColor];
		eventTime.font = [UIFont fontWithName:@"MyriadPro-Regular" size:18];
		[self.contentView addSubview:eventTime];
        
        
        NSArray *itemArray = [NSArray arrayWithObjects: @"Going", @"May be", @"Not going", nil];
        statusControl = [[UISegmentedControl alloc]initWithItems:itemArray];
//        statusControl.frame = CGRectMake(10, 5, 290, 30);
        statusControl.segmentedControlStyle =  UISegmentedControlStyleBar;
        statusControl.selectedSegmentIndex = 0;
//        [statusControl addTarget:self action:@selector(statusControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        UIImage *unselectedBackgroundImage = [[UIImage imageNamed:@"unselectedBg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [statusControl setBackgroundImage:unselectedBackgroundImage forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        UIImage *selectedBackgroundImage = [[UIImage imageNamed:@"selectedBg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [statusControl setBackgroundImage:selectedBackgroundImage forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        
        UIColor *buttonColor = [UIColor blackColor];
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    buttonColor,UITextAttributeTextColor,
                                    [UIFont fontWithName:@"HelveticaNeue-Light" size:13],UITextAttributeFont,
                                    nil];
        
        [statusControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
        
        UIImage *divider1 = [[UIImage imageNamed:@"right_selected_divider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [statusControl setDividerImage:divider1 forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
        
        UIImage *divider2 = [[UIImage imageNamed:@"left_selected_divider.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, 10, 10, 10)];
        [statusControl setDividerImage:divider2 forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        
        [statusControl setDividerImage:[UIImage imageNamed:@"unselectedDividerBg.png"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
        [self.contentView addSubview:statusControl];

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
    
    CGRect frame = CGRectMake(contentRect.origin.x+17, contentRect.origin.y+5, self.contentView.frame.size.width - 30, 30);
    eventName.frame = frame;
    
    frame = CGRectMake(contentRect.origin.x+17, contentRect.origin.y+8+21, self.contentView.frame.size.width - 20, 30);
    eventTime.frame = frame;
    
    frame = CGRectMake(10, contentRect.origin.y+8+21+35,  self.contentView.frame.size.width - 20, 30);
    statusControl.frame = frame;
}

@end
