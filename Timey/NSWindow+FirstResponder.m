//
//  NSWindow+FirstResponder.m
//  Timey
//
//  Created by Jader Feijo on 19/11/2013.
//  Copyright (c) 2013 Jader Feijo. All rights reserved.
//

#import "NSWindow+FirstResponder.h"
#import "AppDelegate.h"
#import "StatusItemView.h"

@implementation NSWindow (FirstResponder)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (BOOL)canBecomeKeyWindow {
	if ([self isKindOfClass:NSClassFromString(@"NSStatusBarWindow")]) {
		if (![[(AppDelegate *)[NSApp delegate] statusItemView] isHighlighted]) {
			return NO;
		}
	}
	return YES;
}

#pragma clang diagnostic pop

@end
