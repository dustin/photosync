/* Controller */

#import <Cocoa/Cocoa.h>

@interface Controller : NSWindowController
{
    IBOutlet id locEdit;
    IBOutlet id locTable;
    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSTextField *statusText;
    IBOutlet NSButton *syncButton;
}
- (IBAction)newLocation:(id)sender;
- (IBAction)performSync:(id)sender;
- (IBAction)rmLocation:(id)sender;

-(void)addLocation:(id)loc;
-(void)showEditor:(id)loc;

@end
