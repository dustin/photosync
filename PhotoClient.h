//
//  PhotoClient.h
//  PhotoSync
//
//  Created by Dustin Sallings on 2/2/2005.
//  Copyright 2005 Dustin Sallings <dustin@spy.net>. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface PhotoClient : NSObject {

}

-(void)authenticateTo:(NSString *)base user:(NSString *)u passwd:(NSString *)p;
-(void)fetchIndexFrom:(NSString *)base to:(NSString *)path;

@end
