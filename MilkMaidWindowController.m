//
//  MilkMaidWindowController.m
//  MilkMaid
//
//  Created by Gregamel on 2/28/10.
//  Copyright 2010 JGA. All rights reserved.
//

#import "MilkMaidWindowController.h"
#define TOKEN @"Token"
#define LAST_LIST @"LastList"

@implementation MilkMaidWindowController

-(void)awakeFromNib {
	[self.window setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces];
	NSString *apiKey = @"1734ba9431007c2242b6865a69940aa5";
	NSString *secret = @"72d1c12ffb26e759";
	
	priority1Image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"priority1" ofType:@"png"]];
	priority2Image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"priority2" ofType:@"png"]];
	priority3Image = [[NSImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"priority3" ofType:@"png"]];
	
	tagList = [[NSMutableArray alloc] init];
	
	[progress setForeColor:[NSColor whiteColor]];
	[progress startAnimation:nil];
	
	[taskTable setDelegate:self];
	[taskTable setDataSource:self];
	//return;
	rtmController = [[EVRZRtmApi alloc] initWithApiKey:apiKey andApiSecret:secret];

	[NSThread detachNewThreadSelector:@selector(checkToken) toTarget:self withObject:nil];
}

- (void)checkToken {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString * token = [[NSUserDefaults standardUserDefaults] objectForKey:TOKEN];
	
	if (token) {
		rtmController.token = token;
		NSDictionary *data = [rtmController dataByCallingMethod:@"rtm.auth.checkToken" andParameters:[[NSDictionary alloc]init] withToken:YES];
		if ([[data objectForKey:@"stat"] isEqualToString:@"ok"]) {
			timeline = [rtmController timeline];
			[timeline retain];
			[self performSelectorOnMainThread:@selector(getLists) withObject:nil waitUntilDone:NO];
		} else {
			[self getAuthToken];
		}
		
	} else {
		[self getAuthToken];
	}
	[pool release];
}

-(void)getAuthToken {
	NSString *frob = [rtmController frob];
	NSString *url = [rtmController authUrlForPerms:@"delete" withFrob:frob];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
	[self performSelectorOnMainThread:@selector(showAuthMessage:) withObject:frob waitUntilDone:NO];
	//[self showAuthMessage:frob];	
}

-(void)showAuthMessage:(NSString*)frob {
	NSAlert *alert = [[NSAlert alloc] init];
	[alert addButtonWithTitle:@"Done"];
	[alert addButtonWithTitle:@"Cancel"];
	[alert setMessageText:@"Accept Permissions"];
	[alert setInformativeText:@"A browser has been opened. Please press the \"OK, I'll allow it\" button then press the Done button below."];
	[alert setAlertStyle:NSWarningAlertStyle];
	
	if ([alert runModal] == NSAlertFirstButtonReturn) {
		NSString *token = [rtmController tokenWithFrob:frob];
		rtmController.token = token;
		[[NSUserDefaults standardUserDefaults] setObject:token forKey:TOKEN];
		[self performSelectorOnMainThread:@selector(getLists) withObject:nil waitUntilDone:NO];
		//[self doneLoading];
		
		
	}
	[alert release];
}

- (void)getLists {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDictionary *data = [rtmController dataByCallingMethod:@"rtm.lists.getList" andParameters:[[NSDictionary alloc]init] withToken:YES];
	lists = [[data objectForKey:@"lists"] objectForKey:@"list"];
	NSMutableArray *listToRemove = [[NSMutableArray alloc]init];
	for (NSDictionary *list in lists) {
		if ([[list objectForKey:@"archived"] intValue] == 0) {
			[listPopUp addItemWithTitle:[list objectForKey:@"name"]];
		} else {
			[listToRemove addObject:list];
		}
	}
	for (NSDictionary *list in listToRemove) {
		[lists removeObject:list];
	}
	[listToRemove release];
	[lists retain];
	//[data release];
	[pool release];
	[progress setHidden:YES];
	[self performSelectorOnMainThread:@selector(selectLast) withObject:nil waitUntilDone:NO];
}

