//
//  PageWriter.m
//  PhotoSync
//
//  Created by Dustin Sallings on 2005/2/4.
//  Copyright 2005 Dustin Sallings. All rights reserved.
//

#import "PageWriter.h"

// Sort descriptor for performing sort by keyword sets

@interface KwSortDescriptor : NSSortDescriptor {
	NSDictionary *kwMap;
}
-initWithKwMap:(NSDictionary *)km;
@end

@implementation KwSortDescriptor
-initWithKwMap:(NSDictionary *)km
{
	id rv=[super init];
	kwMap=km;
	return rv;
}

- (NSComparisonResult)compareObject:(id)object1 toObject:(id)object2
{
	NSComparisonResult rv=NSOrderedSame;

	int a=[[kwMap objectForKey: object1] count];
	int b=[[kwMap objectForKey: object2] count];
	if(a == b) {
		NSString *s1=(NSString *)object1;
		NSString *s2=(NSString *)object2;
		rv=[s1 compare:s2];
	} else {
		// I want bigger numbers first.
		if(a > b) {
			rv=NSOrderedAscending;
		} else {
			rv=NSOrderedDescending;
		}
	}
	return(rv);
}
@end

// The page writer

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

-(void)ensureDir:(NSString *)path
{
	NSFileManager *fm=[NSFileManager defaultManager];
	BOOL isDir=NO;
	if([fm fileExistsAtPath:path isDirectory:&isDir] && isDir) {
		// NSLog(@"%@ exists", path);
	} else {
		NSLog(@"Creating %@ dir", path);
		if(![fm createDirectoryAtPath:path attributes:nil]) {
			[NSException raise:@"CheckPath" format:@"Couldn't create dir %@",
				path];
		}
	}
}

// Format for the index on the index page
#define INDEX_INDEX_FMT \
	@"<li><a href=\"pages/%@.html\">%@ (%d %@)</a></li>\n"
// Format for the month list on a year page
#define YEAR_MONTH_INDEX_FMT \
	@"<li><a href=\"%@/%02d.html\">%02d (%d %@)</a></li>"
// Format string for lines in the month index
#define MONTH_IMG_INDEX_FMT \
	@"<a href=\"%02d/%d.html\"><img alt=\"%d\" src=\"%02d/%d_tn.%@\"/></a>\n"

-(void)processMonth:(int)month year:(NSString *)year
	monthDict:(NSDictionary *)months index:(NSMutableString *)yearIdx
	location:(Location *)location
{
	PageWriter *pw=[PageWriter sharedInstance];

	NSString *monthStr=[[NSString alloc]
		initWithFormat:@"%@/%02d", year, month];
	NSMutableString *monthIdx=[[NSMutableString alloc] initWithCapacity:256];
	id monthList=[months objectForKey:monthStr];
	if(monthList != nil) {
		[monthIdx setString:@""];

		// The index
		[yearIdx appendFormat:YEAR_MONTH_INDEX_FMT,
			year, month, month, [monthList count],
			([monthList count] == 1 ? @"image":@"images")];

		NSString *monthDir=[[NSString alloc]
			initWithFormat:@"%@/pages/%@/%02d",
			[location destDir], year, month];
		[self ensureDir:monthDir];
		NSString *monthFile=[[NSString alloc]
			initWithFormat:@"%@/pages/%@/%02d.html",
			[location destDir], year, month];

		// Images within a month
		NSEnumerator *ye=[monthList objectEnumerator];
		id photo=nil;
		while(photo = [ye nextObject]) {
			[monthIdx appendFormat:MONTH_IMG_INDEX_FMT,
				month, [photo imgId], [photo imgId], month, [photo imgId],
				[photo extension]];
		}

		NSDictionary *toks=[[NSDictionary alloc] initWithObjectsAndKeys:
			monthIdx, @"IMGS",
			year, @"YEAR",
			[NSString stringWithFormat:@"%02d"], @"MONTH",
			nil];

		[pw writePage:@"month" dest:monthFile tokens:toks];

		[toks release];
		[monthFile release];
		[monthDir release];
	}
	// month check
	[monthStr release];
	[monthIdx release];
}

