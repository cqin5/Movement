//
//  AMRequestTableCell.m
//  Automoose
//
//  Created by Srinivas on 11/02/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import "AMRequestTableCell.h"

@implementation AMRequestTableCell
@synthesize profileImage,invitorName,eventName,staticLabel,segmentedControl;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        profileImage = [[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 50, 50)];
        invitorName = [[UILabel alloc]initWithFrame:CGRectMake(70, 10, 250, 20)];
        staticLabel = [[UILabel alloc]initWithFrame:CGRectMake(70, 30, 250, 20)];
        eventName = [[UILabel alloc]initWithFrame:CGRectMake(70, 48, 250, 60)];
        invitorName.font = [UIFont boldSystemFontOfSize:15];
        staticLabel.font = [UIFont systemFontOfSize:13.5];
        segmentedControl = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"Going",@"May be",@"Not Going",nil]];
        segmentedControl.frame = CGRectMake(10, 115, self.contentView.frame.size.width-20, 30);
        segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    [self.contentView addSubview:profileImage];
    [self.contentView addSubview:invitorName];
    [self.contentView addSubview:staticLabel];
    [self.contentView addSubview:eventName];
    [self.contentView addSubview:segmentedControl];
    
}

@end
