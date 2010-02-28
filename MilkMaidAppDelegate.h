//
//  SimpleRTMAppDelegate.h
//  SimpleRTM
//
//  Created by Gregamel on 1/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MilkMaidAppDelegate : NSObject {
    NSWindow *window;

	
}

@property (assign) IBOutlet NSWindow *window;

-(IBAction)openNewWindow:(id)sender;

@end
