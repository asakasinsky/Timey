//
//  AppDelegate.h
//  Timey
//
//  Created by Jader Feijo on 18/11/2013.
//  Copyright (c) 2013 Jader Feijo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class StatusItemView;

@interface AppDelegate : NSObject <NSApplicationDelegate, NSWindowDelegate, NSTableViewDataSource, NSTableViewDelegate>

@property (assign) IBOutlet NSPopover *popover;
@property (assign) IBOutlet NSView *containerView;

@property (assign) IBOutlet NSView *tasksView;
@property (assign) IBOutlet NSTableView *tasksTableView;

@property (assign) IBOutlet NSView *addTaskView;
@property (assign) IBOutlet NSTextField *taskNameTextField;
@property (assign) IBOutlet NSTextField *taskTimeTextField;

@property (readonly, strong, nonatomic) StatusItemView *statusItemView;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;
- (IBAction)addTaskAction:(id)sender;
- (IBAction)removeTaskAction:(id)sender;
- (IBAction)resetTimerAction:(id)sender;
- (IBAction)resetAllTimersAction:(id)sender;

- (IBAction)backToTasksAction:(id)sender;
- (IBAction)saveTaskAction:(id)sender;

@end
