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
	NSTimer *_currentTimer;
}

@end

@implementation TasksManager

@synthesize delegate;
@synthesize managedObjectContext = _managedObjectContext;
@synthesize tasks = _tasks;
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
	[self save];
	[self reloadData];
}

- (void)removeTask:(Task *)task {
	[[self managedObjectContext] deleteObject:task];
	[self save];
	[self reloadData];
}

- (void)startTimerForTask:(Task *)task {
	[self stopCurrentTimer];
	
	[task setTimeStarted:[NSDate date]];
	_currentTimer = [NSTimer timerWithTimeInterval:[task timeLeft] target:self selector:@selector(timerDone:) userInfo:nil repeats:NO];
	_currentTask = task;
	
	[[self delegate] timerStartedForTask:task];
}

- (void)stopCurrentTimer {
	[self stopTimer];
	
	Task *task = [self currentTask];
	_currentTask = nil;
	
	[task updateTimeRemaining];
	[task setTimeStarted:nil];
	
	[self save];
	
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

- (void)reloadData {
	_tasks = nil;
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

- (void)stopTimer {
	[_currentTimer invalidate];
	_currentTimer = nil;
}

- (void)timerDone:(NSTimer *)timer {
	[[self delegate] timerFinishedForTask:[self currentTask]];
	[self stopCurrentTimer];
}

//
// TasksManager Properties
//
#pragma mark - TasksManager Properties -

- (NSArray *)tasks {
	if (!_tasks) {
		NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Task"];
		_tasks = [[[self managedObjectContext] executeFetchRequest:request error:nil] sortedArrayUsingSelector:@selector(compareTitle:)];
	}
	return _tasks;
}

@end
