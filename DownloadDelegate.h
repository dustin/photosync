//
//  DownloadDelegate.h
//  PhotoSync
//
//  Created by Dustin Sallings on 2/2/2005.
//  Copyright 2005 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DownloadDelegate : NSObject {
	NSString *_finalDest;
}

-initWithDest:(NSString *)dest;

- (void)download:(NSURLDownload *)download didCreateDestination:(NSString *)path;
- (void)download:(NSURLDownload *)download didFailWithError:(NSError *)error;
- (void)downloadDidFinish:(NSURLDownload *)download;

@end
