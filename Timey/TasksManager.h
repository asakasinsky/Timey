//
//  TasksManager.h
//  Timey
//
//  Created by Jader Feijo on 19/11/2013.
//  Copyright (c) 2013 Jader Feijo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TasksManagerDelegate.h"

@class Task;

@interface TasksManager : NSObject

@property (assign) id<TasksManagerDelegate> delegate;
@property (readonly, retain) NSManagedObjectContext *managedObjectContext;
@property (readonly, retain) NSArray *tasks;
@property (readonly, retain) Task *currentTask;

-(id)initWithManagedObjectContext:(NSManagedObjectContext *)context;

-(void)addTaskWithTitle:(NSString *)title andFormattedAllocatedTime:(NSString *)allocatedTime;
-(void)removeTask:(Task *)task;

-(void)startTimerForTask:(Task *)task;
-(void)stopCurrentTimer;

-(void)resetTimerForTask:(Task *)task;
-(void)resetAllTimers;

-(void)reloadData;
-(void)save;

@end
