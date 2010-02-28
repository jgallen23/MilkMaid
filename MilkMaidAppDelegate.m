//
//  SimpleRTMAppDelegate.m
//  SimpleRTM
//
//  Created by Gregamel on 1/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "MilkMaidAppDelegate.h"
#import "MilkMaidWindowController.h"

@implementation MilkMaidAppDelegate


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	windowControllers = [[NSMutableArray alloc] init];
	[self openNewWindow:nil];

}

- (void)openNewWindow:(id)sender {
	MilkMaidWindowController *windowController = [[MilkMaidWindowController alloc] initWithWindowNibName:@"MilkMaid"];
	NSWindow *window = windowController.window;
	[windowControllers addObject:windowController];
	[[NSApplication sharedApplication] addWindowsItem:window title:window.title filename:NO];
	[windowController showWindow:self];
}

@end
