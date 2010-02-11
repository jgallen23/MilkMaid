//
//  AddTaskWindowController.m
//  SimpleRTM
//
//  Created by Greg Allen on 2/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AddTaskWindowController.h"


@implementation AddTaskWindowController

@synthesize task;

-(void)addTaskClicked:(id)sender {
	task = [addTaskField stringValue];
	[addTaskField setStringValue:@""];
	[NSApp endSheet:[self window] returnCode:1];
	
}

-(void)cancelClicked:(id)sender {
	[NSApp endSheet:[self window] returnCode:0];
}

@end
