//
//  ItemSelectedVC.m
//  UIPagination
//
//  Copyright (c) 2014 Jorge Sanmartin. All rights reserved.
//

#import "ItemSelectedVC.h"
#import "UIPaginator.h"
#import "PageView.h"
#import "PageViewController.h"

@interface ItemSelectedVC () <UIScrollPaginationViewDataSource, UIScrollPaginationViewDelegate>
@end

#define KNumPages 4

@implementation ItemSelectedVC

@synthesize paginator = _paginator;
@synthesize type = _type;

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
    
    // Do any additional setup after loading the view from its nib.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"Item Selected";
    CGRect frame = self.view.bounds;
    CGFloat top = self.navigationController.navigationBar.frame.size.height;
    frame.origin.y = top;
    frame.size.height = frame.size.height - top;
    UIEdgeInsets edges = UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 20.0f);
    self.paginator = [[UIPaginator alloc] initWithFrame:frame insetsOfPageView:edges];
    _paginator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    //TODO: set Delegate and Datasource (UIScrollPaginationViewDataSource, UIScrollPaginationViewDelegate)
    
    [_paginator setPagingViewDataSource:self delegate:self];
    [_paginator setBackgroundColor:[UIColor clearColor]];
    [self.view addSubview:_paginator];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - PagingViewDataSource methods

- (NSInteger)numberOfItemsInPagingView:(UIScrollPaginationView *)thePagingView {
    return KNumPages;
}

- (id)pagingView:(UIScrollPaginationView *)thePagingView reusableViewForPageIndex:(NSUInteger)thePageIndex {
    static NSString *theIdentifier = @"PageView";
    
    id vc = nil;
    UIView *view = nil;
    
    if (_type == viewSelection) {
        //TODO:pagination with UIView then get reusable UIView
        vc = (PageView *)[thePagingView dequeueReusableViewWithIdentifier:theIdentifier];
        
        if (!vc) {
            vc = [[PageView alloc] init];
        }
        
        view = ((UIView *)vc);
    }else{
        //TODO:pagination with UIView then get reusable UIViewController
        vc =[thePagingView dequeueReusableViewControllerWithIdentifier:theIdentifier];
        
        if (!vc) {
            vc = [[PageViewController alloc] init];
        }
        
        view = ((UIViewController *)vc).view ;
    }
    
    if((thePageIndex % 2) == 0) {
        [view setBackgroundColor:[UIColor grayColor]];
    }else [view setBackgroundColor:[UIColor yellowColor]];
    
    return vc;
}

#pragma mark - UIScrollViewDelegate methods

- (void)scrollViewDidEndDragging:(UIScrollPaginationView *)thePagingView willDecelerate:(BOOL)theDecelerate{
    if (!theDecelerate) {
        NSLog(@"Selected Page Index: %lu", (unsigned long)thePagingView.selectedPageIndex);
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollPaginationView *)thePagingView {
    NSLog(@"Selected Page Index: %lu", (unsigned long)thePagingView.selectedPageIndex);
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollPaginationView *)thePagingView {
    NSLog(@"Selected Page Index: %lu", (unsigned long)thePagingView.selectedPageIndex);
}

@end
