//
//  PageWriter.m
//  PhotoSync
//
//  Created by Dustin Sallings on 2005/2/4.
//  Copyright 2005 Dustin Sallings. All rights reserved.
//

#import "PageWriter.h"


@implementation PageWriter

+(PageWriter *)sharedInstance
{
	static id sharedInstance=nil;
	if(sharedInstance == nil) {
		sharedInstance = [[self alloc] init];
	}
	return sharedInstance;
}

-(void)writePage:(NSString *)srcName dest:(NSString *)destPath
	tokens:(NSDictionary *)t
{
	// NSLog(@"Building a %@ for %@", srcName, destPath);
	
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *path = [mainBundle pathForResource:srcName ofType:@"html"];
	if(path == nil) {
		[NSException raise:@"Missing Resource"
			format:@"Can't get %@ of type html", srcName];
	}
	NSString *srcStr=[[NSString alloc] initWithContentsOfFile:path];
	NSMutableString *str=[[NSMutableString alloc]
		initWithCapacity:[srcStr length]];
	[str setString: srcStr];
	[srcStr release];

	NSEnumerator *e=[t keyEnumerator];
	id key=nil;
	while(key = [e nextObject]) {
		id val=[t objectForKey: key];
		NSRange rng=NSMakeRange(0, [str length]);
		NSString *s=[[NSString alloc] initWithFormat:@"%%%@%%", key];
		[str replaceOccurrencesOfString:s withString:val
			options:NSLiteralSearch range:rng];
		[s release];
	}
	[str writeToFile:destPath atomically:YES];
	[str release];
	[pool release];
}

-(void)copyFile:(NSString *)srcPath to:(NSString *)destPath
{
	NSFileManager *fm=[NSFileManager defaultManager];
	// NSLog(@"Copying %@ to %@", srcPath, destPath);
	[fm copyPath:srcPath toPath:destPath handler:nil];
}

-(void)copyMiscFiles:(NSString *)destPath
{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
	NSBundle *mainBundle = [NSBundle mainBundle];

	NSString *cssSrc=[mainBundle pathForResource:@"style" ofType:@"css"];
	NSString *cssDest=[NSString stringWithFormat:@"%@/style.css", destPath];
	[self copyFile:cssSrc to:cssDest];

	NSString *jsSrc=[mainBundle pathForResource:@"searchfun" ofType:@"txt"];
	NSString *jsDest=[NSString stringWithFormat:@"%@/searchfun.js", destPath];
	[self copyFile:jsSrc to:jsDest];

	NSString *srchSrc=[mainBundle pathForResource:@"search" ofType:@"html"];
	NSString *srchDest=[NSString stringWithFormat:@"%@/search.html", destPath];
	[self copyFile:srchSrc to:srchDest];

	[pool release];
}

@end
