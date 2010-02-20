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
	NSLog(@"%@", taskList);
	NSArray *listTasks = [self getArray:[[rtmResponse objectForKey:@"tasks"] objectForKey:@"list"]];

	for (NSDictionary *list in listTasks) {
		NSLog(@"%@", list);
		NSArray *taskSeriesList = [self getArray:[list objectForKey:@"taskseries"]];
		NSArray* taskSeriesListReversed = [[taskSeriesList reverseObjectEnumerator] allObjects];
		for (NSDictionary *taskSeries in taskSeriesListReversed) {
			NSLog(@"%@", taskSeries);
			
			NSArray *taskArray = [self getArray:[taskSeries objectForKey:@"task"]];
			for (NSDictionary *t in taskArray) {

				id *due;
				if (![[t objectForKey:@"due"] isEqualToString:@""]) {
					NSString *dueDate = [[t objectForKey:@"due"] substringToIndex:10];
					due = [NSDate dateWithDateString:dueDate];
				} else {
					due = @"";
				}
				NSString *tags = @"";
				id *tagNode = [taskSeries objectForKey:@"tags"];
				if ([tagNode isKindOfClass:[NSDictionary class]]) {
					id *tn = [tagNode objectForKey:@"tag"];
					
					if ([tn isKindOfClass:[NSArray class]]) {
						tags = [tn componentsJoinedByString:@","];
					} else {
						tags = tn;
					}
				}

				NSDictionary *task = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[list objectForKey:@"id"], [taskSeries objectForKey:@"id"], 
																		  [t objectForKey:@"id"], [taskSeries objectForKey:@"name"], [t objectForKey:@"priority"], due , tags, nil] 
																 forKeys:[NSArray arrayWithObjects:@"list_id", @"taskseries_id", @"task_id", @"name", @"priority", @"due", @"tags", nil]];
				[tasks addObject:task];
			}
		}
	}
	
	//NSLog(@"%@", tasks);
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

@end