-(void)writePages:(NSCountedSet *)yearSet months:(NSDictionary *)months
	location:(Location *)location
{
	PageWriter *pw=[PageWriter sharedInstance];
	// Make array versions of the years so we can sort them
	NSMutableArray *years=[[NSMutableArray alloc]
		initWithCapacity:[yearSet count]];
	NSEnumerator *e=[yearSet objectEnumerator];
	id year=nil;
	while(year = [e nextObject]) {
		[years addObject: year];
	}
	[years sortUsingSelector:@selector(compare:)];

	NSMutableString *indexIdx=[[NSMutableString alloc] initWithCapacity:256];
	NSMutableString *yearIdx=[[NSMutableString alloc] initWithCapacity:256];
	[indexIdx setString:@""];

	e=[years objectEnumerator];
	while(year = [e nextObject]) {
		[yearIdx setString:@""];
		NSString *yearDir=[[NSString alloc] initWithFormat:@"%@/pages/%@",
			[location destDir], year];
		NSString *yearFile=[[NSString alloc] initWithFormat:@"%@/pages/%@.html",
			[location destDir], year];
		[self ensureDir:yearDir];

		// Set up the index line
		int yearCount=[yearSet countForObject: year];
		[indexIdx appendFormat:INDEX_INDEX_FMT,
			year, year, yearCount, (yearCount == 1 ? @"image":@"images")];

		// NSLog(@"Doing the months for %@", year);
		// Do the months
		int i=0;
		for(i=1; i<=12; i++) {
			[self processMonth:i year:year monthDict:months index:yearIdx
				location:location];
		} // All possible months

		NSDictionary *toks=[[NSDictionary alloc] initWithObjectsAndKeys:
			year, @"YEAR",
			yearIdx, @"MONTHS",
			nil];
		[pw writePage:@"year" dest:yearFile tokens:toks];
		[toks release];

		[yearDir release];
		[yearFile release];
	}

	// Now write the final index file
	NSString *idxFile=[[NSString alloc] initWithFormat:@"%@/index.html",
		[location destDir]];
	NSDictionary *toks=[[NSDictionary alloc] initWithObjectsAndKeys:
		indexIdx, @"YEARS", nil];

	[pw writePage:@"index" dest:idxFile tokens:toks];
	[pw copyMiscFiles:[location destDir]];

	[toks release];
	[idxFile release];
	[indexIdx release];
	[yearIdx release];
	[years release];
}

