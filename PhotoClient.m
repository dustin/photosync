//
//  PhotoClient.m
//  PhotoSync
//
//  Created by Dustin Sallings on 2/2/2005.
//  Copyright 2005 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import "PhotoClient.h"

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

-(BOOL)authenticateTo:(NSString *)base user:(NSString *)u passwd:(NSString *)p
{
	NSLog(@"Authenticating to %@ as %@", base, u);
	BOOL rv=FALSE;
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

	NSHTTPURLResponse *resp=nil;
	NSError *err=nil;
	[NSURLConnection sendSynchronousRequest:theRequest
		returningResponse:&resp error:&err];
	int rc=500;
	if(resp != nil) {
		rc=[resp statusCode];
	}
	if(rc == 200){
		rv=TRUE;
	} else {
		NSLog(@"Looks like we didn't authenticate (rc=%d).", rc);
	}

	[url release];
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

-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qualifiedName
  attributes:(NSDictionary *)attributeDict
{
	if([@"photo" isEqualToString: elementName]) {
		[current release];
		current = [[NSMutableDictionary alloc] initWithCapacity:5];
	} else if([@"album" isEqualToString: elementName]) {
		[photos release];
		photos = [[NSMutableSet alloc] initWithCapacity:5];
	} else if([@"keywordmap" isEqualToString: elementName]) {
		[keywords release];
		keywords = [[NSMutableDictionary alloc] initWithCapacity:5];
	} else if([@"keywords" isEqualToString: elementName]) {
		[current setObject: [[NSMutableSet alloc] initWithCapacity:5]
			forKey:@"keywords"];
	} else if([@"keyword" isEqualToString: elementName]) {
		if([attributeDict objectForKey: @"id"] != nil) {
			NSString *kwid=[attributeDict objectForKey: @"id"];
			NSNumber *n=[[NSNumber alloc] initWithInt: [kwid intValue]];
			[keywords setObject: [attributeDict objectForKey: @"word"]
				forKey: n];
			[n release];
		} else {
			NSString *kwid=[attributeDict objectForKey: @"kwid"];
			NSNumber *n=[[NSNumber alloc] initWithInt: [kwid intValue]];
			[[current objectForKey: @"keywords"] addObject: n];
			[n release];
		}
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
