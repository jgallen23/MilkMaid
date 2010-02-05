//
//  BWTransparentTableViewCell.h
//  BWToolkit
//
//  Created by Brandon Walkin (www.brandonwalkin.com)
//  All code is provided under the New BSD license.
//

#import <Cocoa/Cocoa.h>

@interface TransparentTableViewCell : NSTextFieldCell 
{
	BOOL mIsEditingOrSelecting;
	BOOL customTextColor;
	BOOL shouldBold;
}


@end
