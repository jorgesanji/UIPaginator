//
//  UIScrollPaginationView.m
//
//  Copyright (c) 2014 com. All rights reserved.
//

#import "UIScrollPaginationView.h"
#import "UIPaginator.h"
#import "UIReusableView.h"

// Set to 1 to print debug statement while paging view is laying out subviews.
#define DEBUG_LAYOUT 0
#define needsReloadDataObservable @"needsReloadData"

@interface UIScrollPaginationView ()

@property (nonatomic, strong) NSMutableArray *visibleReusableViews;
@property (nonatomic, assign, getter = isReferencingSuperview) BOOL referencingSuperview;
@property (nonatomic, assign) NSUInteger selectedPageIndexBeforeRotation;

- (void)layoutSubviewsFromIndex:(NSUInteger)theFromIndex toIndex:(NSUInteger)theToIndex;

@end

@implementation UIScrollPaginationView

@synthesize reusableViews = _reusableViews;
@synthesize dataSource = _dataSource;
@synthesize needsReloadData = _needsReloadData;
@synthesize ignoreInputsForSelection = _ignoreInputsForSelection;

@synthesize numberOfItems = _numberOfItems;
@synthesize visibleReusableViews = _visibleReusableViews;
@synthesize referencingSuperview = _referencingSuperview;
@synthesize selectedPageIndexBeforeRotation = _selectedPageIndexBeforeRotation;
@synthesize reusableViewsEnabled = _reusableViewsEnabled;

- (id<UIScrollPaginationViewDelegate>)delegate {
    return (id<UIScrollPaginationViewDelegate>)[super delegate];
}

- (void)setDelegate:(id<UIScrollPaginationViewDelegate>)theDelegate {
    [super setDelegate:theDelegate];
}

- (id)initWithFrame:(CGRect)theFrame {
    self = [super initWithFrame:theFrame];
    if (self) {
        _reusableViews = [[NSMutableDictionary alloc] init];
        self.pagingEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.scrollsToTop = NO;
        self.needsReloadData = YES;
        self.reusableViewsEnabled = YES;
        self.visibleReusableViews = [[NSMutableArray alloc] init];
        [self addObserver:self forKeyPath:needsReloadDataObservable options:NSKeyValueObservingOptionNew context:NULL];
        [self setBackgroundColor:[UIColor clearColor]];
    }
    return self;
}

/**
 Retain UIViews when the uiview conforms reusable protocol
 @param:theSubview
 */

- (void)willRemoveSubview:(UIView *)theSubview {
    if ([theSubview conformsToProtocol:@protocol(UIReusableView)]) {
        [self.visibleReusableViews removeObject:theSubview];
        [self enqueueReusableView:(UIView<UIReusableView> *)theSubview];
    }
}

/**
 Set uiscrollview when UIPaginator is used like a parent view
 @param:theNewSuperview
 */

- (void)willMoveToSuperview:(UIView *)theNewSuperview {
    if ([theNewSuperview isKindOfClass:[UIPaginator class]]) {
        self.referencingSuperview = YES;
        self.clipsToBounds = NO;
    } else {
        self.referencingSuperview = NO;
        self.clipsToBounds = YES;
    }
}

/**
 Retain UIViewController in parent container
 @param:UIViewController
 */

- (void)dealloc {
    if ([self respondsToSelector:@selector(removeObserver:forKeyPath:context:)]) {
        [self removeObserver:self forKeyPath:needsReloadDataObservable context:NULL];
    } else {
        [self removeObserver:self forKeyPath:needsReloadDataObservable];
    }
}

/**
 Draw pages
 @param:theFromIndex
 @param:theToIndex
 */

- (void)layoutSubviewsFromIndex:(NSUInteger)theFromIndex toIndex:(NSUInteger)theToIndex {
#if DEBUG_LAYOUT
    NSLog(@"Layout subviews from %u to %u", theFromIndex, theToIndex);
#endif
    
    if (self.contentSize.width <= 0.0f) { // No content!
        return;
    }
    
    CGFloat thePageWidth = CGRectGetWidth(self.frame);
    CGFloat thePageHeight = CGRectGetHeight(self.frame);
    
    // Remove reusable views that is out of sight.
    NSMutableArray *theVisibleReusableViewsToBeRemoved = [[NSMutableArray alloc] init];
    [self.visibleReusableViews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj conformsToProtocol:@protocol(UIReusableView)]) {
            UIView<UIReusableView> *theReusableView = (UIView<UIReusableView> *)obj;
            NSUInteger theIndex = (NSUInteger)floorf(CGRectGetMinX(theReusableView.frame) / thePageWidth);
            if ((theIndex < theFromIndex) || (theIndex > theToIndex)) {
                [theVisibleReusableViewsToBeRemoved addObject:theReusableView];
            }
        }
    }];
    