-(void)selectLast {
	NSString *lastList = [[NSUserDefaults standardUserDefaults] objectForKey:LAST_LIST];
	if (lastList) {
		[listPopUp selectItemWithTitle:lastList];
		[self listSelected:nil];
	}
}

-(void)listSelected:(id)sender {
	
	NSInteger selectedIndex = [listPopUp indexOfSelectedItem];
	selectedIndex--;
	if (selectedIndex != -1 && [currentList objectForKey:@"id"] != [[lists objectAtIndex:selectedIndex] objectForKey:@"id"]) {
		currentList = [lists objectAtIndex:selectedIndex];
		[[NSUserDefaults standardUserDefaults] setObject:[currentList objectForKey:@"name"] forKey:LAST_LIST];
		[[taskScroll contentView] scrollToPoint:NSMakePoint(0, 0)];
		[NSThread detachNewThreadSelector:@selector(getTasks) toTarget:self withObject:nil];
		
		[currentList retain];
	}
}

-(void)getTasksFromCurrentList {
	[progress setHidden:NO];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDictionary *params = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[currentList objectForKey:@"id"], @"status:incomplete", nil] 
														 forKeys:[NSArray arrayWithObjects:@"list_id", @"filter", nil]];
	NSDictionary *data = [rtmController dataByCallingMethod:@"rtm.tasks.getList" andParameters:params withToken:YES];
	
	RTMHelper *rtmHelper = [[RTMHelper alloc] init];
	
	tasks = [rtmHelper getFlatTaskList:data];
	
	[self performSelectorOnMainThread:@selector(loadTaskData) withObject:nil waitUntilDone:NO];
	
	[tasks retain];
	[rtmHelper release];
	[pool release];
	[progress setHidden:YES];
}

-(void)searchTasks:(NSString*)searchString {
	[progress setHidden:NO];
	[listPopUp selectItemAtIndex:0];
	[[taskScroll contentView] scrollToPoint:NSMakePoint(0, 0)];
	NSString *newSearch = [NSString stringWithFormat:@"(%@) AND status:incomplete", searchString];
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDictionary *params = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:newSearch, nil] 
														 forKeys:[NSArray arrayWithObjects:@"filter", nil]];
	NSDictionary *data = [rtmController dataByCallingMethod:@"rtm.tasks.getList" andParameters:params withToken:YES];
	
	RTMHelper *rtmHelper = [[RTMHelper alloc] init];
	
	tasks = [rtmHelper getFlatTaskList:data];
	
	[self performSelectorOnMainThread:@selector(loadTaskData) withObject:nil waitUntilDone:NO];
	
	[tasks retain];
	[pool release];
	[progress setHidden:YES];
}

-(void)getTasks {
	if (currentList) {
		[self getTasksFromCurrentList];
	} else {
		[self searchTasks:currentSearch];
	}
	
}

-(void)menuRefresh:(id)sender {
	[NSThread detachNewThreadSelector:@selector(getTasks) toTarget:self withObject:nil];
}

-(void)loadTaskData {
	//NSLog(@"%@", tasks);
	[self.window setTitle:[NSString stringWithFormat:@"MilkMaid (%d)", [tasks count]]];
	if ([tasks count] != 0) {
		[[[NSApplication sharedApplication] dockTile] setBadgeLabel:[[NSNumber numberWithInt:[tasks count]] stringValue]];
	} else {
		[[[NSApplication sharedApplication] dockTile] setBadgeLabel:@""];
	}
	[taskTable reloadData];
	
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return [tasks count];
}



