//
//  RTMHelper.m
//  SimpleRTM
//
//  Created by Greg Allen on 1/28/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "RTMHelper.h"
#import "NSDateHelper.h"



static int comparePriorities(id obj1, id obj2, void *context) {
	NSComparisonResult comp = 0;
	int priority1 = [[obj1 objectForKey:@"priority"] intValue];
	int priority2 = [[obj2 objectForKey:@"priority"] intValue];
	
	if (priority1 == 0) {
		priority1 = 4;
	}
	if (priority2 == 0) {
		priority2 = 4;
	}


	if (priority1 > priority2) {
		comp = NSOrderedDescending;
	} else if (priority2 > priority1) {
		comp = NSOrderedAscending;
	} else {
		comp = NSOrderedSame;
	}
	
	//NSLog(@"%@ (%d) v %@ (%d) = %d", [obj1 objectForKey:@"name"], priority1, [obj2 objectForKey:@"name"], priority2, comp);
	[obj1 retain];
	[obj2 retain];
	return comp;
}

static int compareDates(id obj1, id obj2, void *context) {
	
	id due1 = [obj1 objectForKey:@"due"];
	id due2 = [obj2 objectForKey:@"due"];
	
	NSComparisonResult comp = 0;
	
	if ([due1 isKindOfClass:[NSDate class]] && [due2 isKindOfClass:[NSDate class]]) {
		comp = [due1 compare:due2];
	} else if ([due1 isKindOfClass:[NSDate class]] && ![due2 isKindOfClass:[NSDate class]]) {
		comp = NSOrderedAscending;
	} else if ([due2 isKindOfClass:[NSDate class]]) {
		comp = NSOrderedDescending;
	} else {
		comp = NSOrderedSame;
	}
	//NSLog(@"%@ (%d) v %@ (%d) = %d", [obj1 objectForKey:@"name"], due1, [obj2 objectForKey:@"name"], due2, comp);
	[obj1 retain];
	[obj2 retain];
	return comp;
}

static int compareNames(id obj1, id obj2, void *context) {
	NSString *name1 = [obj1 objectForKey:@"name"];
	NSString *name2 = [obj2 objectForKey:@"name"];
	NSComparisonResult comp = [name1 compare:name2];
	NSLog(@"%@ v %@  = %d", name1, name2, comp);
	return comp;
}

static int compare(id obj1, id obj2, void *context) {

	NSComparisonResult comp = compareDates(obj1, obj2, &context);
	if (comp == NSOrderedSame) {

		comp = comparePriorities(obj1, obj2, &context);
	}
	return comp;
}

@implementation RTMHelper


-(NSMutableArray*)getFlatTaskList:(NSDictionary *)rtmResponse {
	
	NSMutableArray *tasks = [[NSMutableArray alloc] init];
	
	NSDictionary *taskList = [rtmResponse objectForKey:@"tasks"];
	
	if (![taskList objectForKey:@"list"])
		return tasks;
	
	NSArray *listTasks = [self getArray:[[rtmResponse objectForKey:@"tasks"] objectForKey:@"list"]];

	for (NSDictionary *list in listTasks) {
		NSArray *taskSeriesList = [self getArray:[list objectForKey:@"taskseries"]];
		NSArray* taskSeriesListReversed = [[taskSeriesList reverseObjectEnumerator] allObjects];
		for (NSDictionary *taskSeries in taskSeriesListReversed) {
			NSDictionary *t = [taskSeries objectForKey:@"task"];
			id *due;
			NSLog(@"%@", [t objectForKey:@"due"]);
			if (![[t objectForKey:@"due"] isEqualToString:@""]) {
				NSString *dueDate = [[t objectForKey:@"due"] substringToIndex:10];
				due = [NSDate dateWithDateString:dueDate];
				NSLog(@"%@", dueDate);
				NSLog(@"%@", due);
			} else {
				due = @"";
			}



			NSDictionary *task = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[list objectForKey:@"id"], [taskSeries objectForKey:@"id"], 
																	  [t objectForKey:@"id"], [taskSeries objectForKey:@"name"], [t objectForKey:@"priority"], due ,nil] 
															 forKeys:[NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", @"name", @"priority", @"due", nil]];
			[tasks addObject:task];
		}
	}
	
	NSLog(@"%@", tasks);
	return [self sortTasks:tasks];
}

-(NSMutableArray*)sortTasks:(NSMutableArray*)tasks {
	[tasks sortUsingFunction:compare context:nil];
	return tasks;
}


-(NSArray*)getArray:(id)obj {
	if ([obj isKindOfClass:[NSArray class]]) {
		return obj;
	} else {
		return [NSArray arrayWithObject:obj];
	}
}

@end
