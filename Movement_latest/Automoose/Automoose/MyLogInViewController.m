

#import "MyLogInViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AMConstants.h"
#import "AMUtility.h"
@interface MyLogInViewController ()
{
    UIImageView *glareImageview;
}
@property (nonatomic, strong) UIImageView *fieldsBackground;

@end

@implementation MyLogInViewController

@synthesize fieldsBackground;

- (void)viewDidLoad
{
    [super viewDidLoad];

    if(isPhone568)
        [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bgLogin-568h.png"]]];
    else
        [self.logInView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bgLogin.png"]]];
    
    [self.logInView setLogo:nil];
    
    self.logInView.signUpLabel.hidden = YES;
    
    [self.logInView.facebookButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.facebookButton setImage:nil forState:UIControlStateHighlighted];
    [self.logInView.facebookButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.logInView.facebookButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.facebookButton setTitle:@"Sign in with Facebook" forState:UIControlStateNormal];
//    [self.logInView.facebookButton setTitle:@"" forState:UIControlStateHighlighted];
    
    [self.logInView.signUpButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.signUpButton setImage:nil forState:UIControlStateHighlighted];
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.logInView.signUpButton setTitle:@"Sign up" forState:UIControlStateNormal];


   
    [self.logInView.logInButton setImage:nil forState:UIControlStateNormal];
    [self.logInView.logInButton setImage:nil forState:UIControlStateHighlighted];
    [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.logInView.logInButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.logInView.logInButton setTitle:@"Sign in" forState:UIControlStateNormal];

    self.logInView.externalLogInLabel.hidden = YES;

    self.logInView.usernameField.delegate = self;
    self.logInView.passwordField.delegate = self;
    
    self.logInView.usernameField.textColor = [AMUtility getColorwithRed:216 green:216 blue:216];
    self.logInView.passwordField.textColor = [AMUtility getColorwithRed:216 green:216 blue:216];

    self.logInView.usernameField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    self.logInView.passwordField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    
    self.logInView.usernameField.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    self.logInView.passwordField.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    self.logInView.usernameField.layer.cornerRadius = 5.0f;
    self.logInView.passwordField.layer.cornerRadius = 5.0f;
    
    [self.logInView.logInButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.logInView.signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.logInView.facebookButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [self.logInView.logInButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
    [self.logInView.signUpButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
    [self.logInView.facebookButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];


    self.logInView.facebookButton.layer.cornerRadius = 5.0f;
    
    UILabel *logoText = [[UILabel alloc]initWithFrame:CGRectMake(55, 110, 247, 36)];
    logoText.text = @"Movement";
    logoText.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:50];
    logoText.backgroundColor = [UIColor clearColor];
    logoText.textColor = [UIColor whiteColor];
    [self.logInView addSubview:logoText];
    if(!isPhone568)
        logoText.frame = CGRectMake(55, 80, 247, 36);
    
    self.logInView.logInButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.logInView.signUpButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.logInView.facebookButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    
}


- (void)viewDidLayoutSubviews {


    UIView *whiteView = [[UIView alloc]init];
    [whiteView setBackgroundColor:[UIColor whiteColor]];
    if(isPhone568)
    {
        [self.logInView.facebookButton setFrame:CGRectMake(37.0f, 180+130+45, 247.0f, 36.0f)];
        [self.logInView.signUpButton setFrame:CGRectMake(123+1+37, 180+130, 123, 36.0f)];
        self.logInView.logInButton.frame = CGRectMake(37,180+130, 123, 36);
        
        self.logInView.usernameField.frame = CGRectMake(37, 180, 247, 36);
        self.logInView.passwordField.frame = CGRectMake(37, 180+45, 247, 36);
        whiteView.frame = CGRectMake(37+123, 180+130, 1, 36);
    }
    else
    {
        [self.logInView.facebookButton setFrame:CGRectMake(37.0f, 150+130+45, 247.0f, 36.0f)];
        [self.logInView.signUpButton setFrame:CGRectMake(123+1+37, 150+130, 123, 36.0f)];
        self.logInView.logInButton.frame = CGRectMake(37,150+130, 123, 36);
        
        self.logInView.usernameField.frame = CGRectMake(37, 150, 247, 36);
        self.logInView.passwordField.frame = CGRectMake(37, 150+45, 247, 36);
        whiteView.frame = CGRectMake(37+123, 150+130, 1, 36);
    }
    [self.logInView addSubview:whiteView];

    UIView *tempView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 36)];
    UIView *tempView2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 36)];
    tempView1.backgroundColor = [UIColor clearColor];
    tempView2.backgroundColor = [UIColor clearColor];
    
    self.logInView.usernameField.textAlignment = NSTextAlignmentLeft;
    self.logInView.passwordField.textAlignment = NSTextAlignmentLeft;
    
    self.logInView.usernameField.leftView = tempView1;
    self.logInView.passwordField.leftView = tempView2;
    
    self.logInView.usernameField.leftViewMode = UITextFieldViewModeAlways;
    self.logInView.passwordField.leftViewMode = UITextFieldViewModeAlways;
    

    [self setMaskforHighlightedBackground:self.logInView.logInButton byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerTopLeft];
    [self setMaskforHighlightedBackground:self.logInView.signUpButton byRoundingCorners:UIRectCornerBottomRight | UIRectCornerTopRight];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
//    textField.background = [UIImage imageNamed:@"input-t.png"];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
//    textField.background = [UIImage imageNamed:@"input.png"];
}

-(void) setMaskforHighlightedBackground:(UIView*)view byRoundingCorners:(UIRectCorner)corners
{
    UIBezierPath* rounded = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(5.0, 5.0)];
    
    CAShapeLayer* shape = [[CAShapeLayer alloc] init];
    [shape setPath:rounded.CGPath];
    
    view.layer.mask = shape;
}

@end
