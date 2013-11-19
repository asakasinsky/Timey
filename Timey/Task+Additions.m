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
	NSTimeInterval interval = 0;
	
	if ([self isRunning]) {
		interval = ([[NSDate date] timeIntervalSinceReferenceDate] - [[[self timeStarted] dateByAddingTimeInterval:[[self allocatedTime] doubleValue]] timeIntervalSinceReferenceDate]) * -1;
	} else {
		interval = (NSTimeInterval)[[self remainingTime] doubleValue];
	}
	
	NSLog(@"%f", interval);
	
	return interval;
}

- (NSString *)formattedTimeLeft {
	return [Task stringFromTimeInterval:[self timeLeft]];
}

- (void)setFormattedAllocatedTime:(NSString *)allocatedTime {
	[self setAllocatedTime:[NSNumber numberWithDouble:[Task timeIntervalFromString:allocatedTime]]];
}

- (BOOL)isRunning {
	if ([self timeStarted]) {
		return YES;
	} else {
		return NO;
	}
}

- (void)startTimer {
	if (!runningTimer) {
		runningTimer = [NSTimer scheduledTimerWithTimeInterval:[[self remainingTime] doubleValue] target:self selector:@selector(timerDone:) userInfo:nil repeats:NO];
		[self setTimeStarted:[NSDate date]];
	}
}

- (void)stopTimer {
	[runningTimer invalidate];
	runningTimer = nil;
	
	[self setRemainingTime:[NSNumber numberWithDouble:[self timeLeft]]];
	[self setTimeStarted:nil];
}

- (void)resetTimer {
	[self setRemainingTime:[self allocatedTime]];
}

- (void)timerDone:(NSTimer *)timer {
	[self stopTimer];
}

@end
