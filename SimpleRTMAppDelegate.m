//
//  SimpleRTMAppDelegate.m
//  SimpleRTM
//
//  Created by Gregamel on 1/27/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SimpleRTMAppDelegate.h"
#define TOKEN @"Token"
#define LAST_LIST @"LastList"
@implementation SimpleRTMAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

	NSString *apiKey = @"1734ba9431007c2242b6865a69940aa5";
	NSString *secret = @"72d1c12ffb26e759";
	
	[progress setForeColor:[NSColor whiteColor]];
	[progress startAnimation:nil];
	
	[addTaskPanel orderOut:self];
	
	[taskTable setDelegate:self];
	[taskTable setDataSource:self];
	
	rtmController = [[EVRZRtmApi alloc] initWithApiKey:apiKey andApiSecret:secret];
	[NSThread detachNewThreadSelector:@selector(checkToken) toTarget:self withObject:nil];
}

- (void)checkToken {
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSString * token = [[NSUserDefaults standardUserDefaults] objectForKey:TOKEN];
	
	if (token) {
		rtmController.token = token;
		NSDictionary *data = [rtmController dataByCallingMethod:@"rtm.auth.checkToken" andParameters:[[NSDictionary alloc]init] withToken:YES];
		NSLog(@"%@", [data objectForKey:@"stat"]);
		if ([[data objectForKey:@"stat"] isEqualToString:@"ok"]) {
			NSLog(@"Token Good");
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
	[alert setInformativeText:@"A browser will be opened, please select accept permissions"];
	[alert setAlertStyle:NSWarningAlertStyle];
	
	if ([alert runModal] == NSAlertFirstButtonReturn) {
		NSString *token = [rtmController tokenWithFrob:frob];
		rtmController.token = token;
		[[NSUserDefaults standardUserDefaults] setObject:token forKey:TOKEN];
		NSLog(@"%@", token);
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
	NSLog(@"selected");
	NSInteger selectedIndex = [listPopUp indexOfSelectedItem];
	selectedIndex--;
	if (selectedIndex != -1 && [currentList objectForKey:@"id"] != [[lists objectAtIndex:selectedIndex] objectForKey:@"id"]) {
		currentList = [lists objectAtIndex:selectedIndex];
		[[NSUserDefaults standardUserDefaults] setObject:[currentList objectForKey:@"name"] forKey:LAST_LIST];
		[NSThread detachNewThreadSelector:@selector(getTasks) toTarget:self withObject:nil];
		
		NSLog(@"%@", currentList);
		[currentList retain];
	}
}

-(void)getTasks {
	[progress setHidden:NO];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDictionary *params = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[currentList objectForKey:@"id"], @"status:incomplete", nil] 
														 forKeys:[NSArray arrayWithObjects:@"list_id", @"filter", nil]];
	NSDictionary *data = [rtmController dataByCallingMethod:@"rtm.tasks.getList" andParameters:params withToken:YES];
	
	RTMHelper *rtmHelper = [[RTMHelper alloc] init];
	
	tasks = [rtmHelper getFlatTaskList:data];

	[self performSelectorOnMainThread:@selector(loadTaskData) withObject:nil waitUntilDone:NO];
	
	[tasks retain];
	[pool release];
	[progress setHidden:YES];
}

-(void)refresh:(id)sender {
	[NSThread detachNewThreadSelector:@selector(getTasks) toTarget:self withObject:nil];
}

-(void)loadTaskData {
	//NSLog(@"%@", tasks);
	[[[NSApplication sharedApplication] dockTile] setBadgeLabel:[[NSNumber numberWithInt:[tasks count]] stringValue]];
	[taskTable reloadData];
}

-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return [tasks count];
}
								
