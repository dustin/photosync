/* Locations */

#import <Cocoa/Cocoa.h>
#import "Location.h"

@interface Locations : NSObject
{
	NSMutableArray *_locations;
}

-(void)addItem: (Location *)item;
-(void)removeItemAt: (int)which;
-(void)removeAll;

-(id)objectAtIndex:(unsigned int)which;

-(NSEnumerator *)objectEnumerator;

-(id)toArray;
-(void)loadArray:(id)arry;

@end
