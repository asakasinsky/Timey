//
//  AppDelegate.m
//  Timey
//
//  Created by Jader Feijo on 18/11/2013.
//  Copyright (c) 2013 Jader Feijo. All rights reserved.
//

#import "AppDelegate.h"
#import "StatusItemView.h"
#import "Task+Additions.h"

@interface AppDelegate () {
	NSArray *tasks;
}

@end

@implementation AppDelegate

@synthesize popover;
@synthesize containerView;
@synthesize tasksView;
@synthesize tasksTableView;
@synthesize addTaskView;
@synthesize taskNameTextField;
@synthesize taskTimeTextField;
@synthesize statusItemView = _statusItemView;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

//
// NSApplicationDelegate Methods
//
#pragma mark - NSApplicationDelegate Methods -

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	NSLog(@"%@", [[self applicationFilesDirectory] path]);
	
	[self statusItemView];
	
	[tasksTableView setTarget:self];
	[tasksTableView setDoubleAction:@selector(tasksTableViewDoubleClickAction:)];
	
	[containerView addSubview:tasksView];
}

- (void)applicationDidResignActive:(NSNotification *)notification {
	[[self popover] close];
	[_statusItemView setHighlighted:NO];
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
		
        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }
		
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
		
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }
	
    return NSTerminateNow;
}

//
// NSWindowDelegate Methods
//
#pragma mark - NSWindowDelegate Methods -

- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

//
// NSTableViewDataSource Methods
//
#pragma mark - NSTableViewDataSource Methods -

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
	return [tasks count];
}

//
// NSTableViewDelegate Methods
//
#pragma mark - NSTableViewDelegate Methods -

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
	NSView *view = [tableView makeViewWithIdentifier:@"TaskCell" owner:self];
	
	NSTextField *cellTaskNameTextField = [view viewWithTag:1];
	NSTextField *cellTimerTextField = [view viewWithTag:2];
	NSImageView *cellTimeRunningImageView = [view viewWithTag:3];
	
	Task *task = [tasks objectAtIndex:row];
	[cellTaskNameTextField setStringValue:[task title]];
	[cellTimerTextField setStringValue:[task formattedTimeLeft]];
	[cellTimeRunningImageView setHidden:![task isRunning]];
	
	return view;
}

//
// AppDelegate Private Methods
//
#pragma mark - AppDelegate Private Methods -

- (NSURL *)applicationFilesDirectory {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.movinpixel.Timey"];
}

- (IBAction)togglePanel:(id)sender {
	if (![(StatusItemView *)sender isHighlighted]) {
		[[NSApplication sharedApplication] activateIgnoringOtherApps:YES];
		[[self popover] showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinYEdge];
		[self reloadData];
	} else {
		[[self popover] close];
	}
	[(StatusItemView *)sender setHighlighted:![(StatusItemView *)sender isHighlighted]];
}

- (IBAction)tasksTableViewDoubleClickAction:(id)sender {
	if ([[self tasksTableView] clickedRow] >= 0) {
		Task *task = [tasks objectAtIndex:[[self tasksTableView] clickedRow]];
		
		if ([task isRunning]) {
			[task stopTimer];
		} else {
			for (Task *t in tasks) {
				[task stopTimer];
			}
			[task startTimer];
		}
		
		[[self tasksTableView] reloadData];
	}
}

- (void)reloadData {
	NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"Task"];
	tasks = [[[self managedObjectContext] executeFetchRequest:request error:nil] sortedArrayUsingSelector:@selector(compareTitle:)];
	[[self tasksTableView] reloadData];
}

- (void)popToTasksView {
	[containerView addSubview:tasksView];
	[tasksView setFrameOrigin:NSMakePoint(containerView.frame.size.width * -1, 0)];
	
	[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
		[context setDuration:0.5];
		[[addTaskView animator] setFrameOrigin:NSMakePoint(containerView.frame.size.width, 0)];
		[[tasksView animator] setFrameOrigin:NSMakePoint(0, 0)];
	} completionHandler:^{
		[addTaskView removeFromSuperview];
	}];
}

//
// AppDelegate Methods
//
#pragma mark - AppDelegate Methods -

- (IBAction)saveAction:(id)sender {
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (IBAction)addTaskAction:(id)sender {
	[containerView addSubview:addTaskView];
	[addTaskView setFrameOrigin:NSMakePoint(containerView.frame.size.width, 0)];
	
	[taskNameTextField setStringValue:@"New Task"];
	[taskTimeTextField setStringValue:@"02:00"];
	
	[NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
		[context setDuration:0.5];
		[[tasksView animator] setFrameOrigin:NSMakePoint(tasksView.frame.size.width * -1, 0)];
		[[addTaskView animator] setFrameOrigin:NSMakePoint(0, 0)];
	} completionHandler:^{
		[tasksView removeFromSuperview];
		[taskNameTextField becomeFirstResponder];
	}];
}

- (IBAction)removeTaskAction:(id)sender {
	if ([[self tasksTableView] selectedRow] >= 0) {
		Task *task = [tasks objectAtIndex:[[self tasksTableView] selectedRow]];
		[[self managedObjectContext] deleteObject:task];
		[self saveAction:sender];
		[self reloadData];
	}
}

- (IBAction)resetTimerAction:(id)sender {
	if ([[self tasksTableView] selectedRow] >= 0) {
		Task *task = [tasks objectAtIndex:[[self tasksTableView] selectedRow]];
		[task resetTimer];
		[[self tasksTableView] reloadData];
	}
}

- (IBAction)resetAllTimersAction:(id)sender {
	for (Task *task in tasks) {
		[task resetTimer];
	}
	[[self tasksTableView] reloadData];
}

- (IBAction)backToTasksAction:(id)sender {
	[self popToTasksView];
}

- (IBAction)saveTaskAction:(id)sender {
	Task *task = [[Task alloc] initWithEntity:[NSEntityDescription entityForName:@"Task" inManagedObjectContext:[self managedObjectContext]] insertIntoManagedObjectContext:[self managedObjectContext]];
	[task setTitle:[taskNameTextField stringValue]];
	[task setFormattedAllocatedTime:[taskTimeTextField stringValue]];
	[task resetTimer];
	[self saveAction:sender];
	
	[self reloadData];
	[self popToTasksView];
}

//
// AppDelegate Properties
//
#pragma mark - AppDelegate Properties -

- (StatusItemView *)statusItemView {
	if (!_statusItemView) {
		_statusItemView = [[StatusItemView alloc] init];
		[_statusItemView setImage:[NSImage imageNamed:@"StatusIcon"]];
		[_statusItemView setTarget:self];
		[_statusItemView setAction:@selector(togglePanel:)];
	}
	return _statusItemView;
}

- (NSManagedObjectModel *)managedObjectModel {
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Timey" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Timey.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

- (NSManagedObjectContext *)managedObjectContext {
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

@end
