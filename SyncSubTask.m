//
//  SyncSubTask.m
//  PhotoSync
//
//  Created by Dustin Sallings on 2005/2/4.
//  Copyright 2005 Dustin Sallings. All rights reserved.
//

#import "SyncSubTask.h"
#import "SyncTask.h"

@implementation SyncSubTask

-initWithName:(NSString *)n photo:(NSString *)p delegate:(id)del
{
	id rv=[super init];
	name=[n retain];
	photo=[p retain];
	delegate=[del retain];
	// Like synctask, I'll retain myself
	[self retain];
	return rv;
}

-(NSString *)name
{
	return name;
}

-(void)run
{
	if([delegate respondsToSelector:@selector(completedTask:)]) {
		// [delegate completedTask:self];
		[delegate performSelector: @selector(completedTask:)
			withObject:self
			afterDelay:2];
	}
	[self release];
}

-(void)dealloc
{
	[name release];
	[photo release];
	[delegate release];
	[super dealloc];
}

@end
