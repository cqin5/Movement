//
//  AMFacebookLoginController.m
//  Automoose
//
//  Created by Srinivas on 04/04/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import "AMFacebookLoginController.h"
#import <QuartzCore/QuartzCore.h>
#import "AMConstants.h"

@interface AMFacebookLoginController ()
{
    UIImageView *glareImageview;
}
@property (nonatomic, strong) UIImageView *fieldsBackground;
@end

@implementation AMFacebookLoginController
@synthesize fieldsBackground;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(isPhone568)
        [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bgLogin-568h.jpg"]]];
    else
        [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bgLogin.jpg"]]];
    
    [self.logInView setLogo:nil];
    
    [self.logInView.facebookButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.facebookButton setImage:nil forState:UIControlStateHighlighted];
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"signin-facebook-t.png"] forState:UIControlStateHighlighted];
    [self.logInView.facebookButton setBackgroundImage:[UIImage imageNamed:@"signin-facebook.png"] forState:UIControlStateNormal];
    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateNormal];
    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateHighlighted];
    
    fieldsBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signin-panel.png"]];
    
    [self.logInView addSubview:self.fieldsBackground];
    [self.logInView sendSubviewToBack:self.fieldsBackground];
    
    glareImageview =[[ UIImageView alloc]init];
    glareImageview.image = [UIImage imageNamed:@"glare.png"];
    [self.logInView addSubview:glareImageview];
    glareImageview.userInteractionEnabled = NO;

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidLayoutSubviews {
    if(isPhone568)
        fieldsBackground.frame = CGRectMake(14, 100, 291, 351);
    else
        fieldsBackground.frame = CGRectMake(14, 55, 291, 351);
    CGRect frame = fieldsBackground.frame;
    [self.logInView.facebookButton setFrame:CGRectMake(35.0f, frame.origin.y+160, 247.0f, 36.0f)];
    glareImageview.frame = CGRectMake(0, fieldsBackground.frame.origin.y - 95, 320, 480);
}

@end
