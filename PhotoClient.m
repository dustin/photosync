//
//  PhotoClient.m
//  PhotoSync
//
//  Created by Dustin Sallings on 2/2/2005.
//  Copyright 2005 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import "PhotoClient.h"
#import "DownloadDelegate.h"

@implementation PhotoClient

-(void)authenticateTo:(NSString *)base user:(NSString *)u passwd:(NSString *)p
{
	NSLog(@"Authenticating to %@ as %@", base, u);
}

-(void)fetchIndexFrom:(NSString *)base to:(NSString *)path
{
	NSLog(@"Fetching index from %@ to %@", base, path);
	NSURL *u=[[NSURL alloc] initWithString:
		[base stringByAppendingString: @"/export"]];
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:u
		cachePolicy:NSURLRequestReloadIgnoringCacheData
		timeoutInterval:60.0];
	DownloadDelegate *del=[[DownloadDelegate alloc] initWithDest: path];
	NSURLDownload *dl=[[NSURLDownload alloc]
		initWithRequest:theRequest delegate: del];
	if(dl != nil) {
		[dl setDestination:path allowOverwrite:YES];
	} else {
		NSLog(@"Can't instantiate download from %@.", u);
	}
	[del release];
	[u release];
}

@end
