#import "Locations.h"

@implementation Locations

-(id)init
{
	self=[super init];
	_locations=[[NSMutableArray alloc] init];
	return self;
}

-(void)dealloc
{
	NSLog(@"Deallocing Locations");
	[_locations release];
	[super dealloc];
}

-(int)numberOfRowsInTableView:(NSTableView *)aTableView
{
	return([_locations count]);
}

- (id)tableView:(NSTableView *)aTableView
    objectValueForTableColumn:(NSTableColumn *)aTableColumn
    row:(int)rowIndex
{
	id theItem=[_locations objectAtIndex: rowIndex];
	id rv=[theItem valueForKey:[aTableColumn identifier]];
	return(rv);
}

-(void)addItem: (Location *)loc
{
	[_locations addObject: loc];
}

-(void)removeItemAt: (int)which
{
	[_locations removeObjectAtIndex: which];
}

-(void)removeAll
{
	[_locations removeAllObjects];
}

-(id)toArray
{
	NSMutableArray *a=[[NSMutableArray alloc] init];
	NSEnumerator *e=[_locations objectEnumerator];
	id object=nil;
	while(object = [e nextObject]) {
		[a addObject: [object toDict]];
	}
	NSArray *rv=[NSArray arrayWithArray: (NSArray *)a];
	[a release];
	return(rv);
}

-(void)loadArray:(id)arry
{
	NSEnumerator *e=[arry objectEnumerator];
	id object=nil;
	while(object = [e nextObject]) {
		Location *loc=[[Location alloc] initWithDict:(NSDictionary *)object];
		[_locations addObject: loc];
		[loc release];
	}
}

-(id)objectAtIndex:(unsigned)which
{
	return([_locations objectAtIndex:which]);
}

-(NSEnumerator *)objectEnumerator
{
    return([_locations objectEnumerator]);
}

@end
