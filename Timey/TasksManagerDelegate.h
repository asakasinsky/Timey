//
//  TasksManagerDelegate.h
//  Timey
//
//  Created by Jader Feijo on 19/11/2013.
//  Copyright (c) 2013 Jader Feijo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Task;

@protocol TasksManagerDelegate <NSObject>

-(void)timerStartedForTask:(Task *)task;
-(void)timerStoppedForTask:(Task *)task;
-(void)timerFinishedForTask:(Task *)task;

@end
