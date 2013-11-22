//
//  PeopleCollectionViewController.m
//  Automoose
//
//  Created by Srinivas on 10/06/13.
//  Copyright (c) 2013 Srinivas. All rights reserved.
//

#import "PeopleCollectionViewController.h"
#import "AMConstants.h"
#import "AMUtility.h"
#import "AMProfileViewer.h"
@interface PeopleCollectionViewController ()

@end

@implementation PeopleCollectionViewController
@synthesize gridview,peopleArray;

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
    gridview.gridViewDelegate = self;
    self.navigationController.navigationBarHidden = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(void)loadFollowers{
    self.title = @"People you follow";
    peopleArray   = [[NSMutableArray alloc]init];

    PFQuery *query = [PFQuery queryWithClassName:kActivity];
    [query whereKey:kFromUser equalTo:[[PFUser currentUser] objectId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects,NSError *error){
       if(!error&& objects)
       {
           NSMutableArray *objectIdArray= [[NSMutableArray alloc]init];
           for (int i=0; i<objects.count; i++) {
               PFObject *entry = [objects objectAtIndex:i];
               [objectIdArray addObject:[entry objectForKey:kToUser]];
           }
           PFQuery *finalQuery =[PFUser query];
           [finalQuery whereKey:kObjectId containedIn:objectIdArray];
           [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *users,NSError *err){
               if(!err)
               {
                   [peopleArray removeAllObjects];
                   peopleArray = [NSMutableArray arrayWithArray:users];
                   [self.gridview loadDatawithUsers:peopleArray];
               }
               else
               {
                [AMUtility showAlertwithTitle:@"Error" andMessage:error.localizedDescription];
               }
               [indicator stopAnimating];
           }];
       }
        else
        {
            [indicator stopAnimating];
            [AMUtility showAlertwithTitle:@"Error" andMessage:error.localizedDescription];
        }
    }];
     self.navigationController.navigationBarHidden = NO;
}
-(void)loadFollowing{
    self.title = @"People following you";
     peopleArray   = [[NSMutableArray alloc]init];
    
    PFQuery *query = [PFQuery queryWithClassName:kActivity];
    [query whereKey:kToUser equalTo:[[PFUser currentUser] objectId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects,NSError *error){
        if(!error&& objects)
        {
            NSMutableArray *objectIdArray= [[NSMutableArray alloc]init];
            for (int i=0; i<objects.count; i++) {
                PFObject *entry = [objects objectAtIndex:i];
                [objectIdArray addObject:[entry objectForKey:kFromUser]];
            }
            PFQuery *finalQuery =[PFUser query];
            [finalQuery whereKey:kObjectId containedIn:objectIdArray];
            [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *users,NSError *err){
                if(!err)
                {
                    [peopleArray removeAllObjects];
                    peopleArray = [NSMutableArray arrayWithArray:users];
                    [self.gridview loadDatawithUsers:peopleArray];
                }
                else
                {
                    [AMUtility showAlertwithTitle:@"Error" andMessage:error.localizedDescription];
                }
                [indicator stopAnimating];
            }];
        }
        else
        {
            [indicator stopAnimating];
            [AMUtility showAlertwithTitle:@"Error" andMessage:error.localizedDescription];
        }
    }];
 self.navigationController.navigationBarHidden = NO;
    
}
-(void)loadFollowersofUser:(PFUser *)user
{
    self.title = @"Following";
    peopleArray   = [[NSMutableArray alloc]init];
    PFQuery *query = [PFQuery queryWithClassName:kActivity];
    [query whereKey:kFromUser equalTo:[user objectId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects,NSError *error){
        if(!error&& objects)
        {
            NSMutableArray *objectIdArray= [[NSMutableArray alloc]init];
            for (int i=0; i<objects.count; i++) {
                PFObject *entry = [objects objectAtIndex:i];
                [objectIdArray addObject:[entry objectForKey:kToUser]];
            }
            PFQuery *finalQuery =[PFUser query];
            [finalQuery whereKey:kObjectId containedIn:objectIdArray];
            [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *users,NSError *err){
                if(!err)
                {
                    [peopleArray removeAllObjects];
                    peopleArray = [NSMutableArray arrayWithArray:users];
                    [self.gridview loadDatawithUsers:peopleArray];
                }
                else
                {
                    [AMUtility showAlertwithTitle:@"Error" andMessage:error.localizedDescription];
                }
                [indicator stopAnimating];
            }];
        }
        else
        {
            [indicator stopAnimating];
            [AMUtility showAlertwithTitle:@"Error" andMessage:error.localizedDescription];
        }
    }];
}

-(void)loadFollowingofUser:(PFUser *)user
{
    self.title = @"Followers";
    peopleArray   = [[NSMutableArray alloc]init];
    PFQuery *query = [PFQuery queryWithClassName:kActivity];
    [query whereKey:kToUser equalTo:[user objectId]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects,NSError *error){
        if(!error&& objects)
        {
            NSMutableArray *objectIdArray= [[NSMutableArray alloc]init];
            for (int i=0; i<objects.count; i++) {
                PFObject *entry = [objects objectAtIndex:i];
                [objectIdArray addObject:[entry objectForKey:kFromUser]];
            }
            PFQuery *finalQuery =[PFUser query];
            [finalQuery whereKey:kObjectId containedIn:objectIdArray];
            [finalQuery findObjectsInBackgroundWithBlock:^(NSArray *users,NSError *err){
                if(!err)
                {
                    [peopleArray removeAllObjects];
                    peopleArray = [NSMutableArray arrayWithArray:users];
                    [self.gridview loadDatawithUsers:peopleArray];
                }
                else
                {
                    [AMUtility showAlertwithTitle:@"Error" andMessage:error.localizedDescription];
                }
                [indicator stopAnimating];
            }];
        }
        else
        {
            [indicator stopAnimating];
            [AMUtility showAlertwithTitle:@"Error" andMessage:error.localizedDescription];
        }
    }];
}

-(void)tappedonGridCellWithIndex:(int )index
{
    AMProfileViewer *profileViewer = [[AMProfileViewer alloc]init];
    [self.navigationController pushViewController:profileViewer animated:YES];
    PFUser *user1 = [peopleArray objectAtIndex:index];
    [profileViewer showDetailsofUser:user1];
}

@end
