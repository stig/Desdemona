/*
Copyright (C) 2006 Stig Brautaset. All rights reserved.

This file is part of Desdemona.

Desdemona is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

Desdemona is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Desdemona; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*/

#import <SBAlphaBeta/SBAlphaBeta.h>
#import <SBReversi/SBReversiState.h>

#import "Desdemona.h"
#import "BoardView.h"

@implementation Desdemona

- (void)awakeFromNib
{
    [[board window] makeKeyAndOrderFront:self];
    [board setController:self];
    [board setTheme:[NSImage imageNamed:@"classic"]];
    [self changeSize:sizeStepper];
    [self changeLevel:levelStepper];
    [self resetGame];
}


/** Displays an alert when "Game Over" is detected. */
- (void)gameOverAlert
{
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];

    int winner = [self winner];
    NSString *msg = winner == ai
        ? @"You lost!"
        : !winner
            ? @"You managed a draw!"
            : @"You won!";
    
    [alert setMessageText:msg];
    [alert setInformativeText:@"Do you want to play another game?"];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        [self resetGame];
    }
}

/** Performs undo twice (once for AI, once for human) 
and updates views in between. */
- (IBAction)undo:(id)sender
{
    [ab undoLastMove];
    [self updateViews];
    [ab undoLastMove];
    [self autoMove];
}

/** Toggle whether the AI is WHITE or BLACK. */
- (IBAction)changeAi:(id)sender
{
    ai = [aiButton state] == NSOnState ? WHITE : BLACK;
    [self autoMove];
}

/** Displays an alert when the "New Game" action is chosen. */
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

/** Initiate a new game. */
- (IBAction)newGame:(id)sender
{
    if ([ab countMoves]) {
		[self newGameAlert];
	}
	else {
		[self resetGame];
	}
}

/** Make the AI perform a move. */
- (void)aiMove
{
    int ply = [levelStepper intValue];
    id st = nil;
    if (ply < 4) {
        st = [ab applyMoveFromSearchWithPly:ply];
    } else {
        ply *= 10.0;
        NSTimeInterval interval = (NSTimeInterval)(ply * ply / 1000.0);
        st = [ab applyMoveFromSearchWithInterval:interval];
    }

    if (st) {
        [self autoMove];
    } else {
        NSLog(@"AI cannot move");
    }
}

/** Perform the given move. */
- (void)move:(id)m
{
    @try {
        [ab applyMove:m];
    }
    @catch (id any) {
        NSLog(@"Illegal move attempted: %@", m);
    }
    @finally {
        [self autoMove];
    }
}

/** Return the current state (pass-through to SBAlphaBeta). */
- (id)state
{
    return [ab currentState];
}

- (int)winner
{
    return [ab winner];
}

- (int)player
{
    return [ab playerTurn];
}

- (void)dealloc
{
    [ab release];
    [super dealloc];
}

/** Figure out if the AI should move "by itself". */
- (void)autoMove
{
    [self updateViews];
    
    if ([ab isGameOver]) {
        [self gameOverAlert];
    }
    else if ([ab currentPlayerMustPass]) {
        [self passAlert];
    }
    
    if (ai == [self player]) {
        [self aiMove];
        [self updateViews];
    }
}

- (void)resetGame
{
    [ab release];
    ab = [[SBAlphaBeta alloc] initWithState:
        [[SBReversiState alloc] initWithBoardSize:
            [sizeStepper intValue]]];
    
    [aiButton setEnabled:YES];
    [aiButton setState:NSOffState];
    [self changeAi:aiButton];
    [self changeLevel:levelStepper];
    
    [self autoMove];
}

- (void)updateViews
{
    SBReversiState *s = [self state];
    SBReversiStateCount counts = [s countSquares];
    [white setIntValue:counts.c[3 - ai]];
    [black setIntValue:counts.c[ai]];
    [turn setStringValue: ai == [ab playerTurn]
        ? @"Desdemona is searching for a move..."
        : @"Your move"];
    [aiButton setEnabled: [ab countMoves] ? NO : YES];
    [sizeStepper setEnabled: [ab countMoves] ? NO : YES];
    [levelStepper setEnabled: [ab countMoves] ? NO : YES];
    
    [board setBoard:[[ab currentState] board]];
    [board setNeedsDisplay:YES];
    [[board window] display];
}

- (IBAction)changeLevel:(id)sender
{
    [level setIntValue:[sender intValue]];
}

- (IBAction)changeSize:(id)sender
{
    [size setIntValue:[sender intValue]];
    [self resetGame];
}

- (void)passAlert
{
	NSAlert *alert = [[[NSAlert alloc] init] autorelease];
	[alert setMessageText:@"No move possible"];
	[alert setInformativeText:@"You cannot make a move and are forced to pass."];
	[alert addButtonWithTitle:@"Ok"];
	[alert runModal];
	[self move:[NSMutableArray arrayWithObject:[NSNull null]]];
}

- (void)clickAtRow:(int)y col:(int)x
{
    [self move:[[self state] moveForCol:y andRow:x]];
}

@end
