//
//  RTMHelper.m
//  SimpleRTM
//
//  Created by Greg Allen on 1/28/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "RTMHelper.h"


@implementation RTMHelper


+(NSArray*)getFlatTaskList:(NSDictionary *)rtmResponse {
	
	NSMutableArray *tasks = [[NSMutableArray alloc] init];
	
	NSDictionary *taskList = [rtmResponse objectForKey:@"tasks"];
	
	if (![taskList objectForKey:@"list"])
		return tasks;
	
	NSArray *listTasks = [RTMHelper getArray:[[rtmResponse objectForKey:@"tasks"] objectForKey:@"list"]];

	for (NSDictionary *list in listTasks) {
		NSArray *taskSeriesList = [RTMHelper getArray:[list objectForKey:@"taskseries"]];
		NSArray* taskSeriesListReversed = [[taskSeriesList reverseObjectEnumerator] allObjects];
		for (NSDictionary *taskSeries in taskSeriesListReversed) {
			NSDictionary *t = [taskSeries objectForKey:@"task"];
			NSDictionary *task = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[list objectForKey:@"id"], [taskSeries objectForKey:@"id"], 
																	  [t objectForKey:@"id"], [taskSeries objectForKey:@"name"], [t objectForKey:@"priority"] ,nil] 
															 forKeys:[NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", @"name", @"priority", nil]];
			[tasks addObject:task];
		}
	}
	
	
	return tasks;
}

+(NSArray*)getArray:(id)obj {
	if ([obj isKindOfClass:[NSArray class]]) {
		return obj;
	} else {
		return [NSArray arrayWithObject:obj];
	}
}

@end
