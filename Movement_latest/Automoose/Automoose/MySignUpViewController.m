

#import "MySignUpViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "AMConstants.h"
#import "TPKeyboardAvoidingScrollView.h"
#import "AMUtility.h"

@interface MySignUpViewController ()
{
 UIImageView *glareImageview;
    TPKeyboardAvoidingScrollView *scrollview;
    UITextField *flagTextfield;
}
@property (nonatomic, strong) UIImageView *fieldsBackground;
@end

@implementation MySignUpViewController

@synthesize fieldsBackground;
-(id)init{
    self.modalTransitionStyle= UIModalTransitionStyleCrossDissolve;
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(isPhone568)
        [self.signUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bgLogin-568h.png"]]];
    else
        [self.signUpView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"bgLogin.png"]]];
    [self.signUpView setLogo:[[UIImageView alloc] initWithImage:nil]];
    
    [self.signUpView.dismissButton setImage:nil forState:UIControlStateNormal];
    [self.signUpView.dismissButton setImage:nil forState:UIControlStateHighlighted];
    [self.signUpView.dismissButton setTitle:@"Cancel" forState:UIControlStateNormal];
    
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateNormal];
    [self.signUpView.signUpButton setBackgroundImage:nil forState:UIControlStateHighlighted];
    [self.signUpView.signUpButton setTitle:@"Finish and sign in" forState:UIControlStateNormal];
    [self.signUpView.signUpButton setTitle:@"" forState:UIControlStateHighlighted];
    
//    [self setFieldsBackground:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"signup-panel.png"]]];
    
    
//    [self.signUpView insertSubview:fieldsBackground atIndex:1];

//     self.signUpView.usernameField.background = [UIImage imageNamed:@"input.png"];
//    self.signUpView.passwordField.background = [UIImage imageNamed:@"input.png"];
//    self.signUpView.emailField.background = [UIImage imageNamed:@"input.png"];
    
//    self.signUpView.usernameField.delegate =self;
//    self.signUpView.passwordField.delegate =self;
//    self.signUpView.emailField.delegate =self;
    
    self.signUpView.usernameField.textColor = [AMUtility getColorwithRed:216 green:216 blue:216];
    self.signUpView.passwordField.textColor = [AMUtility getColorwithRed:216 green:216 blue:216];
    self.signUpView.emailField.textColor = [AMUtility getColorwithRed:216 green:216 blue:216];
    
    self.signUpView.usernameField.font =[UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    self.signUpView.passwordField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    self.signUpView.emailField.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
    
    self.signUpView.usernameField.returnKeyType = UIReturnKeyNext;
    self.signUpView.emailField.returnKeyType =  UIReturnKeyNext;
    self.signUpView.passwordField.returnKeyType =UIReturnKeyJoin ;
    
    self.signUpView.usernameField.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    self.signUpView.passwordField.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    self.signUpView.emailField.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    self.signUpView.usernameField.layer.cornerRadius = 5.0f;
    self.signUpView.passwordField.layer.cornerRadius = 5.0f;
    self.signUpView.emailField.layer.cornerRadius = 5.0f;
    
//    scrollview = [[TPKeyboardAvoidingScrollView alloc]init];
//    [self.signUpView insertSubview:scrollview atIndex:1];
//    [scrollview addSubview:fieldsBackground];
//    [scrollview addSubview:self.signUpView.usernameField];
    
    UILabel *logoText = [[UILabel alloc]initWithFrame:CGRectMake(55, 70, 247, 36)];
    logoText.text = @"Movement";
    logoText.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:50];
    logoText.backgroundColor = [UIColor clearColor];
    logoText.textColor = [UIColor whiteColor];
    [self.signUpView addSubview:logoText];
    if(!isPhone568)
        logoText.frame = CGRectMake(55, 30, 247, 36);
    
    UILabel *singUpText = [[UILabel alloc]initWithFrame:CGRectMake(55,120, 210, 36)];
    singUpText.text = @"Sign up";
    singUpText.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:30];
    singUpText.backgroundColor = [UIColor clearColor];
    singUpText.textColor = [UIColor whiteColor];
    singUpText.textAlignment = NSTextAlignmentCenter;
    [self.signUpView addSubview:singUpText];
    if(!isPhone568)
        singUpText.frame = CGRectMake(55, 80, 210, 36);
    
    self.signUpView.signUpButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    self.signUpView.dismissButton.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.2];
    
    [self.signUpView.signUpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.signUpView.dismissButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    [self.signUpView.signUpButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
    [self.signUpView.dismissButton.titleLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:17]];
    
    self.signUpView.signUpButton.layer.cornerRadius = 5.0f;
    self.signUpView.dismissButton.layer.cornerRadius = 5.0f;
}

