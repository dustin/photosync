/*
 *  PhotoSync.h
 *  PhotoSync
 *
 *  Created by Dustin Sallings on 2005/2/3.
 *  Copyright 2005 Dustin Sallings. All rights reserved.
 *
 */

#define PS_DID_UPDATE @"PhotoSync_DidUpdate"
#define PS_STOP @"PhotoSync_Stop"

#ifdef GNUSTEP
#import <URLConnection.h>
#import <URLDownload.h>
#import <URLCache.h>
#import <HTTPURLResponse.h>
#define NSURLDownload URLDownload
#define NSURLCache URLCache
#define NSURLConnection URLConnection
#define NSURLRequest URLRequest
#define NSMutableURLRequest MutableURLRequest
#define NSURLResponse URLResponse
#define NSHTTPURLResponse HTTPURLResponse
#define NSURLRequestReloadIgnoringCacheData URLRequestReloadIgnoringCacheData
#define NSURLRequestUseProtocolCachePolicy URLRequestUseProtocolCachePolicy
#endif
