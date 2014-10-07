//
//  RestKitBridge.h
//  Proto1
//
//  Created by Rich Randall on 10/5/14.
//  Copyright (c) 2014 Rich Randall. All rights reserved.
//

#ifndef Proto1_RestKitBridge_h
#define Proto1_RestKitBridge_h

#import "RestKit/RestKit.h"

@interface RestKitBridge : NSObject

+(RKRoute *)createRouteWithType:(Class)className
                    pathPattern:(NSString *)pattern
                         method:(RKRequestMethod) method;

@end
#endif
