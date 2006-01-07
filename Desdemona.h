/* Desdemona */

#import <Cocoa/Cocoa.h>
#import <AlphaBeta/AlphaBeta.h>
#import <Reversi/ReversiState.h>
#import <Reversi/ReversiMove.h>

@class DesdemonaBoard;

@interface Desdemona : NSObject
{
    int ai;
    AlphaBeta *ab;
    
    IBOutlet DesdemonaBoard *board;
    
    IBOutlet NSStepper *levelStepper;
    IBOutlet NSStepper *sizeStepper;
    
    IBOutlet NSTextField *level;
    IBOutlet NSTextField *size;
    IBOutlet NSTextField *turn;
    IBOutlet NSTextField *black;
    IBOutlet NSTextField *white;
}
- (IBAction)changeLevel:(id)sender;
- (IBAction)changeSize:(id)sender;
- (IBAction)newGame:(id)sender;
- (IBAction)undo:(id)sender;
- (IBAction)newGame:(id)sender;

- (ReversiState *)state;
- (void)move:(ReversiMove *)move;
- (void)updateViews;
- (void)autoMove;
- (void)aiMove;

@end
