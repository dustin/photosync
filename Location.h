//
//  Location.h
//  PhotoSync
//
//  Created by Dustin Sallings on 2005/2/1.
//  Copyright 2005 Dustin Sallings. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Location : NSObject {

	BOOL _active;
	NSString *_url;
	NSString *_username;
	NSString *_password;
	NSString *_forUser;
	NSString *_destDir;

}

-initWithDict:(NSDictionary *)d;
-(NSDictionary *)toDict;

-(BOOL)isActive;
-(void)setActive:(BOOL)to;

-(NSString *)url;
-(void)setUrl:(NSString *)to;

-(NSString *)username;
-(void)setUsername:(NSString *)to;

-(NSString *)password;
-(void)setPassword:(NSString *)to;

-(NSString *)forUser;
-(void)setForUser:(NSString *)to;

-(NSString *)destDir;
-(void)setDestDir:(NSString *)to;

@end
