//
//  RestKitBridge.m
//  Proto1
//
//  Created by Rich Randall on 10/5/14.
//  Copyright (c) 2014 Rich Randall. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RestKitBridge.h"

@implementation RestKitBridge

+(RKRoute *)createRouteWithType:(Class)className
                    pathPattern:(NSString *)pattern
                         method: (RKRequestMethod) method
{
    return [RKRoute routeWithClass:className pathPattern:pattern method: method];
}

@end