-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	//check type of cell
	
	id cell = [tableColumn dataCellForRow:row];
	//NSLog(@"%@", cell);
	if ([cell isMemberOfClass:[BWTransparentCheckboxCell class]]) {
		return [NSNumber numberWithInteger:NSOffState];
	} else if ([cell isMemberOfClass:[NSImageCell class]]) {
		NSDictionary *task = [tasks objectAtIndex:row];
		NSString *pri = [task objectForKey:@"priority"];
		if ([pri isEqualToString:@"1"]) {
			return priority1Image;
		} else if ([pri isEqualToString:@"2"]) {
			return priority2Image;
		} else if ([pri isEqualToString:@"3"]) {
			return priority3Image;
		} else {
			return nil;
		}
	} else {//if ([cell isMemberOfClass:[BWTransparentTableViewCell class]]) {
		NSDictionary *task = [tasks objectAtIndex:row];
		
		id due = [task objectForKey:@"due"];
		if ([due isKindOfClass:[NSDate class]]) {
			[cell setAlternate2Text:[due relativeFormattedDateOnly]];
			if ([due isPastDate] || [[NSDate date] isEqualToDate:due]) {
				[cell setBold:YES];
			} 
		} else {
			[cell setAlternate2Text:@""];
			[cell setBold:NO];
		}
		
		[cell setAlternateText:[[task objectForKey:@"tags"] componentsJoinedByString:@","]];
		[self addGlobalTags:[task objectForKey:@"tags"]];
		return [task objectForKey:@"name"];
	}
	
}

-(void)addGlobalTags:(NSArray*)tags {
	for (NSString *tag in tags) {
		if (![tagList containsObject:tag])
			[tagList addObject:tag];
	}
}



-(void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	NSDictionary *task = [tasks objectAtIndex:row];
	NSDictionary *params = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:timeline, [task objectForKey:@"list_id"], [task objectForKey:@"taskseries_id"], [task objectForKey:@"task_id"], nil] 
														 forKeys:[NSArray arrayWithObjects:@"timeline", @"list_id", @"taskseries_id", @"task_id", nil]];
	
	[tasks removeObject:task];
	[NSThread detachNewThreadSelector:@selector(completeTask:) toTarget:self withObject:params];
	[self loadTaskData];
}

-(void)completeTask:(NSDictionary *)taskInfo {
	[progress setHidden:NO];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDictionary *data = [rtmController dataByCallingMethod:@"rtm.tasks.complete" andParameters:taskInfo withToken:YES];
	[pool release];
	[progress setHidden:YES];
}

-(void)menuAddTask:(id)sender {
	
	if (!singleInputWindowController)
		singleInputWindowController = [[SingleInputWindowController alloc] initWithWindowNibName:@"SingleInput"];
	[singleInputWindowController setButtonText:@"Add Task"];
	NSWindow *sheet = [singleInputWindowController window];
	[NSApp beginSheet:sheet modalForWindow:self.window modalDelegate:self 
	   didEndSelector:@selector(closeAddTaskSheet:returnCode:contextInfo:) contextInfo:nil];
}

-(void)closeAddTaskSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[sheet orderOut:self];
	if (returnCode == 1) {
		NSString *task = [singleInputWindowController text];
		[NSThread detachNewThreadSelector:@selector(addTask:) toTarget:self withObject:task];
	}
	
}

-(void)addTask:(NSString*)task {
	[progress setHidden:NO];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:timeline, task, @"1", nil] 
																	   forKeys:[NSArray arrayWithObjects:@"timeline", @"name", @"parse", nil]];
	if (currentList) {
		[params setObject:[currentList objectForKey:@"id"] forKey:@"list_id"];
	}
	[rtmController dataByCallingMethod:@"rtm.tasks.add" andParameters:params withToken:YES];
	
	[self getTasks];
	[pool release];
	[progress setHidden:YES];
}

-(void)addTasks:(NSArray*)newTasksArray {
	[progress setHidden:NO];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSArray *newTasks = [newTasksArray objectAtIndex:0];
	NSString *globalAttributes = [newTasksArray objectAtIndex:1];
	for (NSString *t in newTasks) {
		NSString *taskName = [NSString stringWithFormat:@"%@ %@", t, globalAttributes];
		NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjects:[NSArray arrayWithObjects:timeline, taskName, @"1", nil] 
																		   forKeys:[NSArray arrayWithObjects:@"timeline", @"name", @"parse", nil]];
		if (currentList) {
			[params setObject:[currentList objectForKey:@"id"] forKey:@"list_id"];
		}
		[rtmController dataByCallingMethod:@"rtm.tasks.add" andParameters:params withToken:YES];
		
	}
	[self getTasks];
	[pool release];
	[progress setHidden:YES];
	
}

