//
//  MultiAddWindowController.h
//  MilkMaid
//
//  Created by Gregamel on 2/16/10.
//  Copyright 2010 JGA. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MultiAddWindowController : NSWindowController {
	IBOutlet NSScrollView *scrollTextView;
	IBOutlet NSTextField *globalTextField;
	NSArray *tasks;
	NSString *globalAttributes; 
}
@property (assign) NSArray *tasks;
@property (assign) NSString *globalAttributes;
-(IBAction)addClicked:(id)sender;
-(IBAction)cancelClicked:(id)sender;
@end
