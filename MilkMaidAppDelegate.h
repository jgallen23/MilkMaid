//
//  SimpleRTMAppDelegate.h
//  SimpleRTM
//
//  Created by Gregamel on 1/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MilkMaidWindowController;

@interface MilkMaidAppDelegate : NSObject {
	NSMutableArray *windowControllers;
	NSStatusItem *statusItem;
	BOOL windowsVisible;
}

-(IBAction)openNewWindow:(id)sender;

@end
