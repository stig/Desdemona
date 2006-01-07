#import "Desdemona.h"
#import "DesdemonaBoard.h"
#import <AlphaBeta/AlphaBeta.h>
#import <Reversi/ReversiState.h>
#import <Reversi/ReversiMove.h>

@implementation Desdemona


- (void)resetGame
{
    [ab release];
    ab = [[AlphaBeta alloc] initWithState:
        [[ReversiState alloc] initWithBoardSize:
            [sizeStepper intValue]]];
    
    [self autoMove];
}

- (void)awakeFromNib
{
    [[board window] makeKeyAndOrderFront:self];
    [board setController:self];

    isAI[BLACK] = YES;
    
    [self changeSize:sizeStepper];
    [self changeLevel:levelStepper];
    
    [self resetGame];
}

- (void)updateViews
{
    ReversiState *s = [self state];
    ReversiStateCount counts = [s countSquares];
    [white setIntValue:counts.c[WHITE]];
    [black setIntValue:counts.c[BLACK]];
    [turn setStringValue: isAI[[s player]] ? @"Desdemona is searching for a move..." : @"Your move"];
    [sizeStepper setEnabled: [ab countMoves] ? NO : YES];
    [levelStepper setEnabled: [ab countMoves] ? NO : YES];
    [board setNeedsDisplay:YES];
    [[board window] display];
}

- (BOOL)mustPass
{
    NSArray *moves = [[self state] listAvailableMoves];
    if ([moves count] == 1 && [[[moves lastObject] string] isEqualToString: @"-1-1"]) {
        return YES;
    }
    return NO;
}

- (void)passAlert
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:@"No move possible"];
	[alert setInformativeText:@"You cannot make a move and are forced to pass."];
	[alert addButtonWithTitle:@"Ok"];
	[alert runModal];
	[self move:[ReversiMove newWithCol:-1 andRow:-1]];
}

- (void)gameOverAlert
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:@"Game Over!"];
	[alert setInformativeText:@"Do you want to start a new game?"];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	if ([alert runModal] == NSAlertFirstButtonReturn) {
		[self resetGame];
	}
}

- (void)autoMove
{
    [self updateViews];
    
    if ([ab isGameOver]) {
        [self gameOverAlert];
    }
    else if ([self mustPass]) {
        [self passAlert];
    }
    
    int player = [[self state] player];
    if (isAI[player]) {
        [self aiMove];
        [self updateViews];
    }
}

- (IBAction)undo:(id)sender
{
    [ab undo];
    [self updateViews];
    [ab undo];
    [self autoMove];
}

- (IBAction)changeSize:(id)sender
{
    [size setIntValue:[sender intValue]];
    [self resetGame];
}

- (IBAction)changeLevel:(id)sender
{
    int val = [sender intValue];
    [level setIntValue:val];
    val *= 10;
    [ab setMaxTime: (NSTimeInterval)(val * val / 1000.0) ];
}

- (void)newGameAlert
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:@"Start a new game"];
	[alert setInformativeText:@"Are you sure you want to terminate the current game and start a new one?"];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];
	if ([alert runModal] == NSAlertFirstButtonReturn) {
		[self resetGame];
	}
}

- (IBAction)newGame:(id)sender
{
    if ([ab countMoves]) {
		[self newGameAlert];
	}
	else {
		[self resetGame];
	}
}

- (void)aiMove
{
    if ([ab iterativeSearch]) {
        [self autoMove];
    }
    else {
        NSLog(@"AI cannot move");
    }
}

- (void)move:(ReversiMove *)m
{
    if ([ab move:m]) {
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
