#import "Desdemona.h"
#import "DesdemonaBoard.h"
#import <AlphaBeta/AlphaBeta.h>
#import <Reversi/ReversiState.h>
#import <Reversi/ReversiMove.h>

@implementation Desdemona

- (void)awakeFromNib
{
    [[board window] makeKeyAndOrderFront:self];
    [board setController:self];
    
    id st = [[ReversiState alloc] initWithBoardSize:6];
    ab = [[AlphaBeta alloc] initWithState:st];

    isAI[BLACK] = YES;
    
    [self updateViews];
}

- (void)updateViews
{
    ReversiState *s = [self state];
    ReversiStateCount counts = [s countSquares];
	[white setIntValue:counts.c[WHITE]];
	[black setIntValue:counts.c[BLACK]];
	[turn setStringValue: [s player] == WHITE ? @"White" : @"Black"];
    [board setNeedsDisplay:YES];
}

- (void)autoMove
{
    int player = [[self state] player];
    NSLog(@"states: %u, moves: %u", [ab countStates], [ab countMoves]);
    if (isAI[player]) {
        [self aiMove];
        NSLog(@"states: %u, moves: %u (after aiMove)", [ab countStates], [ab countMoves]);
    }
}

- (IBAction)undo:(id)sender
{
    [ab undo];
    [self updateViews];
    [ab undo];
    [self autoMove];
    [self updateViews];
}

- (void)aiMove
{
    if ([ab aiMove]) {
        [self autoMove];
    }
    else {
        NSLog(@"AI cannot move");
    }
    [self updateViews];
}

- (void)move:(ReversiMove *)m
{
    if ([ab move:m]) {
        [self autoMove];
    } 
    else {
        NSLog(@"Illegal move attempted");
    }
    [self updateViews];
}

- (ReversiState *)state
{
    return [ab currentState];
}

- (void)dealloc
{
    [ab release];
    [super dealloc];
}

@end
