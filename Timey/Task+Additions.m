//
//  Task+Additions.m
//  Timey
//
//  Created by Jader Feijo on 19/11/2013.
//  Copyright (c) 2013 Jader Feijo. All rights reserved.
//

#import "Task+Additions.h"

@implementation Task (Additions)

+ (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02li:%02li", (long)hours, (long)minutes];
}

+ (NSTimeInterval)timeIntervalFromString:(NSString *)intervalString {
	NSArray *components = [intervalString componentsSeparatedByString:@":"];
	NSTimeInterval interval = 0;
	
	if ([components count] > 0) {
		interval += [[components objectAtIndex:0] integerValue] * 3600;
	}
	
	if ([components count] > 1) {
		interval += [[components objectAtIndex:1] integerValue] * 60;
	}
	
	return interval;
}

- (NSTimeInterval)timeLeft {
	NSTimeInterval timeLeft = 0;
	
	if ([self timeStarted]) {
		timeLeft = ([[NSDate date] timeIntervalSinceReferenceDate] - [[[self timeStarted] dateByAddingTimeInterval:[[self remainingTime] doubleValue]] timeIntervalSinceReferenceDate]) * -1;
	} else {
		timeLeft = (NSTimeInterval)[[self remainingTime] doubleValue];
	}
	
	NSLog(@"Time Left: %f for Task: %@", timeLeft, [self title]);
	
	return timeLeft;
}

- (NSString *)formattedTimeLeft {
	return [Task stringFromTimeInterval:[self timeLeft]];
}

- (NSString *)formattedSecondsLeft {
	NSInteger ti = (NSInteger)[self timeLeft];
	NSInteger seconds = ti % 60;
	return [NSString stringWithFormat:@".%02li", (long)seconds];
}

- (void)updateTimeRemaining {
	[self setRemainingTime:[NSNumber numberWithDouble:[self timeLeft]]];
}

- (void)setFormattedAllocatedTime:(NSString *)allocatedTime {
	[self setAllocatedTime:[NSNumber numberWithDouble:[Task timeIntervalFromString:allocatedTime]]];
}

- (NSComparisonResult)compareTitle:(Task *)task {
	return [[self title] compare:[task title]];
}

@end
