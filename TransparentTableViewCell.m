//
//  BWTransparentTableViewCell.m
//  BWToolkit
//
//  Created by Brandon Walkin (www.brandonwalkin.com)
//  All code is provided under the New BSD license.
//

#import "TransparentTableViewCell.h"
#import "RTMHelper.h"


@implementation TransparentTableViewCell

-(void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView {
	
	NSColor* primaryColor   = [self isHighlighted] ? [NSColor whiteColor] : [NSColor colorWithCalibratedWhite:(225.0f / 255.0f) alpha:1];
	NSString* primaryText   = [self title];
	
	int y = (![altText isEqualToString:@""] || ![alt2Text isEqualToString:@""]) ? cellFrame.origin.y : cellFrame.origin.y+cellFrame.size.height/5;
	NSMutableDictionary* primaryTextAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys: primaryColor, NSForegroundColorAttributeName, nil];	
	if (shouldBold) {
		[primaryTextAttributes setObject:[NSFont boldSystemFontOfSize:11] forKey:NSFontAttributeName];
	} else {
		[primaryTextAttributes setObject:[NSFont systemFontOfSize:11] forKey:NSFontAttributeName];
	}
	[primaryText drawAtPoint:NSMakePoint(cellFrame.origin.x, y) withAttributes:primaryTextAttributes];
	
	
	//#0060BF
	if (![altText isEqualToString:@""]) {
		NSColor* secondaryColor = [self isHighlighted] ? [NSColor colorWithCalibratedWhite:(198.0f / 255.0f) alpha:1] : [NSColor disabledControlTextColor];
		NSDictionary* secondaryTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys: secondaryColor, NSForegroundColorAttributeName,
												 [NSFont systemFontOfSize:9], NSFontAttributeName, nil];	
		[altText drawAtPoint:NSMakePoint(cellFrame.origin.x, cellFrame.origin.y+cellFrame.size.height/2) 
					withAttributes:secondaryTextAttributes];
	}
	
	if (![alt2Text isEqualToString:@""]) {
		NSColor* secondaryColor = [self isHighlighted] ? [NSColor colorWithCalibratedWhite:(198.0f / 255.0f) alpha:1] : [NSColor disabledControlTextColor];
		NSDictionary* secondaryTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys: secondaryColor, NSForegroundColorAttributeName,
												 [NSFont systemFontOfSize:9], NSFontAttributeName, nil];	
		NSSize size = [alt2Text sizeWithAttributes:secondaryTextAttributes];
		[alt2Text drawAtPoint:NSMakePoint(cellFrame.origin.x + cellFrame.size.width - size.width, cellFrame.origin.y+cellFrame.size.height/2) 
			  withAttributes:secondaryTextAttributes];
	}
}

#pragma mark RSVerticallyCenteredTextFieldCell
// RSVerticallyCenteredTextFieldCell courtesy of Daniel Jalkut
// http://www.red-sweater.com/blog/148/what-a-difference-a-cell-makes

- (NSRect)drawingRectForBounds:(NSRect)theRect
{
	// Get the parent's idea of where we should draw
	NSRect newRect = [super drawingRectForBounds:theRect];
	
	// When the text field is being 
	// edited or selected, we have to turn off the magic because it screws up 
	// the configuration of the field editor.  We sneak around this by 
	// intercepting selectWithFrame and editWithFrame and sneaking a 
	// reduced, centered rect in at the last minute.
	if (mIsEditingOrSelecting == NO)
	{
		// Get our ideal size for current text
		NSSize textSize = [self cellSizeForBounds:theRect];
		
		// Center that in the proposed rect
		float heightDelta = newRect.size.height - textSize.height;	
		if (heightDelta > 0)
		{
			newRect.size.height -= heightDelta;
			newRect.origin.y += (heightDelta / 2);
		}
	}
	
	return newRect;
}

- (void)selectWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject start:(NSInteger)selStart length:(NSInteger)selLength
{
	aRect = [self drawingRectForBounds:aRect];
	mIsEditingOrSelecting = YES;	
	[super selectWithFrame:aRect inView:controlView editor:textObj delegate:anObject start:selStart length:selLength];
	mIsEditingOrSelecting = NO;
}

- (void)editWithFrame:(NSRect)aRect inView:(NSView *)controlView editor:(NSText *)textObj delegate:(id)anObject event:(NSEvent *)theEvent
{	
	aRect = [self drawingRectForBounds:aRect];
	mIsEditingOrSelecting = YES;
	[super editWithFrame:aRect inView:controlView editor:textObj delegate:anObject event:theEvent];
	mIsEditingOrSelecting = NO;
}

- (void)setTextColor:(NSColor *)color {
	customTextColor = YES;
	[super setTextColor:color];
}

- (void)setBold:(BOOL)bold {
	shouldBold = bold;
}

- (void)setAlternateText:(NSString*)text {
	altText = text;
	[altText retain];
}

- (void)setAlternate2Text:(NSString *)text {
	alt2Text = text;
	[alt2Text retain];
}

@end
