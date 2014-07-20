//
//  UIReusableView.h
//
//  Copyright (c) 2014 com. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol UIReusableView <NSObject>

@property (nonatomic, readonly, copy) NSString *reuseIdentifier;

- (void)prepareForReuse;

@end
