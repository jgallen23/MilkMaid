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
	windowsVisible = YES;
	NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
	statusItem = [[statusBar statusItemWithLength:NSVariableStatusItemLength] retain];
	
	NSImage *statusIcon = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_menu" ofType:@"png"]];
	
	[statusItem setImage:statusIcon];
	[statusItem setToolTip:@"MilkMaid"];
	[statusItem setHighlightMode:YES];
	
	[statusItem setAction:@selector(toggleWindows)];
	[statusItem setTarget:self];
		
	windowControllers = [[NSMutableArray alloc] init];
	[self openNewWindow:nil];

}

-(void)toggleWindows {
	for (MilkMaidWindowController *wc in windowControllers) {
		if (windowsVisible) {
			NSLog(@"hide");
			[wc.window orderOut:self];
		} else {
			[wc.window orderFrontRegardless];
		}

	}
	windowsVisible = !windowsVisible;
}

-(void)openNewWindow:(id)sender {
	MilkMaidWindowController *windowController = [[MilkMaidWindowController alloc] initWithWindowNibName:@"MilkMaid"];
	NSWindow *window = windowController.window;
	if ([windowControllers count] == 0) {
		[windowController setLoadLastList:YES];
	}
	[windowControllers addObject:windowController];
	[[NSApplication sharedApplication] addWindowsItem:window title:window.title filename:NO];
	[windowController showWindow:self];
}

@end
