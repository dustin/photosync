//
//  Photo.h
//  PhotoSync
//
//  Created by Dustin Sallings on 2005/2/2.
//  Copyright 2005 Dustin Sallings. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Photo : NSObject {

	int imgId;
	int size;
	int width;
	int height;
	int tnwidth;
	int tnheight;

	int year;
	int month;
	int day;

	NSString *addedby;
	NSString *taken;
	NSString *ts;
	NSString *descr;
	NSString *extension;
	NSString *cat;

	NSSet *keywords;
	NSSet *keywordStrings;

}

-initWithDict:(NSDictionary *)d keywordMap:(NSDictionary *)kw;
-(NSString *)dims;
-(NSSet *)keywordStrings;

-(NSComparisonResult)compare:(Photo *)to;

-(NSDictionary *)tokens;

-(int)year;
-(int)month;
-(int)day;

-(NSString *)keywordString;

-(void)setId:(int)to;

- (int)imgId;
- (void)setImgId:(int)newImgId;
- (int)size;
- (void)setSize:(int)newSize;
- (int)width;
- (void)setWidth:(int)newWidth;
- (int)height;
- (void)setHeight:(int)newHeight;
- (int)tnwidth;
- (void)setTnwidth:(int)newTnwidth;
- (int)tnheight;
- (void)setTnheight:(int)newTnheight;
- (NSString *)addedby;
- (void)setAddedby:(NSString *)newAddedby;
- (NSString *)taken;
- (void)setTaken:(NSString *)newTaken;
- (NSString *)ts;
- (void)setTs:(NSString *)newTs;
- (NSString *)descr;
- (void)setDescr:(NSString *)newDescr;
- (NSString *)extension;
- (void)setExtension:(NSString *)newExtension;
- (NSString *)cat;
- (void)setCat:(NSString *)newCat;
- (NSSet *)keywords;
- (void)setKeywords:(NSSet *)newKeywords;

@end
