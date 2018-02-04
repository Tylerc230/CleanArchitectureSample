//
//  UIPlayground.h
//  UIPlayground
//
//  Created by Tyler Casselman on 11/30/17.
//  Copyright © 2017 Tyler Casselman. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for UIPlayground.
FOUNDATION_EXPORT double UIPlaygroundVersionNumber;

//! Project version string for UIPlayground.
FOUNDATION_EXPORT const unsigned char UIPlaygroundVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <UIPlayground/PublicHeader.h>
NSString *tryCatch( void(^tryBlock)() );

