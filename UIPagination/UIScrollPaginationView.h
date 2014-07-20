//
//  UIScrollPaginationView.h
//
//  Copyright (c) 2014 com. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UIReusableView;
@class UIScrollPaginationView;

@protocol UIScrollPaginationViewDataSource <NSObject>

- (NSInteger)numberOfItemsInPagingView:(UIScrollPaginationView *)thePagingView;

- (id)pagingView:(UIScrollPaginationView *)thePagingView reusableViewForPageIndex:(NSUInteger)thePageIndex;

@end

@protocol UIScrollPaginationViewDelegate <UIScrollViewDelegate>

@optional
/**
 * Returns the selected page index the paging view should display.
 */
- (NSUInteger)pagingViewSelectedPageIndex:(UIScrollPaginationView *)thePagingView;

@end

@interface UIScrollPaginationView : UIScrollView

@property (nonatomic, assign) NSUInteger numberOfItems;
@property (nonatomic, readonly, strong) NSMutableDictionary *reusableViews;
@property (nonatomic, assign) id<UIScrollPaginationViewDataSource> dataSource;
@property (nonatomic, assign) id<UIScrollPaginationViewDelegate> delegate;
@property (nonatomic, assign) BOOL needsReloadData;
@property (nonatomic, assign) NSUInteger selectedPageIndex;
@property (nonatomic, readonly, assign) UIView<UIReusableView> *selectedPage;
@property (nonatomic, assign, getter = isIgnoreInputsForSelection) BOOL ignoreInputsForSelection;
@property (nonatomic, assign, getter = isReusableViewsEnabled) BOOL reusableViewsEnabled;


- (UIViewController *)dequeueReusableViewControllerWithIdentifier:(NSString *)theIdentifier;

- (UIView<UIReusableView> *)dequeueReusableViewWithIdentifier:(NSString *)theIdentifier;

- (void)setSelectedPageIndex:(NSUInteger)theSelectedPageIndex animated:(BOOL)theAnimated;

- (NSUInteger)indexOfVisiblePage:(UIView<UIReusableView> *)thePage;
- (UIView<UIReusableView> *)visiblePageAtIndex:(NSUInteger)theInteger;

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)theToInterfaceOrientation duration:(NSTimeInterval)theDuration;
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)theInterfaceOrientation duration:(NSTimeInterval)theDuration;

@end

