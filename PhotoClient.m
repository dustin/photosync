//
//  PhotoClient.m
//  PhotoSync
//
//  Created by Dustin Sallings on 2/2/2005.
//  Copyright 2005 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import "PhotoClient.h"
#import "PhotoSync.h"

@implementation PhotoClient

-initWithIndexPath:(NSString *)path
{
	id rv=[super init];
	indexPath=[path retain];
	return rv;
}

-(void)dealloc
{
	NSLog(@"Deallocing %@", self);
	[indexPath release];
	[el release];
	[current release];
	[keywords release];
	[photos release];
	[super dealloc];
}

-(BOOL)tryRequest:(NSURLRequest *)theRequest
{
	BOOL rv=NO;
	NSLog(@"Trying %@", [theRequest URL]);
	NSHTTPURLResponse *resp=nil;
#ifdef GNUSTEP
	URLError *err=nil;
#else
	NSError *err=nil;
#endif
	NSData *body=[NSURLConnection sendSynchronousRequest:theRequest
		returningResponse:&resp error:&err];
	int rc=500;
	if(resp != nil) {
		rc=[resp statusCode];
	}
	if(rc == 200 || (rc >= 300 && rc < 400)) {
		rv=YES;
	} else {
		NSLog(@"%@ failed (rc=%d).", [theRequest URL], rc);
		NSString *str=[[NSString alloc] initWithData: body
			encoding:NSUTF8StringEncoding];
		NSLog(@"Response data:  %@", str);
		[str release];
	}
	return(rv);
}

-(BOOL)authenticateTo:(NSString *)base
	user:(NSString *)u passwd:(NSString *)p forUser:(NSString *)altUser
{
	BOOL rv=NO;
	if(u != nil && [u length] > 0) {
		NSLog(@"Authenticating to %@ as %@", base, u);
		NSURL *url=[[NSURL alloc] initWithString:
			[base stringByAppendingString: @"/login.do"]];
	
		// We should post the credentials so they don't show up in the logs
		NSMutableURLRequest *theRequest=[NSMutableURLRequest requestWithURL:url
			cachePolicy:NSURLRequestReloadIgnoringCacheData
			timeoutInterval:60.0];
		[theRequest setHTTPMethod: @"POST"];
		NSString *bodyString=[[NSString alloc]
			initWithFormat:@"username=%@&password=%@", u, p];
		[theRequest setHTTPBody:
			[bodyString dataUsingEncoding:NSUTF8StringEncoding]];
		[bodyString release];

		rv=[self tryRequest:theRequest];

		if(rv == YES && altUser != nil && [altUser length] > 0) {
			NSLog(@"Attempting to setuid");
			[url release];
			url=[[NSURL alloc] initWithString:
				[NSString stringWithFormat: @"%@/setuid.do?user=%@",
				base, altUser]];
			NSURLRequest *suReq=[NSURLRequest requestWithURL:url
				cachePolicy:NSURLRequestReloadIgnoringCacheData
				timeoutInterval:60.0];
			rv=[self tryRequest: suReq];
		}
		
		[url release];
	} else {
		NSLog(@"Not authenticating (but logging out) %@ - no username", base);
		NSURL *url=[[NSURL alloc] initWithString:
			[base stringByAppendingString: @"/logout.do"]];
		NSURLRequest *req=[NSURLRequest requestWithURL:url
			cachePolicy:NSURLRequestReloadIgnoringCacheData
			timeoutInterval:60.0];
		rv=[self tryRequest: req];
		[url release];
	}
	return(rv);
}

-(void)fetchIndexFrom:(NSString *)base downloadDelegate:(id)del
{
	NSLog(@"Fetching index from %@ to %@", base, indexPath);
	NSURL *u=[[NSURL alloc] initWithString:
		[base stringByAppendingString: @"/export"]];
	NSURLRequest *theRequest=[NSURLRequest requestWithURL:u
		cachePolicy:NSURLRequestReloadIgnoringCacheData
		timeoutInterval:60.0];
	NSURLDownload *dl=[[NSURLDownload alloc]
		initWithRequest:theRequest delegate: del];
	if(dl != nil) {
		[dl setDestination:indexPath allowOverwrite:YES];
	} else {
		NSLog(@"Can't instantiate download from %@.", u);
	}
	[u release];
}

-(void)parseIndex
{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
	NSURL *u=[[NSURL alloc] initFileURLWithPath:indexPath];
	NSXMLParser *xmlp=[[NSXMLParser alloc] initWithContentsOfURL: u];

	[xmlp setDelegate: self];
	if([xmlp parse]) {
		NSLog(@"Parse was successful.");
	} else {
		NSLog(@"Parse was NOT successful.");
	}

	[xmlp release];
	[u release];

	NSLog(@"Parsed %d photos", [photos count]);
	[pool release];
}

-(NSDictionary *)keywords
{
	return(keywords);
}

-(NSSet *)photos
{
	return(photos);
}

//
// This class also acts as a delegate for parsing the XML
//

#define PS_SEC_NONE 0
#define PS_SEC_KEYWORDS 1
#define PS_SEC_ALBUM 2

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
  attributes:(NSDictionary *)attributeDict
{
	if([@"photoexport" isEqualToString: elementName]) {
		section=PS_SEC_NONE;
	} else if([@"photo" isEqualToString: elementName]) {
		[current release];
		current = [[NSMutableDictionary alloc] initWithCapacity:5];
	} else if([@"album" isEqualToString: elementName]) {
		section=PS_SEC_ALBUM;
		[photos release];
		photos = [[NSMutableSet alloc] initWithCapacity:5];
	} else if([@"keywordmap" isEqualToString: elementName]) {
		section=PS_SEC_KEYWORDS;
		[keywords release];
		keywords = [[NSMutableDictionary alloc] initWithCapacity:5];
	} else if([@"keywords" isEqualToString: elementName]) {
		NSMutableSet *ms=[[NSMutableSet alloc] initWithCapacity:5];
		[current setObject: ms forKey:@"keywords"];
		[ms release];
	} else if([@"keyword" isEqualToString: elementName]) {
		NSString *kwid=[attributeDict objectForKey: @"id"];
		NSNumber *n=[[NSNumber alloc] initWithInt: [kwid intValue]];
		if(section == PS_SEC_KEYWORDS) {
			[keywords setObject: [attributeDict objectForKey: @"word"]
				forKey: n];
		} else {
			[[current objectForKey: @"keywords"] addObject: n];
		}
		[n release];
	} else {
		[el release];
		el = [elementName retain];
	}
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if([@"photo" isEqualToString: elementName]) {
		Photo *photo=[[Photo alloc] initWithDict:current keywordMap:keywords];
		// NSLog(@"Finished %@", photo);
		[photos addObject:photo];
		[current release];
		current=nil;
		[el release];
		el=nil;
		[photo release];
	}
}

-(void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
	if(el != nil && current != nil) {
		NSString *trimmed=[string
			stringByTrimmingCharactersInSet:
				[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		NSString *curVal=[current objectForKey:el];
		if(curVal == nil) {
			[current setObject:trimmed forKey:el];
		} else {
			if([trimmed length] > 0) {
				NSString *pad=@"";
				[current setObject:[NSString stringWithFormat:@"%@%@%@",
						curVal, pad, trimmed]
					forKey:el];
			}
		}
	}
}

@end
