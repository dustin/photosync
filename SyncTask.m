//
//  SyncTask.m
//  PhotoSync
//
//  Created by Dustin Sallings on 2005/2/3.
//  Copyright 2005 Dustin Sallings. All rights reserved.
//

#import "SyncTask.h"
#import "SyncSubTask.h"
#import "PhotoSync.h"

@interface SyncTaskDelegate
-(void)completedTask:(SyncTask *)task;
-(void)updateStatus:(NSString *)msg with:(int)done of:(int)total;
@end

@implementation SyncTask

-initWithLocation:(Location *)loc delegate:(id)del
{
	id rv=[super init];
	subTasks=[[NSMutableArray alloc] init];
	location=[loc retain];
	delegate=[del retain];
	NSString *idxpath=[[location destDir]
		stringByAppendingPathComponent: @"index.xml"];
	photoClient=[[PhotoClient alloc] initWithIndexPath:idxpath];
	
	BOOL authed=[photoClient authenticateTo:[location url]
		user:[location username] passwd:[location password]];
	if(authed) {
		NSLog(@"Authenticated");
	} else {
		NSLog(@"Authentication failed");
		[rv release];
		rv=nil;
	}
	// OK, this is a bit weird, but it happens outside of the
	// run loop, so it's going to retain and release itself
	[rv retain];
	return rv;
}

-(NSString *)description
{
	return([NSString stringWithFormat:@"<SyncTask loc=%@>", location]);
}

-(void)updateStatus:(NSString *)msg with:(int)done of:(int)total
{
	if([delegate respondsToSelector:@selector(updateStatus:with:of:)]) {
		[delegate updateStatus:msg with:done of:total];
	}
}

-(void)updateStatus:(NSString *)msg
{
	[self updateStatus:msg with:0 of:0];
}

-(void)doNextTask:(id)sender
{
	// NSLog(@"doNextTask: called.");
	if([subTasks count] == 0) {
		NSLog(@"All subtasks complete.");
		// At this point, we have nothing left to offer.  Inform the delegate
		// and release self
		if([delegate respondsToSelector:@selector(completedTask:)]) {
			[delegate completedTask:self];
		}
		[self release];
	} else {
		// NSLog(@"Starting a subtask");
		SyncSubTask *task=[subTasks lastObject];
		[task retain];
		[subTasks removeLastObject];

		[self updateStatus:[NSString
			stringWithFormat:@"Processing %@", [task name]]];
		[task run];

		[task release];
	}
}

-(void)completedTask:(SyncTask *)task
{
	// NSLog(@"Completed subtask:  %@", task);
	// Figure out where where are
	int todo=[[photoClient photos] count];
	int done=todo - [subTasks count];
	[self updateStatus:nil with:done of:todo];

	[self doNextTask:self];
}

-(void)run
{
	NSLog(@"Running %@", self);
	[self updateStatus: [@"Fetching index from "
		stringByAppendingString: [location url]]];
	[photoClient fetchIndexFrom: [location url] downloadDelegate:self];
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
    NSLog(@"Finished downloading index from %@, beginning parse",
		[location url]);
	[self updateStatus: @"Parsing index"];
    [photoClient parseIndex];
	[subTasks removeAllObjects];
	NSEnumerator *e=[[photoClient photos] objectEnumerator];
	id object=nil;
	NSLog(@"Creating tasks...");
	while(object = [e nextObject]) {
		NSString *n=[[NSString alloc]
			initWithFormat:@"Photo %d", [object imgId]];
		SyncSubTask *sst=[[SyncSubTask alloc]
			initWithName:n photo:object delegate:self];
		[n release];
		[subTasks addObject:sst];
		[sst release];
	}
	NSLog(@"Created tasks");
	[self doNextTask:self];
}

-(void)dealloc
{
	[subTasks release];
	[location release];
	[photoClient release];
	[delegate release];
	[super dealloc];
}

@end
