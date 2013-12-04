//
//  NowRingFiller.m
//  Automoose
//
//  Created by Srinivas on 17/04/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import "NowRingFiller.h"
#import "AMUtility.h"
#import <QuartzCore/QuartzCore.h>

@implementation NowRingFiller


-(BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // start of your application:didFinishLaunchingWithOptions // ...
    // The rest of your application:didFinishLaunchingWithOptions method// ...
}



- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Create a white ring that fills the entire frame and is 2 points wide.
    // Its frame is inset 1 point to fit for the 2 point stroke width
    CGFloat radius = MIN(rect.size.width,rect.size.height)/2;
    CGFloat inset  = 1;
    CAShapeLayer *ring = [CAShapeLayer layer];
    ring.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, inset, inset)
                                           cornerRadius:radius-inset].CGPath;
    
    ring.fillColor   = [UIColor whiteColor].CGColor;
//    ring.strokeColor = [UIColor whiteColor].CGColor;
    ring.lineWidth   = 2;
    
    // Create a white pie-chart-like shape inside the white ring (above).
    // The outside of the shape should be inside the ring, therefore the
    // frame needs to be inset radius/2 (for its outside to be on
    // the outside of the ring) + 2 (to be 2 points in).
//    CAShapeLayer *pieShape = [CAShapeLayer layer];
//    inset = radius/2 + 2; // The inset is updated here
//    pieShape.path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, inset, inset)
//                                               cornerRadius:radius-inset].CGPath;
//    pieShape.fillColor   = [UIColor greenColor].CGColor;
//    pieShape.strokeColor = [UIColor greenColor].CGColor;
//    pieShape.lineWidth   = (radius-inset)*2;
    
    // Add sublayers
    // NOTE: the following code is used in a UIView subclass (thus self is a view)
    // If you instead chose to use this code in a view controller you should instead
    // use self.view.layer to access the view of your view controller.
    [self.layer addSublayer:ring];
//    [self.layer addSublayer:pieShape];
    
    
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
//    CGContextAddEllipseInRect(ctx, rect);
//    
//    CGContextAddEllipseInRect(ctx,
//                              CGRectMake(
//                                         rect.origin.x +15,
//                                         rect.origin.y+15 ,
//                                         rect.size.width - 30,
//                                         rect.size.height - 30));
//    
//    CGContextSetFillColor(ctx, CGColorGetComponents([[AMUtility getColorwithRed:53 green:107 blue:210] CGColor]));
//    CGContextEOFillPath(ctx);

//    CGContextRef context = UIGraphicsGetCurrentContext();
//    
//    CGContextSetLineWidth(context, 2.0);
//    
//    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
//    



    

    
}


@end
