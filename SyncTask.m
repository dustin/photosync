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
#import "PageWriter.h"

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
		user:[location username] passwd:[location password]
		forUser:[location forUser]];
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

-(void)stopSubTasks:(id)sender
{
	NSLog(@"Subtask stopping.");
	// First cancel the objects so we can release
	NSEnumerator *e=[subTasks objectEnumerator];
	id object=nil;
	while(object = [e nextObject]) {
		[object cancel];
	}
	[subTasks removeAllObjects];
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
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		[self release];
	} else {
		// NSLog(@"Starting a subtask");
		SyncSubTask *task=[subTasks lastObject];
		[task retain];
		[subTasks removeLastObject];

		int todo=[[photoClient photos] count];
		int done=todo - [subTasks count];

		[self updateStatus:[NSString
			stringWithFormat:@"Processing %@", [task name]] with:done of:todo];
		[task run];

		[task release];
	}
}

-(void)completedTask:(SyncTask *)task
{
	// NSLog(@"Completed subtask:  %@", task);
	// Figure out where where are
	[self performSelector:@selector(doNextTask:) withObject:self afterDelay:0];
}

-(void)cancel
{
	[self release];
}

-(void)run
{
	NSLog(@"Running %@", self);

	BOOL authed=[photoClient authenticateTo:[location url]
		user:[location username] passwd:[location password]
		forUser:[location forUser]];
	if(authed) {
		NSLog(@"Authenticated");
		// Register myself for stopping
		[[NSNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(stopSubTasks:)
			name: PS_STOP
			object: nil];

		[self updateStatus: [@"Fetching index from "
			stringByAppendingString: [location url]] with:0 of:0];
		[photoClient fetchIndexFrom: [location url] downloadDelegate:self];
	} else {
		NSLog(@"Authentication failed");
	}
}

- (void)download:(NSURLDownload *)download
	didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"Received response from %@, expected length is %d",
		[location url], [response expectedContentLength]);
}

- (void)download:(NSURLDownload *)download
	didReceiveDataOfLength:(unsigned)l
{
	NSLog(@"Received %u bytes of data from %@", l, [location url]);
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
    NSLog(@"Finished downloading index from %@, beginning parse",
		[location url]);
    [photoClient parseIndex];
	[subTasks removeAllObjects];
	NSEnumerator *e=[[photoClient photos] objectEnumerator];
	id object=nil;
	NSLog(@"Creating tasks...");
	while(object = [e nextObject]) {
		NSString *n=[[NSString alloc]
			initWithFormat:@"Photo %d", [object imgId]];
		SyncSubTask *sst=[[SyncSubTask alloc]
			initWithName:n location:location photo:object delegate:self];
		[n release];
		[subTasks addObject:sst];
		[sst release];
	}
	NSLog(@"Created %d tasks", [subTasks count]);

	PageWriter *pw=[PageWriter sharedInstance];
	[pw setupPages:photoClient location:location];

	[pool release];
	[download release];
	[self doNextTask:self];
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{   
	NSLog(@"%@ failed", [[download request] URL]);
	[download release];
}

-(void)dealloc
{
	// NSLog(@"Deallocing %@", self);
	[subTasks release];
	[location release];
	[photoClient release];
	[delegate release];
	[super dealloc];
}

@end
