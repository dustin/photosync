/* Locations */

#import <AppKit/AppKit.h>
#import "Location.h"

@interface Locations : NSObject
{
	NSMutableArray *_locations;
}

-(void)addItem: (Location *)item;
-(void)removeItemAt: (int)which;
-(void)removeAll;

-objectAtIndex:(unsigned int)which;

-(NSEnumerator *)objectEnumerator;

-toArray;
-(void)loadArray:(id)arry;

@end
