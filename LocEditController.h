/* LocEditController */

#import <Cocoa/Cocoa.h>
#import "Location.h"

@interface LocEditController : NSWindowController
{
    IBOutlet id destination;
    IBOutlet id password;
    IBOutlet id url;
    IBOutlet id username;
	
	Location *_loc;
}
- (IBAction)browse:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

-(void)setLocation:(Location *)to;

@end
