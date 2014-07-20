//
//  UIPaginator.m
//
//  Copyright (c) 2014 com. All rights reserved.
//

#import "UIPaginator.h"

@implementation UIPaginator

@synthesize edgeInsets = _edgeInsets;
@synthesize pagingView = _pagingView;

- (void)setFrame:(CGRect)theFrame {
    [super setFrame:theFrame];
    self.pagingView.frame = UIEdgeInsetsInsetRect(self.bounds, self.edgeInsets);
}

- (NSUInteger)selectedPageIndex {
    return self.pagingView.selectedPageIndex;
}

- (void)setSelectedPageIndex:(NSUInteger)theSelectedPageIndex {
    self.pagingView.selectedPageIndex = theSelectedPageIndex;
}

- (BOOL)ignoreInputsForSelection {
    return self.pagingView.ignoreInputsForSelection;
}

- (void)setIgnoreInputsForSelection:(BOOL)theIgnoreInputsForSelection {
    self.pagingView.ignoreInputsForSelection = theIgnoreInputsForSelection;
}

- (id)initWithFrame:(CGRect)theFrame insetsOfPageView:(UIEdgeInsets)theEdgeInsets {
    self = [super initWithFrame:theFrame];
    if (self) {
        self.edgeInsets = theEdgeInsets;
        CGRect frame = UIEdgeInsetsInsetRect(self.bounds, self.edgeInsets);
        self.pagingView = [[UIScrollPaginationView alloc] initWithFrame:frame];
        self.pagingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self setBackgroundColor:[UIColor clearColor]];
        [self addSubview:self.pagingView];

    }
    return self;
}

- (void)setPagingViewDataSource:(id<UIScrollPaginationViewDataSource>)thePagingViewDataSource delegate:(id<UIScrollPaginationViewDelegate>)thePagingViewDelegate {
    self.pagingView.dataSource = thePagingViewDataSource;
    self.pagingView.delegate = thePagingViewDelegate;
}

- (UIView *)hitTest:(CGPoint)thePoint withEvent:(UIEvent *)theEvent {
    if ([self pointInside:thePoint withEvent:theEvent]) {
        UIView *theView = [super hitTest:thePoint withEvent:theEvent];
        if (theView == self) {
            theView = self.pagingView;
        }
        return theView;
    } else {
        return nil;
    }
}

- (void)setPagingViewNeedsReloadData {
    self.pagingView.needsReloadData = YES;
}

- (void)HideOrShowContent{
    [_pagingView setHidden:![_pagingView isHidden]];
}

@end
