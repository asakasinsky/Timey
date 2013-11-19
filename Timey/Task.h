//
//  Task.h
//  Timey
//
//  Created by Jader Feijo on 19/11/2013.
//  Copyright (c) 2013 Jader Feijo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Task : NSManagedObject

@property (nonatomic, retain) NSNumber * allocatedTime;
@property (nonatomic, retain) NSNumber * remainingTime;
@property (nonatomic, retain) NSDate * timeStarted;
@property (nonatomic, retain) NSString * title;

@end
