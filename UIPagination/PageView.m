//
//  PageView.m
//
//  Copyright (c) 2014 com. All rights reserved.
//

#import "PageView.h"
#import "Common.h"

#define KTagLabel 2000

@interface PageView ()
@end

@implementation PageView
@synthesize title = _title;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

-(void)didMoveToSuperview{
    [super didMoveToSuperview];
    
    //ADD UILabel programatically
    if (!_title) {
        self.title = [[UILabel alloc] init];
        _title.textAlignment = NSTextAlignmentCenter;
        _title.height = 80.0f;
        _title.width = 100.0f;
        
        CGFloat top = (self.height/2) - (_title.height/2);
        CGFloat left = (self.width/2) - (_title.width/2);
        _title.top = top;
        _title.left = left;
        [_title setText:@"TEST"];
        [_title setFont:OpenSansSemiBold];
        [self addSubview:_title];
    }
}

- (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

- (void)prepareForReuse {
    [_title setText:@"Reused view"];
}

@end
