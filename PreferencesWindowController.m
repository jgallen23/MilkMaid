//
//  PreferencesWindowController.m
//  MilkMaid
//
//  Created by Gregamel on 3/10/10.
//  Copyright 2010 JGA. All rights reserved.
//

#import "PreferencesWindowController.h"


@implementation PreferencesWindowController

-(void)awakeFromNib {
	[menuBarIconButton setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"menuicon"]];
	[dockIconButton setState:[[NSUserDefaults standardUserDefaults] boolForKey:@"dockicon"]];
}

-(void)menuBarClicked:(id)sender {
	if ([sender state] == NSOnState) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"menuicon"];
	} else {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"menuicon"];
	}

}

-(void)dockIconClicked:(id)sender {
	if ([sender state] == NSOnState) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"dockicon"];
	} else {
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"dockicon"];
	}
}

-(void)windowWillClose:(NSNotification *)notification {
	[[NSApp delegate] updateMenuIcon];
}

@end
