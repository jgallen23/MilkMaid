//
//  SimpleRTMAppDelegate.h
//  SimpleRTM
//
//  Created by Gregamel on 1/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EVRZRtmApi.h"
#import <BWToolkitFramework/BWToolkitFramework.h>
#import "RTMHelper.h"
#import "YRKSpinningProgressIndicator.h"

@interface SimpleRTMAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource> {
    NSWindow *window;
	NSPanel *addTaskPanel;
	EVRZRtmApi *rtmController;
	NSMutableArray *lists;
	NSDictionary *currentList;
	NSMutableArray *tasks;
	IBOutlet BWTransparentPopUpButton *listPopUp;
	IBOutlet BWTransparentTableView *taskTable;
	IBOutlet NSTextField *addTaskField;
	IBOutlet YRKSpinningProgressIndicator *progress;
	
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSPanel *addTaskPanel;
@property (assign) IBOutlet YRKSpinningProgressIndicator *progress;
-(IBAction)listSelected:(id)sender;
-(IBAction)showAddTask:(id)sender;
-(IBAction)addTaskClicked:(id)sender;
-(IBAction)closeSheet:(id)sender;
-(IBAction)refresh:(id)sender;
-(IBAction)showLists:(id)sender;
-(IBAction)setTaskPriority:(id)sender;
-(IBAction)setTaskDueDate:(id)sender;
-(IBAction)menuPostponeTask:(id)sender;
@end
