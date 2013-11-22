//
//  AMGridView.h
//  Automoose
//
//  Created by Srinivas on 12/11/12.
//  Copyright (c) 2012 Srinivas. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AMGridView;
@protocol AMGridViewDelegate <NSObject>
@optional
-(void)tappedonGridCellwithIndex:(int )index andGrid:(UIView*)selectedFriend;
-(void)tappedonGridCellWithIndex:(int )index;
-(void)detectedTouches;

-(void)imageDownloaded:(UIImage *)image withIndex:(NSInteger )index;
@end
@interface AMGridView : UIScrollView
{
    NSInteger yValueCount;
    NSInteger xValueCount;
    NSOperationQueue *queue;
    NSArray *receivedData;
    BOOL isIndexSaved;
    NSInteger firstPlaceIndex;
    NSMutableData *responseData;;
}
@property(nonatomic,strong)id<AMGridViewDelegate> gridViewDelegate;
- (id)initWithFrame:(CGRect)frame andWithData:(NSArray *)data;
-(id)initWithFrame:(CGRect)frame andWithPeopleData:(NSArray *)data;
- (id)initWithFrame:(CGRect)frame andWithPlaceData:(NSArray *)data;
- (void)setFrame:(CGRect)frame andWithData:(NSArray *)data;
-(void)setUpPeopleData:(NSArray *)data;
-(void)loadDatawithUsers:(NSArray *)users;
@end