-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	//check type of cell
	id cell = [tableColumn dataCellForRow:row];
	if ([cell isMemberOfClass:[BWTransparentCheckboxCell class]]) {
		return [NSNumber numberWithInteger:NSOffState];
	} else {//if ([cell isMemberOfClass:[BWTransparentTableViewCell class]]) {
		NSDictionary *task = [tasks objectAtIndex:row];
		
		NSString *pri = [task objectForKey:@"priority"];
		if ([pri isEqualToString:@"1"]) {
			[cell setTextColor:[SimpleRTMAppDelegate colorFromHexRGB:@"EA5200"]];
		} else if ([pri isEqualToString:@"2"]) {
			[cell setTextColor:[SimpleRTMAppDelegate colorFromHexRGB:@"0060BF"]];
		} else if ([pri isEqualToString:@"3"]) {
			[cell setTextColor:[SimpleRTMAppDelegate colorFromHexRGB:@"359AFF"]];
		} else {
			[cell setTextColor:[NSColor whiteColor]];
		}

		return [task objectForKey:@"name"];
	}
	
}

+ (NSColor *) colorFromHexRGB:(NSString *) inColorString
{
	NSColor *result = nil;
	unsigned int colorCode = 0;
	unsigned char redByte, greenByte, blueByte;
	
	if (nil != inColorString)
	{
		NSScanner *scanner = [NSScanner scannerWithString:inColorString];
		(void) [scanner scanHexInt:&colorCode];	// ignore error
	}
	redByte		= (unsigned char) (colorCode >> 16);
	greenByte	= (unsigned char) (colorCode >> 8);
	blueByte	= (unsigned char) (colorCode);	// masks off high bits
	result = [NSColor
			  colorWithCalibratedRed:		(float)redByte	/ 0xff
			  green:	(float)greenByte/ 0xff
			  blue:	(float)blueByte	/ 0xff
			  alpha:1.0];
	return result;
}
				
-(void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	NSDictionary *task = [tasks objectAtIndex:row];
	NSLog(@"%@", task);
	NSDictionary *params = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[rtmController timeline], [task objectForKey:@"list_id"], [task objectForKey:@"taskseries_id"], [task objectForKey:@"task_id"], nil] 
														 forKeys:[NSArray arrayWithObjects:@"timeline", @"list_id", @"taskseries_id", @"task_id", nil]];
	NSLog(@"%@", params);
	[tasks removeObject:task];
	[NSThread detachNewThreadSelector:@selector(completeTask:) toTarget:self withObject:params];
	[taskTable reloadData];
}

-(void)completeTask:(NSDictionary *)taskInfo {
	[progress setHidden:NO];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDictionary *data = [rtmController dataByCallingMethod:@"rtm.tasks.complete" andParameters:taskInfo withToken:YES];
	NSLog(@"%@", data);
	[pool release];
	[progress setHidden:YES];
}

-(void)showAddTask:(id)sender {
	NSLog(@"new task");
	[NSApp beginSheet:addTaskPanel modalForWindow:window modalDelegate:self didEndSelector:nil contextInfo:nil];
}

-(void)closeSheet:(id)sender {
	[addTaskPanel orderOut:nil];
	[NSApp endSheet:addTaskPanel];
}

-(void)addTask:(NSString*)task {
	[progress setHidden:NO];
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSDictionary *params = [[NSDictionary alloc] initWithObjects:[NSArray arrayWithObjects:[rtmController timeline], [currentList objectForKey:@"id"], task, @"1", nil] 
														 forKeys:[NSArray arrayWithObjects:@"timeline", @"list_id",@"name", @"parse", nil]];
	[rtmController dataByCallingMethod:@"rtm.tasks.add" andParameters:params withToken:YES];
	
	[self getTasks];
	[pool release];
	[progress setHidden:YES];
}

-(void)addTaskClicked:(id)sender {
	NSString *task = [addTaskField stringValue];
	NSLog(@"%@", task);

	[NSThread detachNewThreadSelector:@selector(addTask:) toTarget:self withObject:task];
	
	[self closeSheet:nil];
}

-(void)showLists:(id)sender {
	[listPopUp performClick:self];
}
								

@end
