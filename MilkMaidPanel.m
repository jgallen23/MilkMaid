//
//  MilkMaidPanel.m
//  MilkMaid
//
//  Created by Greg Allen on 2/28/10.
//  Copyright 2010 JGA. All rights reserved.
//

#import "MilkMaidPanel.h"


@implementation MilkMaidPanel

-(BOOL)canBecomeMainWindow {
	return YES;
}

-(BOOL)isExcludedFromWindowsMenu {
	return NO;
}

@end
