//
//  Photo.m
//  PhotoSync
//
//  Created by Dustin Sallings on 2005/2/2.
//  Copyright 2005 Dustin Sallings. All rights reserved.
//

#import "Photo.h"


@implementation Photo

-initWithDict:(NSDictionary *)d
{
	id rv=[super init];
	NSAutoreleasePool *pool=[[NSAutoreleasePool alloc] init];

	NSEnumerator *enumerator = [d keyEnumerator];
	id key=nil;
	while((key = [enumerator nextObject]) != nil) {
		[self takeValue: [d objectForKey:key] forKey:key];
	}

	NSArray *parts=[taken componentsSeparatedByString:@"-"];
	year=[[parts objectAtIndex:0] intValue];
	month=[[parts objectAtIndex:1] intValue];
	day=[[parts objectAtIndex:2] intValue];

	[pool release];
	return rv;
}

-(NSComparisonResult)compare:(Photo *)to
{
	return([taken compare:[to taken]]);
}

-(NSDictionary *)tokens
{
	NSDictionary *rv=[NSDictionary dictionaryWithObjectsAndKeys:
		[NSString stringWithFormat:@"%d", imgId], @"IMGID",
		taken, @"TAKEN",
		[self keywordString], @"KEYWORDS",
		descr, @"DESCR",
		[NSString stringWithFormat:@"%04d", year], @"YEAR",
		[NSString stringWithFormat:@"%02d", month], @"MONTH",
		nil];
	return rv;
}

-(NSString *)keywordString
{
	NSMutableArray *a=[[NSMutableArray alloc]
		initWithCapacity:[keywordStrings count]];
	NSEnumerator *e=[keywordStrings objectEnumerator];
	id ob=nil;
	while(ob = [e nextObject]) {
		[a addObject: ob];
	}
	[a sortUsingSelector:@selector(compare:)];
	NSString *rv=[a componentsJoinedByString:@" "];
	[a release];
	return(rv);
}

-(int)year
{
	return year;
}

-(int)month
{
	return month;
}

-(int)day
{
	return day;
}

-(NSSet *)keywordStrings
{
	return(keywordStrings);
}

- (void)handleTakeValue:(id)value forUnboundKey:(NSString *)key
{
	NSLog(@"Warning!  Taking value (%@) for unknown key (%@)", value, key);
}

-(NSString *)description
{
	return([NSString stringWithFormat:@"<Photo id=%d, dims=%@>", imgId,
		[self dims], nil]);
}

-(NSString *)dims
{
	return([NSString stringWithFormat:@"%dx%d", width, height, nil]);
}

-(void)dealloc
{
	[addedby release];
	[taken release];
	[ts release];
	[descr release];
	[extension release];
	[cat release];

	[keywordStrings release];
	[super dealloc];
}

-(void)setId:(int)to
{
	imgId=to;
}

- (int)imgId {
    return imgId;
}

- (void)setImgId:(int)newImgId {
    if (imgId != newImgId) {
        imgId = newImgId;
    }
}

- (int)size {
    return size;
}

- (void)setSize:(int)newSize {
    if (size != newSize) {
        size = newSize;
    }
}

- (int)width {
    return width;
}

- (void)setWidth:(int)newWidth {
    if (width != newWidth) {
        width = newWidth;
    }
}

- (int)height {
    return height;
}

- (void)setHeight:(int)newHeight {
    if (height != newHeight) {
        height = newHeight;
    }
}

- (int)tnwidth {
    return tnwidth;
}

- (void)setTnwidth:(int)newTnwidth {
    if (tnwidth != newTnwidth) {
        tnwidth = newTnwidth;
    }
}

- (int)tnheight {
    return tnheight;
}

- (void)setTnheight:(int)newTnheight {
    if (tnheight != newTnheight) {
        tnheight = newTnheight;
    }
}

- (NSString *)addedby {
    return [[addedby retain] autorelease];
}

- (void)setAddedby:(NSString *)newAddedby {
    if (addedby != newAddedby) {
        [addedby release];
        addedby = [newAddedby copy];
    }
}

- (NSString *)taken {
    return [[taken retain] autorelease];
}

- (void)setTaken:(NSString *)newTaken {
    if (taken != newTaken) {
        [taken release];
        taken = [newTaken copy];
    }
}

- (NSString *)ts {
    return [[ts retain] autorelease];
}

- (void)setTs:(NSString *)newTs {
    if (ts != newTs) {
        [ts release];
        ts = [newTs copy];
    }
}

- (NSString *)descr {
    return [[descr retain] autorelease];
}

- (void)setDescr:(NSString *)newDescr {
    if (descr != newDescr) {
        [descr release];
        descr = [newDescr copy];
    }
}

- (NSString *)extension {
    return [[extension retain] autorelease];
}

- (void)setExtension:(NSString *)newExtension {
    if (extension != newExtension) {
        [extension release];
        extension = [newExtension copy];
    }
}

- (NSString *)cat {
    return [[cat retain] autorelease];
}

- (void)setCat:(NSString *)newCat {
    if (cat != newCat) {
        [cat release];
        cat = [newCat copy];
    }
}

- (NSSet *)keywords {
    return [[keywordStrings retain] autorelease];
}

- (void)setKeywords:(NSSet *)newKeywords {
    if (keywordStrings != newKeywords) {
        [keywordStrings release];
        keywordStrings = [newKeywords copy];
    }
}

@end