#if DEBUG_LAYOUT
    if ([theVisibleReusableViewsToBeRemoved count] > 0) {
        NSLog(@"Removing %u views", [theVisibleReusableViewsToBeRemoved count]);
    }
#endif
    
    [theVisibleReusableViewsToBeRemoved makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if ([self.visibleReusableViews count] == 0) { // At minimum must have a view for reference for the logic to work.
        CGFloat theMinX = theFromIndex * thePageWidth;
        CGRect theRect = CGRectMake(theMinX, 0.0f, thePageWidth, thePageHeight);
        
        UIView *theReusableView = nil;
        id class = [self.dataSource pagingView:self reusableViewForPageIndex:theFromIndex];
        if ([class isKindOfClass:[UIView class]]) {
            theReusableView = (UIView *)class;
        }else{
            UIViewController *theReusableViewController = (UIViewController *)class;
            theReusableView = theReusableViewController.view;
            //TODO:Save ViewController reference
            [self addChildViewController:theReusableViewController];
        }
        
        [theReusableView setFrame:theRect];
        if (!CGRectContainsRect(theRect, theReusableView.frame)) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:[NSString stringWithFormat:
                                                   @"theReusableView's frame (%@) must be contained by the given frame (%@)",
                                                   NSStringFromCGRect(theReusableView.frame),
                                                   NSStringFromCGRect(theRect)]
                                         userInfo:nil];
        }
        [self.visibleReusableViews insertObject:theReusableView atIndex:0];
        [self addSubview:theReusableView];
    }
    
    UIView<UIReusableView> *theLeftMostReusableView = [self.visibleReusableViews objectAtIndex:0];
    NSUInteger theLeftMostPageIndex = (NSUInteger)floorf(CGRectGetMinX(theLeftMostReusableView.frame) / thePageWidth);
    while ((theLeftMostPageIndex != 0) && (theLeftMostPageIndex > theFromIndex)) {
        theLeftMostPageIndex = MAX(0, theLeftMostPageIndex - 1);
        CGFloat theMinX = theLeftMostPageIndex * thePageWidth;
        CGRect theRect = CGRectMake(theMinX, 0.0f, thePageWidth, thePageHeight);
        
        UIView *theReusableView = nil;
        id class = [self.dataSource pagingView:self reusableViewForPageIndex:theLeftMostPageIndex];
        if ([class isKindOfClass:[UIView class]]) {
            theReusableView = (UIView *)class;
        }else{
            UIViewController *theReusableViewController = (UIViewController *)class;
            theReusableView = theReusableViewController.view;
            //TODO:Save ViewController reference
            [self addChildViewController:theReusableViewController];
        }

        [theReusableView setFrame:theRect];
        if (!CGRectContainsRect(theRect, theReusableView.frame)) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:[NSString stringWithFormat:
                                                   @"theReusableView's frame (%@) must be contained by the given frame (%@)",
                                                   NSStringFromCGRect(theReusableView.frame),
                                                   NSStringFromCGRect(theRect)]
                                         userInfo:nil];
        }
        [self.visibleReusableViews insertObject:theReusableView atIndex:0];
        [self addSubview:theReusableView];
    }
    
    UIView<UIReusableView> *theRightMostReusableView = [self.visibleReusableViews lastObject];
    NSUInteger theRightMostPageIndex = (NSUInteger)floorf(CGRectGetMinX(theRightMostReusableView.frame) / thePageWidth);
    while ((theRightMostPageIndex != MAX(0, self.numberOfItems - 1)) && (theRightMostPageIndex < theToIndex)) {
        theRightMostPageIndex = MIN(theRightMostPageIndex + 1, MAX(0, self.numberOfItems - 1));
        CGFloat theMinX = theRightMostPageIndex * thePageWidth;
        CGRect theRect = CGRectMake(theMinX, 0.0f, thePageWidth, thePageHeight);
        
        UIView *theReusableView = nil;
        id class = [self.dataSource pagingView:self reusableViewForPageIndex:theRightMostPageIndex];
        
        if ([class isKindOfClass:[UIView class]]) {
            theReusableView = (UIView *)class;
        }else{
            UIViewController *theReusableViewController = (UIViewController *)class;
            theReusableView = theReusableViewController.view;
            //TODO:Save ViewController reference
            [self addChildViewController:theReusableViewController];
        }
        [theReusableView setFrame:theRect];
        
        if (!CGRectContainsRect(theRect, theReusableView.frame)) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                           reason:[NSString stringWithFormat:
                                                   @"theReusableView's frame (%@) must be contained by the given frame (%@)",
                                                   NSStringFromCGRect(theReusableView.frame),
                                                   NSStringFromCGRect(theRect)]
                                         userInfo:nil];
        }
        [self.visibleReusableViews addObject:theReusableView];
        [self addSubview:theReusableView];
    }
}

