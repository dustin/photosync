#import "LocEditController.h"

@implementation LocEditController

- (IBAction)browse:(id)sender
{
	NSOpenPanel *op=[NSOpenPanel openPanel];
	[op setCanChooseFiles:FALSE];
	[op setCanChooseDirectories:TRUE];
	[op setCanCreateDirectories:TRUE];
	[op setAllowsMultipleSelection:FALSE];
	int result = [op runModalForTypes:nil];
	if(result == NSOKButton) {
		[destination setStringValue:[[op filenames] objectAtIndex:0]];
	}
}

- (IBAction)cancel:(id)sender
{
	[[self window] performClose: sender];
}

- (IBAction)save:(id)sender
{
	[_loc setUrl:[url stringValue]];
	[_loc setUsername:[username stringValue]];
	[_loc setPassword:[password stringValue]];
	[_loc setDestDir:[destination stringValue]];
	// Throw away our copy
	[_loc release];
	_loc = nil;
	// Close the window
	[[self window] performClose: sender];
	// Send a notification
	[[NSNotificationCenter defaultCenter]
		postNotificationName: @"DidUpdate" object: self];
}

-(void)setLocation:(Location *)to
{
	if(_loc != nil) {
		[_loc release];
	}
	[to retain];
	_loc=to;
	
	[url setStringValue:[_loc url]];
	[username setStringValue:[_loc username]];
	[password setStringValue:[_loc password]];
	[destination setStringValue:[_loc destDir]];
}

@end
