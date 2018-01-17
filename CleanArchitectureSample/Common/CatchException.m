//
//  CatchException.m
//  CleanArchitectureSample
//
//  Created by Tyler Casselman on 1/9/18.
//  Copyright © 2018 Tyler Casselman. All rights reserved.
//

#import <Foundation/Foundation.h>
NSString *tryCatch( void(^tryBlock)(void) )
{
    NSString *error = nil;
    @try {
        tryBlock();
    }
    @catch (NSException *exception) {
        error = [NSString stringWithFormat:@"%@ %@", exception.name, exception.reason];
        NSLog(error);
    }
    @finally {
        return error;
    }
}
