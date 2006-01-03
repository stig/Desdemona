/* Desdemona */

#import <Cocoa/Cocoa.h>
#import <AlphaBeta/AlphaBeta.h>
#import <Reversi/ReversiState.h>
#import <Reversi/ReversiMove.h>

@class DesdemonaBoard;

@interface Desdemona : NSObject
{
    IBOutlet AlphaBeta *ab;
    IBOutlet DesdemonaBoard *board;
    IBOutlet NSTextField *black;
    IBOutlet NSTextField *white;
    IBOutlet NSTextField *turn;
}

- (ReversiState *)state;
- (void)move:(ReversiMove *)move;

@end
