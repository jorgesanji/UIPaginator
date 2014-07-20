//
//  Common.h
//  UIPagination
//
//  Copyright (c) 2014 Jorge Sanmartin. All rights reserved.
//

#define OpenSansRegular [UIFont fontWithName:@"OpenSans" size:17]
#define OpenSansSemiBold [UIFont fontWithName:@"OpenSans-Semibold" size:17]
#define OpenSansLight [UIFont fontWithName:@"OpenSansLight" size:17]

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define KHeight 90.0f

typedef enum {
    viewSelection,
    viewControllerSelection
} TypeSelected;