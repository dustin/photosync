//
//  SyncSubTask.h
//  PhotoSync
//
//  Created by Dustin Sallings on 2005/2/4.
//  Copyright 2005 Dustin Sallings. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Photo.h"
#import "Location.h"

@interface SyncSubTask : NSObject {

	NSString *name;
	Photo *photo;
	Location *location;
	id delegate;

	NSMutableArray *imgsToFetch;
}

-initWithName:(NSString *)n location:(Location *)l
	photo:(NSString *)p delegate:(id)del;

-(NSString *)name;

-(void)run;
-(void)cancel;

@end
