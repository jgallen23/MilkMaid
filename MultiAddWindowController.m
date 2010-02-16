//
//  MultiAddWindowController.m
//  MilkMaid
//
//  Created by Gregamel on 2/16/10.
//  Copyright 2010 JGA. All rights reserved.
//

#import "MultiAddWindowController.h"


@implementation MultiAddWindowController

@synthesize tasks;

-(void)addClicked:(id)sender {
	NSTextView *textView = [scrollTextView documentView];
	NSString *tasksString = [[textView textStorage] string];
	tasksString = [tasksString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	tasks = [tasksString componentsSeparatedByString:@"\n"];
	[tasks retain];
	[textView setString:@""];
	[NSApp endSheet:[self window] returnCode:1];
}

-(void)cancelClicked:(id)sender {
	[NSApp endSheet:[self window] returnCode:0];
}

@end
