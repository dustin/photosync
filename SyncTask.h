//
//  SyncTask.h
//  PhotoSync
//
//  Created by Dustin Sallings on 2005/2/3.
//  Copyright 2005 Dustin Sallings. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Location.h"
#import "PhotoClient.h"

@interface SyncTask : NSObject {
	PhotoClient *photoClient;
	Location *location;
	id delegate;

	NSMutableArray *subTasks;
}

-initWithLocation:(Location *)loc delegate:(id)del;

-(void)run;
-(void)cancel;
-(void)stopSubTasks:(id)sender;

@end
