//
//  ComboInputWindowController.h
//  MilkMaid
//
//  Created by Gregamel on 2/28/10.
//  Copyright 2010 JGA. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ComboInputWindowController : NSWindowController {
	IBOutlet NSComboBox *comboBox;
	NSArray *data;
	NSString *text;
}
//@property (assign) NSArray *data;
@property (assign) NSString *text;
-(IBAction)okClicked:(id)sender;
-(IBAction)cancelClicked:(id)sender;
-(void)setData:(NSArray *)aData;
@end
