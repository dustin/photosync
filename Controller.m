#import "Controller.h"
#import "LocEditController.h"
#import "Locations.h"
#import "PhotoClient.h"
#import "PhotoSync.h"
#import "SyncTask.h"

@implementation Controller

- (IBAction)newLocation:(id)sender
{
	Location *loc=[[Location alloc] init];
	[self addLocation: loc];
	[self showEditor: loc];
	[loc release];
}

-(void)doNextTask:(id)sender
{
	NSLog(@"doNextTask: called.");
	if([stuffToDo count] == 0) {
		NSLog(@"All tasks complete.");
		[syncButton setEnabled: YES];
		[statusText setHidden: YES];
		[progressIndicator setHidden: YES];
	} else {
		NSLog(@"Starting a task");
		SyncTask *task=[stuffToDo lastObject];
		[task retain];
		[stuffToDo removeLastObject];

		[task run];
		NSLog(@"Finished with %@.", task);
		[task release];
	}
}

-(void)completedTask:(SyncTask *)task
{
	NSLog(@"Completed task:  %@", task);
	[self doNextTask:self];
}

-(void)updateStatus:(NSString *)msg with:(int)done of:(int)total
{
	if(msg != nil) {
		[statusText setHidden: NO];
		[statusText setStringValue:msg];
	}
	if(total != 0) {
		[progressIndicator setIndeterminate: NO];
		[progressIndicator setMaxValue: (double)total];
		[progressIndicator setHidden: NO];
		[progressIndicator setDoubleValue:(double)done];
	}
}

- (IBAction)performSync:(id)sender
{
	NSLog(@"Grabbing index");
	[syncButton setEnabled: FALSE];
	
	// Clear out the work list
	[stuffToDo removeAllObjects];
	NSEnumerator *e=[[locTable dataSource] objectEnumerator];
    id object=nil;
    while(object = [e nextObject]) {
		if([object isActive]) {
			NSLog(@"Setting up %@ with %d",
				[object url], [[object username] retainCount]);
			SyncTask *st=[[SyncTask alloc] initWithLocation:object
				delegate:self];
			if(st == nil) {
				NSLog(@"Authentication failed");
				NSRunAlertPanel(@"Authentication Failed",
					[NSString stringWithFormat:@"Authentication failed for %@",
						[object url]], @"OK", nil, nil);
			} else {
				NSLog(@"Queuing %@", st);
				[stuffToDo insertObject:st atIndex:0];
			}
			[st release];
		}
    }

	[self doNextTask:sender];
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

	stuffToDo=[[NSMutableArray alloc] init];

	[locTable setDoubleAction:@selector(doubleClicked:)];

	[[NSNotificationCenter defaultCenter]
		addObserver:self
		selector:@selector(refreshList:)
		name: PS_DID_UPDATE
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