-(void)menuShowLists:(id)sender {
	[listPopUp performClick:self];
}

-(void)menuPriority:(id)sender {
	NSInteger rowIndex = [taskTable selectedRow];
	if (rowIndex == -1)
		return;
	NSDictionary *task = [tasks objectAtIndex:rowIndex];
	
	NSDictionary *params = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:timeline, [task objectForKey:@"list_id"], [task objectForKey:@"taskseries_id"], [task objectForKey:@"task_id"], [sender title], nil] 
														 forKeys:[NSArray arrayWithObjects:@"timeline", @"list_id", @"taskseries_id", @"task_id", @"priority", nil]];
	[NSThread detachNewThreadSelector:@selector(setPriority:) toTarget:self withObject:params];
}

-(void)setPriority:(NSDictionary*)params {
	[progress setHidden:NO];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[rtmController dataByCallingMethod:@"rtm.tasks.setPriority" andParameters:params withToken:YES];
	
	[self getTasks];
	[pool release];
	[progress setHidden:YES];
}

-(void)menuDueDate:(id)sender {
	NSInteger rowIndex = [taskTable selectedRow];
	if (rowIndex == -1)
		return;
	NSDictionary *task = [tasks objectAtIndex:rowIndex];
	
	NSDictionary *params = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:timeline, [task objectForKey:@"list_id"], [task objectForKey:@"taskseries_id"], [task objectForKey:@"task_id"], [sender title], @"1", nil] 
														 forKeys:[NSArray arrayWithObjects:@"timeline", @"list_id", @"taskseries_id", @"task_id", @"due", @"parse", nil]];
	[NSThread detachNewThreadSelector:@selector(setDueDate:) toTarget:self withObject:params];
}

-(void)setDueDate:(NSDictionary*)params {
	[progress setHidden:NO];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[rtmController dataByCallingMethod:@"rtm.tasks.setDueDate" andParameters:params withToken:YES];
	
	[self getTasks];
	[pool release];
	[progress setHidden:YES];
}

-(void)menuPostponeTask:(id)sender {
	NSInteger rowIndex = [taskTable selectedRow];
	if (rowIndex == -1)
		return;
	NSDictionary *task = [tasks objectAtIndex:rowIndex];
	
	NSDictionary *params = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:timeline, [task objectForKey:@"list_id"], [task objectForKey:@"taskseries_id"], [task objectForKey:@"task_id"], nil] 
														 forKeys:[NSArray arrayWithObjects:@"timeline", @"list_id", @"taskseries_id", @"task_id", nil]];
	[NSThread detachNewThreadSelector:@selector(postponeTask:) toTarget:self withObject:params];
}

-(void)postponeTask:(NSDictionary*)params {
	[progress setHidden:NO];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[rtmController dataByCallingMethod:@"rtm.tasks.postpone" andParameters:params withToken:YES];
	
	[self getTasks];
	[pool release];
	[progress setHidden:YES];
}

-(void)menuDeleteTask:(id)sender {
	NSInteger rowIndex = [taskTable selectedRow];
	if (rowIndex == -1)
		return;
	NSDictionary *task = [tasks objectAtIndex:rowIndex];
	
	NSDictionary *params = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:timeline, [task objectForKey:@"list_id"], [task objectForKey:@"taskseries_id"], [task objectForKey:@"task_id"], nil] 
														 forKeys:[NSArray arrayWithObjects:@"timeline", @"list_id", @"taskseries_id", @"task_id", nil]];
	[NSThread detachNewThreadSelector:@selector(deleteTask:) toTarget:self withObject:params];
}

-(void)deleteTask:(NSDictionary*)params {
	[progress setHidden:NO];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[rtmController dataByCallingMethod:@"rtm.tasks.delete" andParameters:params withToken:YES];
	
	[self getTasks];
	[pool release];
	[progress setHidden:YES];
}

