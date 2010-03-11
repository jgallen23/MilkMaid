//
//  RTMList.h
//  MilkMaid
//
//  Created by Gregamel on 3/11/10.
//  Copyright 2010 JGA. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RTMList : NSObject {
	NSString* title;
	NSString* type;
	NSDictionary* searchParams;
	NSDictionary* addParams;
}

@property (copy) NSString* title;
@property (copy) NSString* type;
@property (assign) NSDictionary* searchParams;
@property (assign) NSDictionary* addParams;
@end
