//
//  UIPaginator.h
//
//  Copyright (c) 2014 com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIScrollPaginationView.h"

@interface UIPaginator : UIView
@property (assign, nonatomic) UIEdgeInsets edgeInsets;
@property (strong, nonatomic) UIScrollPaginationView *pagingView;
@property (nonatomic, assign) NSUInteger selectedPageIndex;
@property (nonatomic, assign) BOOL ignoreInputsForSelection;

- (id)initWithFrame:(CGRect)theFrame insetsOfPageView:(UIEdgeInsets)theEdgeInsets;

- (void)setPagingViewDataSource:(id<UIScrollPaginationViewDataSource>)thePagingViewDataSource delegate:(id<UIScrollPaginationViewDelegate>)thePagingViewDelegate;

- (void)setPagingViewNeedsReloadData;

- (void)HideOrShowContent;
@end