-(void)menuSearch:(id)sender {
	if (!singleInputWindowController)
		singleInputWindowController = [[SingleInputWindowController alloc] initWithWindowNibName:@"SingleInput"];
	[singleInputWindowController setButtonText:@"Search"];
	NSWindow *sheet = [singleInputWindowController window];
	[NSApp beginSheet:sheet modalForWindow:self.window modalDelegate:self 
	   didEndSelector:@selector(closeSearchSheet:returnCode:contextInfo:) contextInfo:nil];
}

-(void)closeSearchSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[sheet orderOut:self];
	if (returnCode == 1) {
		currentSearch = [singleInputWindowController text];
		currentList = nil;
		[currentSearch retain];

		[NSThread detachNewThreadSelector:@selector(searchTasks:) toTarget:self withObject:currentSearch];
	}
	
}

-(void)menuMultiAdd:(id)sender {
	if (!multiAddWindowController)
		multiAddWindowController = [[MultiAddWindowController alloc] initWithWindowNibName:@"MultiAdd"];
	NSWindow *sheet = [multiAddWindowController window];
	[NSApp beginSheet:sheet modalForWindow:self.window modalDelegate:self 
	   didEndSelector:@selector(closeMultiAddSheet:returnCode:contextInfo:) contextInfo:nil];
}

-(void)closeMultiAddSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[sheet orderOut:self];
	if (returnCode == 1) {
		NSArray *newTasks = [multiAddWindowController tasks];
		NSString *globalAttributes = [multiAddWindowController globalAttributes];
		[NSThread detachNewThreadSelector:@selector(addTasks:) toTarget:self withObject:[NSArray arrayWithObjects: newTasks,globalAttributes,nil]];
	}
	
}

-(void)menuRenameTask:(id)sender {
	NSInteger rowIndex = [taskTable selectedRow];
	if (rowIndex == -1)
		return;
	NSDictionary *task = [tasks objectAtIndex:rowIndex];
	if (!singleInputWindowController)
		singleInputWindowController = [[SingleInputWindowController alloc] initWithWindowNibName:@"SingleInput"];
	[singleInputWindowController setButtonText:@"Rename"];
	[singleInputWindowController setTextValue:[task objectForKey:@"name"]];
	NSWindow *sheet = [singleInputWindowController window];
	[NSApp beginSheet:sheet modalForWindow:self.window modalDelegate:self 
	   didEndSelector:@selector(closeRenameTaskSheet:returnCode:contextInfo:) contextInfo:nil];
}

-(void)closeRenameTaskSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[sheet orderOut:self];
	if (returnCode == 1) {
		NSString *taskName = [singleInputWindowController text];
		NSInteger rowIndex = [taskTable selectedRow];
		if (rowIndex == -1)
			return;
		NSDictionary *task = [tasks objectAtIndex:rowIndex];
		
		NSDictionary *params = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:timeline, [task objectForKey:@"list_id"], [task objectForKey:@"taskseries_id"], [task objectForKey:@"task_id"], taskName,nil] 
															 forKeys:[NSArray arrayWithObjects:@"timeline", @"list_id", @"taskseries_id", @"task_id", @"name", nil]];
		[NSThread detachNewThreadSelector:@selector(renameTask:) toTarget:self withObject:params];
	}
	
}
-(void)renameTask:(NSDictionary*)params {
	[progress setHidden:NO];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[rtmController dataByCallingMethod:@"rtm.tasks.setName" andParameters:params withToken:YES];
	[self getTasks];
	[pool release];
	[progress setHidden:YES];
}

-(void)menuSetTagsTask:(id)sender {
	NSInteger rowIndex = [taskTable selectedRow];
	if (rowIndex == -1)
		return;
	NSDictionary *task = [tasks objectAtIndex:rowIndex];
	if (!singleInputWindowController)
		singleInputWindowController = [[SingleInputWindowController alloc] initWithWindowNibName:@"SingleInput"];
	[singleInputWindowController setButtonText:@"Set Tags"];
	[singleInputWindowController setTextValue:[task objectForKey:@"tags"]];
	NSWindow *sheet = [singleInputWindowController window];
	[NSApp beginSheet:sheet modalForWindow:self.window modalDelegate:self 
	   didEndSelector:@selector(closeSetTagsTaskSheet:returnCode:contextInfo:) contextInfo:nil];
}

