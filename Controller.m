#import "Controller.h"
#import "LocEditController.h"
#import "Locations.h"
#import "PhotoClient.h"

@implementation Controller

- (IBAction)newLocation:(id)sender
{
	Location *loc=[[Location alloc] init];
	[self addLocation: loc];
	[self showEditor: loc];
	[loc release];
}

- (IBAction)performSync:(id)sender
{
	NSLog(@"Grabbing index");
	
	NSEnumerator *e=[[locTable dataSource] objectEnumerator];
    id object=nil;
    while(object = [e nextObject]) {
		PhotoClient *pc=[[PhotoClient alloc] init];
		NSString *idxpath=[[object destDir]
			stringByAppendingPathComponent: @"index.xml"];
	
		[pc fetchIndexFrom: [object url] to: idxpath];
		[pc parseIndex: idxpath];
		NSLog(@"Parsed %d photos", [[pc photos] count]);
		[pc release];
    }
}


- (IBAction)rmLocation:(id)sender
{
	int row=[locTable selectedRow];
	if(row >= 0) {
		[[locTable dataSource] removeItemAt: row];
		[locTable reloadData];
	}
}

-(void)initDefaults
{
	NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
	id ob=[def objectForKey:@"locations"];
	if(ob != nil) {
		[[locTable dataSource] loadArray: ob];
		[locTable reloadData];
	}
}

-(void)awakeFromNib
{
	[self setWindowFrameAutosaveName: @"MainWindow"];
	[self initDefaults];
	
	[locTable setDoubleAction:@selector(doubleClicked:)];
	
	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(refreshList:)
		name: @"DidUpdate"
		object: nil];
}

-(void)refreshList:(id)sender
{
	[locTable reloadData];
}

-(void)showEditor:(id)loc
{
	[locEdit showWindow:self];
	[locEdit setLocation:loc];
}

-(void)doubleClicked:(id)sender
{
	int row=[locTable selectedRow];
	if(row >= 0) {
		[self showEditor: [[locTable dataSource] objectAtIndex: row]];
	}
}

-(void)addLocation:(id)loc
{
	[[locTable dataSource] addItem: loc];
	[locTable reloadData];
}

-(void)applicationWillTerminate:(id)notification
{
	NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
	[def setObject: [[locTable dataSource] toArray] forKey:@"locations"];
}

@end
