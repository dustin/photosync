//
//  SyncSubTask.m
//  PhotoSync
//
//  Created by Dustin Sallings on 2005/2/4.
//  Copyright 2005 Dustin Sallings. All rights reserved.
//

#import "SyncSubTask.h"
#import "SyncTask.h"
#import "Location.h"

@implementation SyncSubTask

-initWithName:(NSString *)n location:(Location *)l
	photo:(NSString *)p delegate:(id)del
{
	id rv=[super init];
	location=[l retain];
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

-(void)checkPath
{
	NSFileManager *fm=[NSFileManager defaultManager];
	NSString *yearDir=[[NSString alloc] initWithFormat:@"%@/pages/%d",
		[location destDir], [photo year]];

	BOOL isDir=NO;
	if([fm fileExistsAtPath:yearDir isDirectory:&isDir] && isDir) {
		// Already there
	} else {
		NSLog(@"Need to create %@", yearDir);
		if(![fm createDirectoryAtPath:yearDir attributes:nil]) {
			[NSException raise:@"CheckPath" format:@"Couldn't create dir %@",
				yearDir];
		}
	}

	NSString *monthDir=[[NSString alloc] initWithFormat:@"%@/pages/%d/%d",
		[location destDir], [photo year], [photo month]];
	if([fm fileExistsAtPath:monthDir isDirectory:&isDir] && isDir) {
		// Already there
	} else {
		NSLog(@"Need to create %@", monthDir);
		if(![fm createDirectoryAtPath:monthDir attributes:nil]) {
			[NSException raise:@"CheckPath" format:@"Couldn't create dir %@",
				monthDir];
		}
	}

	[yearDir release];
	[monthDir release];
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
	} else {
		[NSException raise:@"FetchImage" format:@"Couldn't fetch image from %@",
			u];
	}
	[url release];
}

-(void)fetchNormal:(NSString *)path
{
	NSString *u=[[NSString alloc]
		initWithFormat:@"%@/PhotoServlet?id=%d&thumbnail=1",
			[location url], [photo imgId]];
	[self fetch:u to:path];
	[u release];
}

-(void)fetchTn:(NSString *)path
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
	[self release];
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
	// NSLog(@"%@ completed successfully", [[download request] URL]);
	[download release];
	imgsToFetch--;
	if(imgsToFetch == 0) {
		[self complete];
	}
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
	NSLog(@"%@ failed", [[download request] URL]);
	[download release];
	imgsToFetch--;
	if(imgsToFetch == 0) {
		[self complete];
	}
}

-(void)run
{
	imgsToFetch=0;

	// Start by figuring out what we need to do
	[self checkPath];

	// See if the images are there
	NSFileManager *fm=[NSFileManager defaultManager];
	NSString *normalFn=[[NSString alloc]
		initWithFormat:@"%@/pages/%d/%d/%d_normal.jpg",
			[location destDir], [photo year], [photo month], [photo imgId]];
	NSString *tnFn=[[NSString alloc]
		initWithFormat:@"%@/pages/%d/%d/%d_tn.jpg",
			[location destDir], [photo year], [photo month], [photo imgId]];

	if(![fm fileExistsAtPath:normalFn]) {
		imgsToFetch++;
		[self fetchNormal:normalFn];
	}
	if(![fm fileExistsAtPath:tnFn]) {
		imgsToFetch++;
		[self fetchTn:tnFn];
	}

	[normalFn release];
	[tnFn release];

	// If we don't have anything to do go ahead and shut down.
	if(imgsToFetch == 0) {
		[self complete];
	}
}

-(void)dealloc
{
	[location release];
	[name release];
	[photo release];
	[delegate release];
	[super dealloc];
}

@end
