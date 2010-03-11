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

	[self registerDefaultSettings];
	[self updateMenuIcon];
	
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"dockicon"]) {
		ProcessSerialNumber psn = { 0, kCurrentProcess };
		TransformProcessType(&psn, kProcessTransformToForegroundApplication);
	}
		
	windowControllers = [[NSMutableArray alloc] init];
	[self openNewWindow:nil];

}

-(void)registerDefaultSettings {
	[[NSUserDefaults standardUserDefaults] registerDefaults:[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:1], @"menuicon", [NSNumber numberWithInt:1], @"dockicon", nil]];
}

-(void)updateMenuIcon {

	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"menuicon"] && !statusItem) {
		NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
		statusItem = [[statusBar statusItemWithLength:NSVariableStatusItemLength] retain];
		
		NSImage *statusIcon = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"icon_menu" ofType:@"png"]];
		
		[statusItem setImage:statusIcon];
		[statusItem setToolTip:@"MilkMaid"];
		[statusItem setHighlightMode:YES];
		
		[statusItem setAction:@selector(toggleWindows)];
		[statusItem setTarget:self];
	} else if (statusItem) {
		[statusItem release];
	}


}

-(void)toggleWindows {
	for (MilkMaidWindowController *wc in windowControllers) {
		if (windowsVisible) {
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

-(void)showPreferences:(id)sender {
	if (!prefsWindowController) {
		prefsWindowController = [[PreferencesWindowController alloc] initWithWindowNibName:@"Preferences"];
		[prefsWindowController showWindow:self];
	}
	[prefsWindowController.window orderFrontRegardless];
}

@end
