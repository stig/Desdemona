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

- (BOOL)mustPass
{
    NSArray *moves = [[self state] listAvailableMoves];
    if ([moves count] == 1 && [[[moves lastObject] string] isEqualToString: @"-1-1"]) {
        return YES;
    }
    return NO;
}

- (void)autoMove
{
    if ([self mustPass]) {
        NSLog(@"applying pass move");
        [self aiMove];
    }
    
    int player = [[self state] player];
    if (isAI[player]) {
        [self aiMove];
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
        [self updateViews];
        [self autoMove];
    }
    else {
        NSLog(@"AI cannot move");
    }
}

- (void)move:(ReversiMove *)m
{
    if ([ab move:m]) {
        [self updateViews];
        [self autoMove];
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
