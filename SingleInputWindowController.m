//
//  AddTaskWindowController.m
//  SimpleRTM
//
//  Created by Greg Allen on 2/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SingleInputWindowController.h"


@implementation SingleInputWindowController

@synthesize text;
@synthesize buttonText;

-(void)windowDidLoad {
	[textField setStringValue:text];
	[okButton setTitle:buttonText];
}

-(void)okClicked:(id)sender {
	text = [textField stringValue];
	[textField setStringValue:@""];
	[NSApp endSheet:[self window] returnCode:1];
	
}

-(void)setTextValue:(NSString *)textValue {
	text = textValue;
	[textField setStringValue:textValue];
}

-(void)setButtonText:(NSString *)buttonTextValue {
	buttonText = buttonTextValue;
	[okButton setTitle:buttonTextValue];
}

-(void)cancelClicked:(id)sender {
	[textField setStringValue:@""];
	[NSApp endSheet:[self window] returnCode:0];
}

@end