// Build the javascript search data
-(void)writeSearchData:(PhotoClient *)photoClient location:(Location *)location
{
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];
	// We're going to build three basic data structure here.
	// We start by indexing the images -> keyword mappings
	NSMutableDictionary *kws=[[NSMutableDictionary alloc] initWithCapacity:512];
	NSEnumerator *e=[[photoClient photos] objectEnumerator];
	id photo=nil;
	while(photo = [e nextObject]) {
		NSEnumerator *ke=[[photo keywordStrings] objectEnumerator];
		id kw=nil;
		while(kw = [ke nextObject]) {
			NSMutableArray *imgs=[kws objectForKey:kw];
			if(imgs == nil) {
				imgs=[[NSMutableArray alloc] initWithCapacity:16];
				[kws setObject:imgs forKey:kw];
				[imgs release];
			}
			[imgs addObject: photo];
		}
	}

	// Sorted list of keywords by use
	KwSortDescriptor *ksd=[[KwSortDescriptor alloc] initWithKwMap:kws];
	NSArray *sortDescriptors=[[NSArray alloc] initWithObjects: ksd, nil];
	NSMutableArray *sortedKeys=[[NSMutableArray alloc]
		initWithCapacity:[kws count]];
	[sortedKeys addObjectsFromArray:[kws allKeys]];
	[sortedKeys sortUsingDescriptors: sortDescriptors];

	// quoted strings
	NSMutableArray *quoteKws=[[NSMutableArray alloc]
		initWithCapacity:[sortedKeys count]];
	e=[sortedKeys objectEnumerator];
	id kw=nil;
	while(kw = [e nextObject]) {
		NSString *qkw=[[NSString alloc] initWithFormat:@"\"%@\"", kw];
		[quoteKws addObject: qkw];
		[qkw release];
	}

	NSMutableString *outString=[[NSMutableString alloc] initWithCapacity:8192];
	[outString appendFormat:@"keywords=[%@];\n",
		[quoteKws componentsJoinedByString:@", "]];

	// keyword position from the sorted list to image mapping
	[outString appendString:@"imgs = new Array();\n"];
	e=[sortedKeys objectEnumerator];
	kw=nil;
	int i=0;
	while(kw = [e nextObject]) {
		NSMutableArray *photos=[kws objectForKey:kw];
		[photos sortUsingSelector:@selector(compare:)];
		NSMutableArray *ids=[[NSMutableArray alloc]
			initWithCapacity:[photos count]];
		NSEnumerator *pe=[photos objectEnumerator];
		photo=nil;
		while(photo = [pe nextObject]) {
			NSString *idStr=[[NSString alloc]
				initWithFormat:@"%d", [photo imgId]];
			[ids addObject: idStr];
			[idStr release];
		}
		[ids sortUsingSelector:@selector(compare:)];
		[outString appendFormat:@"imgs[%d]=[%@];\n", i,
			[ids componentsJoinedByString:@", "]];
		[ids release];
		i++;
	}

	// Photo location mapping
	e=[[photoClient photos] objectEnumerator];
	photo=nil;
	[outString appendString:@"photloc = new Array();\n"];
	while(photo = [e nextObject]) {
		[outString appendFormat:@"photloc[%d]='%04d/%02d';\n",
			[photo imgId], [photo year], [photo month]];
	}

	// Write it out
	NSString *destFile=[[NSString alloc] initWithFormat:@"%@/searchdata.js",
		[location destDir]];
	[outString writeToFile:destFile atomically:YES];

	[outString release];
	[destFile release];
	[quoteKws release];
	[sortDescriptors release];
	[sortedKeys release];
	[ksd release];
	[kws release];
	[pool release];
}

// Build all pages
-(void)setupPages:(PhotoClient *)photoClient location:(Location *)location
{
	NSLog(@"Setting up the main pages in %@", [location destDir]);
	NSString *pagesDir=[[NSString alloc] initWithFormat:@"%@/pages",
		[location destDir]];
	[self ensureDir:pagesDir];
	NSCountedSet *yearSet=[[NSCountedSet alloc] initWithCapacity:50];
	NSMutableDictionary *imgLists=[[NSMutableDictionary alloc]
		initWithCapacity:500];

	NSEnumerator *e=[[photoClient photos] objectEnumerator];
	id photo=nil;
	while(photo = [e nextObject]) {
		NSString *year=[[NSString alloc] initWithFormat:@"%04d", [photo year]];
		NSString *month=[[NSString alloc] initWithFormat:@"%04d/%02d",
			[photo year], [photo month]];

		[yearSet addObject: year];

		NSMutableArray *imgList=[imgLists objectForKey:month];
		if(imgList == nil) {
			imgList=[[NSMutableArray alloc] initWithCapacity:128];
			[imgLists setObject:imgList forKey:month];
			[imgList release];
		}
		[imgList addObject: photo];
		
		[month release];
		[year release];
	}

	// Now we're going to go through the values and sort them.
	e=[imgLists objectEnumerator];
	id imgList=nil;
	while(imgList = [e nextObject]) {
		[imgList sortUsingSelector:@selector(compare:)];
	}

	// Now that we have our structures, let's write out some pages
	[self writePages:yearSet months:imgLists location:location];

	[imgLists release];
	[yearSet release];
	[pagesDir release];

	[self writeSearchData:photoClient location:location];
}

@end
