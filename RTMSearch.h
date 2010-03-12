//
//  RTMList.h
//  MilkMaid
//
//  Created by Gregamel on 3/11/10.
//  Copyright 2010 JGA. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface RTMSearch : NSObject {
	NSString* title;
	NSString* searchType;
	NSDictionary* searchParams;
	NSDictionary* addParams;
	NSString* addAttributes;
}

@property (copy) NSString* title;
@property (copy) NSString* searchType;
@property (retain) NSDictionary* searchParams;
@property (retain) NSDictionary* addParams;
@property (copy) NSString* addAttributes;

-(id)initWithTitle:(NSString *)aTitle searchType:(NSString *)aType searchParams:(NSDictionary *)aSearchParams addParams:(NSDictionary *)aAddParams;
-(id)initWithTitle:(NSString *)aTitle searchType:(NSString *)aType searchParams:(NSDictionary *)aSearchParams addAttributes:(NSString *)aAddAttributes;
@end
