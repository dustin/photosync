//
//  SyncSubTask.m
//  PhotoSync
//
//  Created by Dustin Sallings on 2005/2/4.
//  Copyright 2005 Dustin Sallings. All rights reserved.
//

#import "PhotoSync.h"
#import "SyncSubTask.h"
#import "SyncTask.h"
#import "Location.h"
#import "PageWriter.h"

@interface SyncSubTaskDelegate
-(void)completedTask:(id)sender;
@end

@implementation SyncSubTask

-initWithName:(NSString *)n location:(Location *)l
	photo:(NSString *)p delegate:(id)del
{
	id rv=[super init];
	location=[l retain];
	name=[n retain];
	photo=[p retain];
	delegate=[del retain];
	imgsToFetch=[[NSMutableArray alloc] init];
	// Like synctask, I'll retain myself
	[self retain];
	return rv;
}

-(NSString *)name
{
	return name;
}

-(void)fetch:(NSString *)u to:(NSString *)dest
{
	NSURL *url=[[NSURL alloc] initWithString:u];
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
		cachePolicy:NSURLRequestUseProtocolCachePolicy
		timeoutInterval:60.0];
	NSURLDownload *dl=[[NSURLDownload alloc]
		initWithRequest:theRequest delegate: self];
	if(dl != nil) {
		[dl setDestination:dest allowOverwrite:YES];
		[imgsToFetch addObject: dl];
	} else {
		[NSException raise:@"FetchImage" format:@"Couldn't fetch image from %@",
			u];
	}
	[url release];
}

-(void)fetchTn:(NSString *)path
{
	NSString *u=[[NSString alloc]
		initWithFormat:@"%@/PhotoServlet?id=%d&thumbnail=1",
			[location url], [photo imgId]];
	[self fetch:u to:path];
	[u release];
}

-(void)fetchNormal:(NSString *)path
{
	// XXX:  hard-coded scale
	NSString *u=[[NSString alloc]
		initWithFormat:@"%@/PhotoServlet?id=%d&scale=800x600",
			[location url], [photo imgId]];
	[self fetch:u to:path];
	[u release];
}

-(void)complete
{
	if([delegate respondsToSelector:@selector(completedTask:)]) {
		[delegate completedTask:self];
	}
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[self release];
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
	// NSLog(@"%@ completed successfully", [[download request] URL]);
	[imgsToFetch removeObject: download];
	[download release];
	if([imgsToFetch count] == 0) {
		[self complete];
	}
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
	NSLog(@"%@ failed", [[download request] URL]);
	[imgsToFetch removeObject: download];
	[download release];
	if([imgsToFetch count] == 0) {
		[self complete];
	}
}

-(void)stopDownloads:(id)sender
{
	NSLog(@"Subtask needs to stop downloads");
	NSEnumerator *e=[imgsToFetch objectEnumerator];
	id dl=nil;
	while(dl = [e nextObject]) {
		NSLog(@"Cancelling download of %@", [[dl request] URL]);
		[dl cancel];
	}
	[imgsToFetch removeAllObjects];
	[self complete];
}

-(void)run
{
	// See if the images are there
	NSFileManager *fm=[NSFileManager defaultManager];
	NSString *normalFn=[[NSString alloc]
		initWithFormat:@"%@/pages/%04d/%02d/%d_normal.jpg",
			[location destDir], [photo year], [photo month], [photo imgId]];
	NSString *tnFn=[[NSString alloc]
		initWithFormat:@"%@/pages/%04d/%02d/%d_tn.jpg",
			[location destDir], [photo year], [photo month], [photo imgId]];

	if(![fm fileExistsAtPath:normalFn]) {
		[self fetchNormal:normalFn];
	}
	if(![fm fileExistsAtPath:tnFn]) {
		[self fetchTn:tnFn];
	}

	NSString *pageLoc=[[NSString alloc]
		initWithFormat:@"%@/pages/%04d/%02d/%d.html",
			[location destDir], [photo year], [photo month], [photo imgId]];

	PageWriter *pw=[PageWriter sharedInstance];
	[pw writePage:@"page" dest:pageLoc tokens:[photo tokens]];

	[pageLoc release];
	[normalFn release];
	[tnFn release];

	// If we don't have anything to do go ahead and shut down.
	if([imgsToFetch count] == 0) {
		[self complete];
	} else {
		[[NSNotificationCenter defaultCenter]
			addObserver:self
			selector:@selector(stopDownloads:)
			name: PS_STOP
			object: nil];
	}

}

-(void)cancel
{
	[self release];
}

-(void)dealloc
{
	[imgsToFetch release];
	[location release];
	[name release];
	[photo release];
	[delegate release];
	[super dealloc];
}

@end
