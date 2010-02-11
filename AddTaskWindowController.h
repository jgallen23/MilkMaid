//
//  AddTaskWindowController.h
//  SimpleRTM
//
//  Created by Greg Allen on 2/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AddTaskWindowController : NSWindowController {
	IBOutlet NSTextField *addTaskField;
	NSString *task;
}
@property (assign) NSString *task;
-(IBAction)addTaskClicked:(id)sender;
-(IBAction)cancelClicked:(id)sender;
@end
