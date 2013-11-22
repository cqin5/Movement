//
//  AMEventImageViewer.m
//  Automoose
//
//  Created by Srinivas on 26/06/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import "AMEventImageViewer.h"

@interface AMEventImageViewer ()

@end

@implementation AMEventImageViewer
@synthesize imageview;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    imageview = [[PFImageView alloc]initWithFrame:CGRectMake(0, 0, 320, kScreenHeight)];
    
    [self.view addSubview:imageview];
//    imageview.image = [UIImage imageNamed:@"defaultpublic.png"];
    self.navigationController.navigationBarHidden = YES;
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [doneButton setTitle:@"Done" forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(doneButtonAction) forControlEvents:UIControlEventTouchUpInside];
//    imageview.autoresizesSubviews = YES;
//    imageview.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    doneButton.frame = CGRectMake(220, 10, 100, 30);

    imageview.contentMode = UIViewContentModeScaleAspectFit;

    NSLog(@"%f",kScreenHeight);
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden=NO;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
-(void)doneButtonAction{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)loadImage:(UIImage *)image{
    imageview.image =image;
        NSLog(@"%f %f %f %f %f",imageview.image.size.height,imageview.frame.origin.x,imageview.frame.origin.x,imageview.frame.size.width,imageview.frame.size.height);
}
//Load image in background
-(void)loadFileinBackground:(PFFile *)file{
    imageview.file = file;
    [imageview loadInBackground];
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self doneButtonAction];
}
@end