-(void)closeSetTagsTaskSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[sheet orderOut:self];
	if (returnCode == 1) {
		NSString *tags = [singleInputWindowController text];
		NSInteger rowIndex = [taskTable selectedRow];
		if (rowIndex == -1)
			return;
		NSDictionary *task = [tasks objectAtIndex:rowIndex];
		
		NSDictionary *params = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:timeline, [task objectForKey:@"list_id"], [task objectForKey:@"taskseries_id"], [task objectForKey:@"task_id"], tags,nil] 
															 forKeys:[NSArray arrayWithObjects:@"timeline", @"list_id", @"taskseries_id", @"task_id", @"tags", nil]];
		[NSThread detachNewThreadSelector:@selector(setTagsTask:) toTarget:self withObject:params];
	}
	
}
-(void)setTagsTask:(NSDictionary*)params {
	[progress setHidden:NO];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[rtmController dataByCallingMethod:@"rtm.tasks.setTags" andParameters:params withToken:YES];
	[self getTasks];
	[pool release];
	[progress setHidden:YES];
}

-(void)menuSetDueTask:(id)sender {
	NSInteger rowIndex = [taskTable selectedRow];
	if (rowIndex == -1)
		return;
	NSDictionary *task = [tasks objectAtIndex:rowIndex];
	if (!singleInputWindowController)
		singleInputWindowController = [[SingleInputWindowController alloc] initWithWindowNibName:@"SingleInput"];
	[singleInputWindowController setButtonText:@"Set Due"];
	[singleInputWindowController setTextValue:[[task objectForKey:@"due"] isKindOfClass:[NSDate class]] ? [[task objectForKey:@"due"] relativeFormattedDateOnly] : @""];
	NSWindow *sheet = [singleInputWindowController window];
	[NSApp beginSheet:sheet modalForWindow:self.window modalDelegate:self 
	   didEndSelector:@selector(closeSetDueTaskSheet:returnCode:contextInfo:) contextInfo:nil];
}

-(void)closeSetDueTaskSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[sheet orderOut:self];
	if (returnCode == 1) {
		NSString *due = [singleInputWindowController text];
		NSInteger rowIndex = [taskTable selectedRow];
		if (rowIndex == -1)
			return;
		NSDictionary *task = [tasks objectAtIndex:rowIndex];
		
		NSDictionary *params = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:timeline, [task objectForKey:@"list_id"], [task objectForKey:@"taskseries_id"], [task objectForKey:@"task_id"], due, @"1", nil] 
															 forKeys:[NSArray arrayWithObjects:@"timeline", @"list_id", @"taskseries_id", @"task_id", @"due", @"parse", nil]];
		[NSThread detachNewThreadSelector:@selector(setDueTask:) toTarget:self withObject:params];
	}
	
}
-(void)setDueTask:(NSDictionary*)params {
	[progress setHidden:NO];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[rtmController dataByCallingMethod:@"rtm.tasks.setDueDate" andParameters:params withToken:YES];
	[self getTasks];
	[pool release];
	[progress setHidden:YES];
}

-(void)menuJumpToTag:(id)sender {
	if (!comboInputWindowController)
		comboInputWindowController = [[ComboInputWindowController alloc] initWithWindowNibName:@"ComboInput"];
	[comboInputWindowController setData:tagList];
	NSWindow *sheet = [comboInputWindowController window];
	[NSApp beginSheet:sheet modalForWindow:self.window modalDelegate:self 
	   didEndSelector:@selector(closeJumpToTagSheet:returnCode:contextInfo:) contextInfo:nil];
}

-(void)closeJumpToTagSheet:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
	[sheet orderOut:self];
	if (returnCode == 1) {
		[self searchTasks:[NSString stringWithFormat:@"tag:%@", [comboInputWindowController text]]];
	}
}

@end
