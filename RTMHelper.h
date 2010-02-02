//
//  RTMHelper.h
//  SimpleRTM
//
//  Created by Greg Allen on 1/28/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RTMHelper : NSObject {

}

- (NSMutableArray*)getFlatTaskList:(NSDictionary*)rtmResponse;
@end
