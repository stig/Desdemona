/* Desdemona */

#import <Cocoa/Cocoa.h>
#import <AlphaBeta/AlphaBeta.h>
#import <Reversi/ReversiState.h>
#import <Reversi/ReversiMove.h>

@class DesdemonaBoard;

@interface Desdemona : NSObject
{
    BOOL isAI[3];
    AlphaBeta *ab;
    IBOutlet DesdemonaBoard *board;
    IBOutlet NSTextField *black;
    IBOutlet NSTextField *white;
    IBOutlet NSTextField *turn;
}

- (IBAction)undo:(id)sender;

- (ReversiState *)state;
- (void)move:(ReversiMove *)move;
- (void)updateViews;
- (void)autoMove;
- (void)aiMove;

@end
