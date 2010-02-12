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
#import "AddTaskWindowController.h"
#import "SearchWindowController.h"

@interface SimpleRTMAppDelegate : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource> {
    NSWindow *window;
	AddTaskWindowController *addTaskWindowController;
	SearchWindowController *searchWindowController;
	EVRZRtmApi *rtmController;
	NSMutableArray *lists;
	NSDictionary *currentList;
	NSString *currentSearch;
	NSMutableArray *tasks;
	IBOutlet BWTransparentPopUpButton *listPopUp;
	IBOutlet BWTransparentTableView *taskTable;

	IBOutlet YRKSpinningProgressIndicator *progress;
	
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet YRKSpinningProgressIndicator *progress;
-(IBAction)listSelected:(id)sender;
-(IBAction)showAddTask:(id)sender;

-(IBAction)closeSheet:(id)sender;
-(IBAction)refresh:(id)sender;
-(IBAction)showLists:(id)sender;
-(IBAction)menuPriority:(id)sender;
-(IBAction)menuDueDate:(id)sender;
-(IBAction)menuPostponeTask:(id)sender;
-(IBAction)menuDeleteTask:(id)sender;
-(IBAction)menuSearch:(id)sender;
@end
