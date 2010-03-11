//
//  SimpleRTMAppDelegate.h
//  SimpleRTM
//
//  Created by Gregamel on 1/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PreferencesWindowController.h"

@class MilkMaidWindowController;

@interface MilkMaidAppDelegate : NSObject {
	NSMutableArray *windowControllers;
	PreferencesWindowController *prefsWindowController;
	NSStatusItem *statusItem;
	BOOL windowsVisible;
}

-(IBAction)openNewWindow:(id)sender;
-(void)updateMenuIcon;
-(IBAction)showPreferences:(id)sender;

@end
