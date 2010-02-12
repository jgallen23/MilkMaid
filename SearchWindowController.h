//
//  SearchWindowController.h
//  SimpleRTM
//
//  Created by Gregamel on 2/12/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SearchWindowController : NSWindowController {
	IBOutlet NSTextField *searchField;
	NSString *searchString;
}
@property (assign) NSString *searchString;
-(IBAction)searchClicked:(id)sender;
-(IBAction)cancelClicked:(id)sender;
@end
