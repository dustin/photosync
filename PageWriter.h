//
//  PageWriter.h
//  PhotoSync
//
//  Created by Dustin Sallings on 2005/2/4.
//  Copyright 2005 Dustin Sallings. All rights reserved.
//

#import <AppKit/AppKit.h>
#import "Location.h"
#import "PhotoClient.h"

@interface PageWriter : NSObject {

}

+(PageWriter *)sharedInstance;

-(void)writePage:(NSString *)srcName dest:(NSString *)destPath
	tokens:(NSDictionary *)t;

-(void)setupPages:(PhotoClient *)photoClient location:(Location *)location;

@end
