//
//  DownloadDelegate.m
//  PhotoSync
//
//  Created by Dustin Sallings on 2/2/2005.
//  Copyright 2005 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import "DownloadDelegate.h"


@implementation DownloadDelegate

-initWithDest:(NSString *)dest
{
    id rv=[super init];
	_finalDest=dest;
	[_finalDest retain];
    return(rv);
}

- (void)download:(NSURLDownload *)download didCreateDestination:(NSString *)path
{
	NSLog(@"Download created %@", path);
}

- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error
{
    NSLog(@"Download of %@ failed!  Dest was %@.  Error - %@ %@",
        [[download request] URL],
        _finalDest,
        [error localizedDescription],
        [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
	[download release];
}

- (void)downloadDidFinish:(NSURLDownload *)download
{
    NSLog(@"Finished download of %@ at %@", [[download request] URL], _finalDest);
    [download release];
}

- (void)dealloc
{
    if(_finalDest != nil) {
        [_finalDest release];
    }
    [super dealloc];
}

@end
