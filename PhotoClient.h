//
//  PhotoClient.h
//  PhotoSync
//
//  Created by Dustin Sallings on 2/2/2005.
//  Copyright 2005 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Photo.h"

@interface PhotoClient : NSObject {

	NSString *el;
	NSMutableDictionary *current;
	NSMutableDictionary *keywords;

	NSMutableSet *photos;

}

-(BOOL)authenticateTo:(NSString *)base user:(NSString *)u passwd:(NSString *)p;
-(void)fetchIndexFrom:(NSString *)base to:(NSString *)path;

// Parse the index
-(void)parseIndex:(NSString *)path;

-(NSDictionary *)keywords;
-(NSSet *)photos;

@end
