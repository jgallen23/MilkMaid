//
//  MilkMaidWindowController.h
//  MilkMaid
//
//  Created by Gregamel on 2/28/10.
//  Copyright 2010 JGA. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EVRZRtmApi.h"
#import <BWToolkitFramework/BWToolkitFramework.h>
#import "RTMHelper.h"
#import "YRKSpinningProgressIndicator.h"
#import "SingleInputWindowController.h"
#import "MultiAddWindowController.h"
#import "ComboInputWindowController.h"

@interface MilkMaidWindowController : NSWindowController {
	SingleInputWindowController *singleInputWindowController;
	MultiAddWindowController *multiAddWindowController;
	ComboInputWindowController *comboInputWindowController;
	EVRZRtmApi *rtmController;
	NSMutableArray *lists;
	NSDictionary *currentList;
	NSString *currentSearch;
	NSMutableArray *tasks;
	NSString *timeline;
	IBOutlet BWTransparentPopUpButton *listPopUp;
	IBOutlet BWTransparentTableView *taskTable;
	IBOutlet BWTransparentScrollView *taskScroll;
	NSImage *priority1Image;
	NSImage *priority2Image;
	NSImage *priority3Image;
	NSMutableArray *tagList;
	NSString *globalTaskAttributes;
	
	IBOutlet YRKSpinningProgressIndicator *progress;
}
-(IBAction)listSelected:(id)sender;
-(IBAction)menuAddTask:(id)sender;

-(IBAction)closeSheet:(id)sender;
-(IBAction)menuRefresh:(id)sender;
-(IBAction)menuShowLists:(id)sender;
-(IBAction)menuPriority:(id)sender;
-(IBAction)menuDueDate:(id)sender;
-(IBAction)menuPostponeTask:(id)sender;
-(IBAction)menuDeleteTask:(id)sender;
-(IBAction)menuSearch:(id)sender;
-(IBAction)menuMultiAdd:(id)sender;
-(IBAction)menuRenameTask:(id)sender;
-(IBAction)menuSetTagsTask:(id)sender;
-(IBAction)menuSetDueTask:(id)sender;
-(IBAction)menuJumpToTag:(id)sender;
@end
