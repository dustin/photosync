//
//  SyncSubTask.h
//  PhotoSync
//
//  Created by Dustin Sallings on 2005/2/4.
//  Copyright 2005 Dustin Sallings. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Photo.h"

@interface SyncSubTask : NSObject {

	NSString *name;
	Photo *photo;
	id delegate;
}

-initWithName:(NSString *)n photo:(NSString *)p delegate:(id)del;

-(NSString *)name;

-(void)run;

@end
