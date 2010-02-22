//
//  AddTaskWindowController.h
//  SimpleRTM
//
//  Created by Greg Allen on 2/10/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SingleInputWindowController : NSWindowController {
	IBOutlet NSTextField *textField;
	IBOutlet NSButton *okButton;
	NSString *text;
	NSString *buttonText;
}
@property (assign) NSString *text;
@property (assign) NSString *buttonText;
-(IBAction)okClicked:(id)sender;
-(IBAction)cancelClicked:(id)sender;
-(void)setTextValue:(NSString *)textValue;
-(void)setButtonText:(NSString *);
@end
