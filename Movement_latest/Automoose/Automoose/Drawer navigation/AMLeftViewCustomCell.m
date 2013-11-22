//
//  AMLeftViewCustomCell.m
//  Automoose
//
//  Created by Lavanya on 09/03/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import "AMLeftViewCustomCell.h"

@implementation AMLeftViewCustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
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


- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)layoutSubviews{
    [super layoutSubviews];
    CGRect frame = self.textLabel.frame;
    frame.origin.y = frame.origin.y+2;
    self.textLabel.frame = frame;
}
@end
