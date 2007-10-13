/*
Copyright (C) 2006,2007 Stig Brautaset. All rights reserved.

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

#import "Desdemona.h"
#import "NSImage+Tiles.h"


@implementation Desdemona

+ (void)initialize
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
        @"3",           @"ai_level",
        @"8",           @"boardsize",
        nil]];
}

- (void)awakeFromNib
{
    [[board window] makeKeyAndOrderFront:self];
    NSImage *theme = [NSImage imageNamed:@"classic"];
    tiles = [theme tilesWithSize:NSMakeSize(100, 100) forRows:4 columns:8];
    [tiles retain];
    [self resetGame];
}

- (void)dealloc
{
    [alphaBeta release];
    [super dealloc];
}

- (void)resetGame
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id st = [[[SBReversiState alloc] initWithBoardSize:
                [defaults integerForKey:@"boardsize"]]
                    autorelease];

    [self setAlphaBeta:[[SBAlphaBeta alloc] initWithState:st]];

    [self setLevel:[defaults integerForKey:@"ai_level"]];
    [self setAi:2];
    [self autoMove];
}

#pragma mark Actions

- (void)updateViews
{
    SBReversiState *state = [alphaBeta currentState];
    [white setIntValue:[state opponentCount]];
    [black setIntValue:[state playerCount]];

    int size = [state boardSize];
    
    // Resize the matrix if we have different dimensions from before.
    int r, c;
    [board getNumberOfRows:&r columns:&c];
    if (r != size || c != size) {
        [board renewRows:size columns:size];
        
        /* such.. a.. hack... - make the matrix resize, as this is
           the only way I've found to get the cells to resize. */
        NSSize s = [board frame].size;
        [board setFrameSize:NSMakeSize(100,100)];
        [board setFrameSize:s];
    }

    for (unsigned r = 0; r < size; r++) {
        for (unsigned c = 0; c < size; c++) {
            int player = [state pieceAtRow:r col:c];
        
            NSImageCell *ic = [board cellAtRow:r column:c];
            [ic setImage:[tiles objectAtIndex:player]];
            [ic setImageFrameStyle:NSImageFrameNone];
        }
    }

    [board setNeedsDisplay:YES];
}


/** Make the AI perform a move. */
- (void)aiMove
{
    // This turns out to be a pretty good formula for going from
    // sequential levels to suitable intervals for search. At least
    // for Reversi, where x+1 often reaches one more ply than x.
    NSTimeInterval interval = exp(level) / 1000.0;
    id st = [alphaBeta performMoveFromSearchWithInterval:interval];
    NSLog(@"Reached a depth of %u", [alphaBeta depthForSearch]);


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
        [alphaBeta performMove:m];
    }
    @catch (id any) {
        NSLog(@"Illegal move attempted: %@", m);
    }
    @finally {
        [self autoMove];
    }
}

/** Figure out if the AI should move "by itself". */
- (void)autoMove
{
    [self updateViews];
    
    if ([alphaBeta isGameOver]) {
        [self gameOverAlert];
    }
    else if ([alphaBeta isForcedPass]) {
        [self passAlert];
    }
    
    if ([self ai] == [alphaBeta currentPlayer]) {
        [progressIndicator startAnimation:self];
        [self aiMove];
        [progressIndicator stopAnimation:self];
        [self updateViews];
    }
}


#pragma mark Alerts

/** Displays an alert when "Game Over" is detected. */
- (void)gameOverAlert
{
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];

    int winner = [alphaBeta winner];
    NSString *msg = winner == ai ? @"You lost!" :
                    !winner      ? @"You managed a draw!" :
                                   @"You won!";
    
    [alert setMessageText:msg];
    [alert setInformativeText:@"Do you want to play another game?"];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];
    if ([alert runModal] == NSAlertFirstButtonReturn) {
        [self resetGame];
    }
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

- (void)passAlert
{
    NSAlert *alert = [[[NSAlert alloc] init] autorelease];
    [alert setMessageText:@"No move possible"];
    [alert setInformativeText:@"You cannot make a move and are forced to pass."];
    [alert addButtonWithTitle:@"Ok"];
    [alert runModal];
    [self move:[NSNull null]];
}


#pragma mark IBActions

- (IBAction)moveAction:(id)sender
{
    int c = [sender selectedColumn];
    int r = [sender selectedRow];

    SBReversiState *state = [alphaBeta currentState];
    id move = [state moveForCol:r andRow:c];

    if ([[state legalMoves] containsObject:move]) {
       [self move:move];

    } else {
        NSLog(@"Not a legal move: [%d,%d]", r, c);
    }
}

/**
Performs undo twice (once for AI, once for human) 
and updates views in between.
*/
- (IBAction)undo:(id)sender
{
    [alphaBeta undoLastMove];
    [self updateViews];
    [alphaBeta undoLastMove];
    [self autoMove];
}

/** Initiate a new game. */
- (IBAction)newGame:(id)sender
{
    if ([alphaBeta countPerformedMoves]) {
        [self newGameAlert];
    }
    else {
        [self resetGame];
    }
}


#pragma mark Accessors

- (void)setAi:(unsigned)x { ai = x; }
- (unsigned)ai { return ai; }

- (void)setLevel:(unsigned)x { level = x; }
- (unsigned)level { return level; }

- (void)setAlphaBeta:(id)x
{
    if (alphaBeta != x) {
        [alphaBeta release];
        alphaBeta = [x retain];
    }
}
- (id)alphaBeta { return alphaBeta; }


@end
