/* Controller */

#import <AppKit/AppKit.h>

#define BUTTON_SYNC 1
#define BUTTON_STOP 2

@interface Controller : NSWindowController
{
    IBOutlet id locEdit;
    IBOutlet id locTable;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSTextField *statusText;
    IBOutlet NSButton *syncButton;

	NSMutableArray *stuffToDo;
}
- (IBAction)newLocation:(id)sender;
- (IBAction)performSync:(id)sender;
- (IBAction)rmLocation:(id)sender;
- (IBAction)editHighlighted:(id)sender;

-(void)addLocation:(id)loc;
-(void)showEditor:(id)loc;

@end