/**
 Draw pages
 */
- (void)layoutSubviews {
    [super layoutSubviews];
    [self reloadDataIfNecessary];
    
    CGRect theVisibleBounds = self.bounds;
    if (self.isReferencingSuperview) {
        theVisibleBounds = [self convertRect:self.superview.bounds fromView:self.superview];
    }
    CGFloat theMinimumVisibleX = CGRectGetMinX(theVisibleBounds);
    CGFloat theMaximumVisibleX = CGRectGetMaxX(theVisibleBounds);
    
    CGFloat thePageWidth = CGRectGetWidth(self.frame);
    if (self.numberOfItems > 0) {
        
        NSInteger max = (NSInteger)floorf(theMinimumVisibleX / thePageWidth);
        NSUInteger theFromIndex = MAX(0, max);
        NSUInteger theToIndex = MIN((NSInteger)floorf((theMaximumVisibleX - 0.1f) / thePageWidth), MAX(0, self.numberOfItems - 1));
        [self layoutSubviewsFromIndex:theFromIndex toIndex:theToIndex];
    }
}

/**
 Reload pages retaining the las position in UISCrollView
 */

- (void)reloadDataIfNecessary {
    if (self.needsReloadData) {
        [self removeAllVisibleReusableViews];
        self.numberOfItems = [self.dataSource numberOfItemsInPagingView:self];
        CGSize theContentSize = self.frame.size;
        theContentSize.width *= self.numberOfItems;
        self.contentSize = theContentSize;
        if ([self.delegate conformsToProtocol:@protocol(UIScrollPaginationViewDelegate)] && [self.delegate respondsToSelector:@selector(pagingViewSelectedPageIndex:)]) {
            self.selectedPageIndex = [(id<UIScrollPaginationViewDelegate>)self.delegate pagingViewSelectedPageIndex:self];
        }
        self.needsReloadData = NO;
    }
}

/**
 Get index the current Page
 @return:get current index
 */

- (NSUInteger)selectedPageIndex {
    if ((!self.ignoreInputsForSelection) && ((self.isTracking) || (self.isDragging) || (self.isDecelerating))) {
        return NSNotFound;
    } else {
        return (NSUInteger)(self.contentOffset.x / CGRectGetWidth(self.frame));
    }
}

/**
 Get UIView in current index
 @param:selectedPage
 @return:UIView
 */

- (UIView<UIReusableView> *)selectedPage {
    NSUInteger theSelectedPageIndex = self.selectedPageIndex;
    if (theSelectedPageIndex != NSNotFound) {
        CGFloat theMinX = theSelectedPageIndex * CGRectGetWidth(self.frame);
        CGFloat theMaxX = theMinX + CGRectGetWidth(self.frame);
        for (UIView<UIReusableView> *theReusableView in self.visibleReusableViews) {
            CGPoint theCenter = theReusableView.center;
            if ((theMinX <= theCenter.x) && (theMaxX >= theCenter.y)) {
                return theReusableView;
            }
        }
    }
    return nil;
}

/**
 Move to a specific page
 @param:theSelectedPageIndex
 */

- (void)setSelectedPageIndex:(NSUInteger)theSelectedPageIndex {
    self.contentOffset = CGPointMake((theSelectedPageIndex * CGRectGetWidth(self.frame)), 0.0f);
}

/**
 Move to a specific page with animation
 @param:theSelectedPageIndex
 @param:theAnimated
 */

- (void)setSelectedPageIndex:(NSUInteger)theSelectedPageIndex animated:(BOOL)theAnimated {
    if (theAnimated) {
        [self scrollRectToVisible:CGRectMake((theSelectedPageIndex * CGRectGetWidth(self.frame)), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)) animated:YES];
    } else {
        [self setSelectedPageIndex:theSelectedPageIndex];
    }
}

/**
 Get index from a UIView
 @param:thePage
 @return:index
 */

- (NSUInteger)indexOfVisiblePage:(UIView<UIReusableView> *)thePage {
    if ([self.visibleReusableViews containsObject:thePage]) {
        return (NSUInteger)(thePage.frame.origin.x / CGRectGetWidth(self.frame));
    } else {
        return NSNotFound;
    }
}

