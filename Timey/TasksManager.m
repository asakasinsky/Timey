//
//  TasksManager.m
//  Timey
//
//  Created by Jader Feijo on 19/11/2013.
//  Copyright (c) 2013 Jader Feijo. All rights reserved.
//

#import "TasksManager.h"
#import "Task+Additions.h"

@interface TasksManager () {
	NSMutableArray *_tasks;
	
	NSTimer *_currentTimer;
	NSTimer *_updateTimer;
}

@end

@implementation TasksManager

@synthesize delegate;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize currentTask = _currentTask;

//
// TasksManager Methods
//
#pragma mark - TasksManager Methods -

- (id)initWithManagedObjectContext:(NSManagedObjectContext *)context {
	if ((self = [super init])) {
		_managedObjectContext = context;
	}
	return self;
}

- (void)addTaskWithTitle:(NSString *)title andFormattedAllocatedTime:(NSString *)allocatedTime {
	Task *task = [[Task alloc] initWithEntity:[NSEntityDescription entityForName:@"Task" inManagedObjectContext:[self managedObjectContext]] insertIntoManagedObjectContext:[self managedObjectContext]];
	[task setTitle:title];
	[task setFormattedAllocatedTime:allocatedTime];
	[_tasks addObject:task];
	[self save];
}

- (void)removeTask:(Task *)task {
	[_tasks removeObject:task];
	[[self managedObjectContext] deleteObject:task];
	[self save];
}

- (BOOL)isCurrentTask:(Task *)task {
	return [[[self currentTask] objectID] isEqual:[task objectID]];
}

- (void)startTimerForTask:(Task *)task {
	[self stopCurrentTimer];
	
	[task setTimeStarted:[NSDate date]];
	_currentTask = task;
	
	[self startTimer];
	
	[self save];
	[[self delegate] timerStartedForTask:task];
}

- (void)stopCurrentTimer {
	[self stopTimer];
	
	Task *task = [self currentTask];
	[task updateTimeRemaining];
	[task setTimeStarted:nil];
	
	[self save];
	
	_currentTask = nil;
	
	[[self delegate] timerStoppedForTask:task];
}

- (void)resetTimerForTask:(Task *)task {
	[task setRemainingTime:[task allocatedTime]];
}

- (void)resetAllTimers {
	for (Task *task in [self tasks]) {
		[self resetTimerForTask:task];
	}
}

- (void)save {
	NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

//
// TasksManager Private Methods
//
#pragma mark - TasksManager Private Methods -

- (void)startTimer {
	_currentTimer = [NSTimer scheduledTimerWithTimeInterval:[[self currentTask] timeLeft] target:self selector:@selector(timerDone:) userInfo:nil repeats:NO];
	_updateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(updateTimer:) userInfo:nil repeats:YES];
}

- (void)stopTimer {
	[_currentTimer invalidate];
	_currentTimer = nil;
	
	[_updateTimer invalidate];
	_updateTimer = nil;
}

- (void)timerDone:(NSTimer *)timer {
	[[self delegate] timerFinishedForTask:[self currentTask]];
	[self stopCurrentTimer];
}

- (void)updateTimer:(NSTimer *)timer {
	[[self delegate] timerTickedFor:[self currentTask]];
}

//
// TasksManager Properties
//
#pragma mark - TasksManager Properties -

- (NSArray *)tasks {
	if (!_tasks) {
		NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Task"];
		_tasks = [[NSMutableArray alloc] initWithArray:[[[self managedObjectContext] executeFetchRequest:request error:nil] sortedArrayUsingSelector:@selector(compareTitle:)]];
	
		for (Task *task in _tasks) {
			if ([task timeStarted] != nil) {
				[task updateTimeRemaining];
				[self startTimerForTask:task];
				break;
			}
		}
	}
	return _tasks;
}

@end
