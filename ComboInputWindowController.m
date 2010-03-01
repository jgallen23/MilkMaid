//
//  ComboInputWindowController.m
//  MilkMaid
//
//  Created by Gregamel on 2/28/10.
//  Copyright 2010 JGA. All rights reserved.
//

#import "ComboInputWindowController.h"


@implementation ComboInputWindowController
//@synthesize data;
@synthesize text;

-(void)awakeFromNib {
	[self setData:data];
}


-(void)okClicked:(id)sender {
	text = [comboBox objectValue];
	[comboBox setObjectValue:@""];
	[NSApp endSheet:[self window] returnCode:1];
}

-(void)cancelClicked:(id)sender {
	[comboBox setObjectValue:@""];
	[NSApp endSheet:[self window] returnCode:0];
}

-(void)setData:(NSArray *)aData {
	[comboBox removeAllItems];
	for (NSString *item in aData) {
		[comboBox addItemWithObjectValue:item];
	}
	data = aData;
}


@end
