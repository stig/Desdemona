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

- (void)move:(ReversiMove *)m
{
    if ([ab move:m]) {
        [self updateViews];
        if ([ab aiMove]) {
            [self updateViews];
        }
    }	
    else {
        NSLog(@"Illegal move attempted");
    }
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