- (void)viewDidLayoutSubviews {
  
//    scrollview.frame = fieldFrame;
    
    self.signUpView.usernameField.placeholder = @"Name";
    self.signUpView.emailField.placeholder = @"Email Address";
    self.signUpView.passwordField.placeholder = @"Password";
    if(isPhone568)
    {
        [self.signUpView.dismissButton setFrame:CGRectMake(37, 352+45, 247.0f, 36.0f)];
        [self.signUpView.signUpButton setFrame:CGRectMake(37, 352, 247.0f, 36.0f)];
        float yOffset = 0.0f;
        [self.signUpView.usernameField setFrame:CGRectMake(37,100+80.0f,247,36)];
        yOffset += 45;
        [self.signUpView.emailField setFrame:CGRectMake(37,100+80.0f+yOffset,247,36)];
        yOffset += 45;
        [self.signUpView.passwordField setFrame:CGRectMake(37,100+80.0f+yOffset,247,36)];
    }
    else
    {
        [self.signUpView.dismissButton setFrame:CGRectMake(37, 322+45, 247.0f, 36.0f)];
        [self.signUpView.signUpButton setFrame:CGRectMake(37, 322, 247.0f, 36.0f)];
        float yOffset = 0.0f;
        [self.signUpView.usernameField setFrame:CGRectMake(37,70+80.0f,247,36)];
        yOffset += 45;
        [self.signUpView.emailField setFrame:CGRectMake(37,70+80.0f+yOffset,247,36)];
        yOffset += 45;
        [self.signUpView.passwordField setFrame:CGRectMake(37,70+80.0f+yOffset,247,36)];
    }
    

    UIView *tempView1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 36)];
    UIView *tempView2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 36)];
    UIView *tempView3 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 10, 36)];
    
    self.signUpView.usernameField.leftView = tempView1;
    self.signUpView.usernameField.leftViewMode = UITextFieldViewModeAlways;
    
    self.signUpView.passwordField.leftView = tempView2;
    self.signUpView.passwordField.leftViewMode = UITextFieldViewModeAlways;
    
    self.signUpView.emailField.leftView = tempView3;
    self.signUpView.emailField.leftViewMode = UITextFieldViewModeAlways;
    self.signUpView.usernameField.textAlignment = NSTextAlignmentLeft;
    self.signUpView.emailField.textAlignment = NSTextAlignmentLeft;
    self.signUpView.passwordField.textAlignment = NSTextAlignmentLeft;
//    yOffset += fieldFrame.size.height;
//    
//    [self.signUpView.additionalField setFrame:CGRectMake(fieldFrame.origin.x+5.0f, 
//                                                         fieldFrame.origin.y+30.0f+yOffset, 
//                                                         fieldFrame.size.width-10.0f, 
//                                                         fieldFrame.size.height)];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    textField.background =nil;
    
    if(!isPhone568) {
        if(textField == self.signUpView.passwordField ) {
            CGRect frame = self.signUpView.frame;
            if(frame.origin.y == 20)
            {
                frame.origin.y = -25;
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.5];
                [UIView setAnimationDelay:0.0];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                self.signUpView.frame =  frame;
                [UIView commitAnimations];
            }
        }
    }
   
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    textField.background = nil;
    if(!isPhone568) {
        CGRect frame = self.signUpView.frame;
        if(frame.origin.y != 20) {
            frame.origin.y = 20;
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.5];
            [UIView setAnimationDelay:0.0];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            self.signUpView.frame =  frame;
            [UIView commitAnimations];
        }
    }
    
}
@end