/**
 Get UIView from a index
 @param:theInteger
 @return:UIView
 
 */

- (UIView<UIReusableView> *)visiblePageAtIndex:(NSUInteger)theInteger {
    __block UIView<UIReusableView> *thePageInQuery = nil;
    [self.visibleReusableViews enumerateObjectsUsingBlock:^(id theObject, NSUInteger theIndex, BOOL *theStop) {
        if ([self indexOfVisiblePage:(UIView<UIReusableView> *)theObject] == theInteger) {
            thePageInQuery = (UIView<UIReusableView> *)theObject;
            *theStop = YES;
        }
    }];
    return thePageInQuery;
}

/**
 Remove all views from UISCrollView
 */

- (void)removeAllVisibleReusableViews {
    
    if ([self.visibleReusableViews count] == 0) {
        return;
    }
    
    [self.visibleReusableViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    self.numberOfItems = 0;
}

/**
 Retain UIViewController in parent container
 @param:UIViewController
 */

-(void)addChildViewController:(UIViewController *)vc{
    NSArray *childViewController = [((UIViewController *)self.delegate) childViewControllers];
    BOOL add = ![childViewController containsObject:vc];
    if (add) {
        [((UIViewController *)self.delegate) addChildViewController:vc];
    }
}

#pragma mark - Enqueue/Dequeue method

/**
 Retain UIView when reusable view is activated
 @param:UIView
 */

- (void)enqueueReusableView:(UIView<UIReusableView> *)theReusableView {
    if (!self.isReusableViewsEnabled) {
        return;
    }
    NSMutableArray *theQueue = [self.reusableViews objectForKey:theReusableView.reuseIdentifier];
    if (theQueue == nil) {
        theQueue = [[NSMutableArray alloc] init];
        [self.reusableViews setObject:theQueue forKey:theReusableView.reuseIdentifier];
    }
    [theQueue insertObject:theReusableView atIndex:0];
}

/**
 Get UIView reusable with identifier
 @param:theIdentifier
 @return:reusable view
 */

- (UIView<UIReusableView> *)dequeueReusableViewWithIdentifier:(NSString *)theIdentifier {
    NSMutableArray *theQueue = [self.reusableViews objectForKey:theIdentifier];
    if (theQueue == nil) {
        return nil;
    }
    UIView<UIReusableView> *theLastReusableView = [theQueue lastObject];
    if (theLastReusableView == nil) {
        return nil;
    }
    [theQueue removeObject:theLastReusableView];
    [theLastReusableView prepareForReuse];
    return theLastReusableView;
}

/**
 Get UIViewController reusable with identifier
 @param:theIdentifier
 @return:reusable view
 */

- (UIViewController *)dequeueReusableViewControllerWithIdentifier:(NSString *)theIdentifier {
    NSMutableArray *theQueue = [self.reusableViews objectForKey:theIdentifier];
    if (theQueue == nil) {
        return nil;
    }
    UIView<UIReusableView> *theLastReusableView = [theQueue lastObject];
    if (theLastReusableView == nil) {
        return nil;
    }
    [theQueue removeObject:theLastReusableView];
    [theLastReusableView prepareForReuse];
    return [theLastReusableView parentViewController];
}


#pragma mark - Key-Value Observing methods

/**
 Observable needsReloadData when their value change then reload data UISCrollView
 @param:theKeyPath
 @param:id
 @param:theChange
 @param:theContext
 @return:reusable view
 */

- (void)observeValueForKeyPath:(NSString *)theKeyPath ofObject:(id)theObject change:(NSDictionary *)theChange context:(void *)theContext {
    if ([theObject isEqual:self]) {
        if ([theKeyPath isEqualToString:needsReloadDataObservable]) {
            NSKeyValueChange theKeyValueChangeKind = [[theChange objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
            switch (theKeyValueChangeKind) {
                case NSKeyValueChangeSetting: {
                    if (self.needsReloadData) {
                        [self setNeedsLayout];
                    }
                } break;
                default: {
                } break;
            }
        }
    }
}

#pragma mark - Rotation methods

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)theToInterfaceOrientation duration:(NSTimeInterval)theDuration {
    self.selectedPageIndexBeforeRotation = self.selectedPageIndex;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)theInterfaceOrientation duration:(NSTimeInterval)theDuration {
    self.needsReloadData = YES;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    self.selectedPageIndex = self.selectedPageIndexBeforeRotation;
    self.selectedPageIndexBeforeRotation = 0;
}


@end
