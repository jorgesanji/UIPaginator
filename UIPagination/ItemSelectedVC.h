//
//  ItemSelectedVC.h
//  UIPagination
//
//  Copyright (c) 2014 Jorge Sanmartin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Common.h"

@class UIPaginator;
@interface ItemSelectedVC : UIViewController

@property(nonatomic ,strong)UIPaginator *paginator;
@property(nonatomic)TypeSelected type;


@end
