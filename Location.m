//
//  Location.m
//  PhotoSync
//
//  Created by Dustin Sallings on 2005/2/1.
//  Copyright 2005 Dustin Sallings. All rights reserved.
//

#import "Location.h"


@implementation Location

-(id)init
{
	id rv=[super init];
	_active = TRUE;
	_url=@"";
	_username=@"";
	_password=@"";
	_forUser=@"";
	_destDir=@"";

	return rv;
}

-(NSString *)description
{
	return([NSString stringWithFormat:@"<Location url=``%@'' rc=%u>",
		_url, [self retainCount], nil]);
}

-(id)initWithDict:(NSDictionary *)d
{
	self=[super init];
	_active = [[d objectForKey:@"active"] boolValue];
	_url=[[d objectForKey:@"url"] retain];
	_username=[[d objectForKey:@"username"] retain];
	_password=[[d objectForKey:@"password"] retain];
	_forUser=[[d objectForKey:@"forUser"] retain];
	_destDir=[[d objectForKey:@"destDir"] retain];
	
	return self;
}

-(NSDictionary *)toDict
{
	NSDictionary *rv=[NSDictionary dictionaryWithObjectsAndKeys:
		[NSNumber numberWithBool: _active], @"active",
		_url, @"url",
		_username, @"username",
		_password, @"password",
		_forUser, @"forUser",
		_destDir, @"destDir",
		nil];
	return(rv);
}

-(void)dealloc
{
	if(_url != nil) {
		[_url release];
		_url=nil;
	}
	if(_username != nil) {
		[_username release];
		_username=nil;
	}
	if(_password != nil) {
		[_password release];
		_password=nil;
	}
	if(_forUser != nil) {
		[_forUser release];
		_forUser=nil;
	}
	if(_destDir != nil) {
		[_destDir release];
		_destDir=nil;
	}
	[super dealloc];
}

-(BOOL)active
{
	return _active;
}

-(void)setActive:(BOOL)to
{
	_active = to;
}

-(NSString *)url
{
	return _url;
}

-(void)setUrl:(NSString *)to
{
	if(_url != nil) {
		[_url release];
	}
	[to retain];
	_url = to;
}

-(NSString *)username
{
	return _username;
}

-(void)setUsername:(NSString *)to
{
	if(_username != nil) {
		[_username release];
	}
	[to retain];
	_username = to;
}

-(NSString *)password
{
	return _password;
}

-(void)setPassword:(NSString *)to
{
	if(_password != nil) {
		[_password release];
	}
	[to retain];
	_password = to;
}

-(NSString *)forUser
{
	return _forUser;
}

-(void)setForUser:(NSString *)to
{
	if(_forUser != nil) {
		[_forUser release];
	}
	[to retain];
	_forUser = to;
}

-(NSString *)destDir
{
	return _destDir;
}

-(void)setDestDir:(NSString *)to
{
	if(_destDir != nil) {
		[_destDir release];
	}
	[to retain];
	_destDir = to;
}

@end
