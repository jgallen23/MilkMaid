//
//  SearchWindowController.m
//  SimpleRTM
//
//  Created by Gregamel on 2/12/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "SearchWindowController.h"


@implementation SearchWindowController

@synthesize searchString;

-(void)searchClicked:(id)sender {
	searchString = [searchField stringValue];
	[searchField setStringValue:@""];	
	[NSApp endSheet:[self window] returnCode:1];
}

-(void)cancelClicked:(id)sender {
	[NSApp endSheet:[self window] returnCode:0];
}

@end
