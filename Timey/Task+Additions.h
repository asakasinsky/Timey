//
//  Task+Additions.h
//  Timey
//
//  Created by Jader Feijo on 19/11/2013.
//  Copyright (c) 2013 Jader Feijo. All rights reserved.
//

#import "Task.h"

@interface Task (Additions)

+ (NSString *)stringFromTimeInterval:(NSTimeInterval)interval;
+ (NSTimeInterval)timeIntervalFromString:(NSString *)intervalString;

- (NSTimeInterval)timeLeft;
- (NSString *)formattedTimeLeft;

- (void)setFormattedAllocatedTime:(NSString *)allocatedTime;

- (BOOL)isRunning;
- (void)startTimer;
- (void)stopTimer;
- (void)resetTimer;

@end
