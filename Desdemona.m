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

#import <SBReversi/SBReversiState.h>


@implementation Desdemona

+ (void)initialize
{
    // Register default preferences.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
        @"3",           @"ai_level",
        @"8",           @"boardsize",
        @"classic",     @"theme",
        @"0.6",         @"animationDuration",
        nil]];
}

- (void)awakeFromNib
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSImage *theme = [NSImage imageNamed:[defaults valueForKey:@"theme"]];
    tiles = [theme tilesWithSize:NSMakeSize(100, 100) forRows:4 columns:8];
    [tiles retain];
    
    alphaBeta = [SBAlphaBeta new];
    
    [self resetGame];

    // Make the window show now we've painted it for the first time
    [[board window] makeKeyAndOrderFront:self];
}

- (void)resetGame
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id st = [[SBReversiState alloc] initWithBoardSize:
                [defaults integerForKey:@"boardsize"]];

    [alphaBeta setState:[st autorelease]];

    // Set AI level so it stays the same throughout the game.
    [self setLevel:[defaults integerForKey:@"ai_level"]];
    [self setAi:2];
    [self autoMove];
}

#pragma mark Actions

- (void)invokeSelector:(SEL)selector withDelay:(NSTimeInterval)theInterval
{
    NSMethodSignature *signature = [Desdemona instanceMethodSignatureForSelector:selector];

    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation setSelector:selector];
    [invocation setTarget:self];
    
    [NSTimer scheduledTimerWithTimeInterval:theInterval
                                 invocation:invocation
                                    repeats:NO];
}

- (void)animateBoard
{
    id state = [alphaBeta currentState];
    unsigned size = [state boardSize];

    unsigned done = YES;
    for (unsigned r = 0; r < size; r++) {
        for (unsigned c = 0; c < size; c++) {
            int target = [state pieceAtRow:r col:c];
            if (current[r][c] != target) {
                done = NO;

                if      (!current[r][c] || !target) current[r][c] = target;
                else if (current[r][c] > target)    current[r][c]--;
                else                                current[r][c]++;
            }
        }
    }

    for (unsigned r = 0; r < size; r++) {
        for (unsigned c = 0; c < size; c++) {
            NSImageCell *ic = [board cellAtRow:r column:c];
            [ic setImage:[tiles objectAtIndex:current[r][c]]];
            [ic setImageFrameStyle:NSImageFrameNone];
        }
    }

    if (!done) {
        float duration = [[NSUserDefaults standardUserDefaults] floatForKey:@"animationDuration"];
        [self invokeSelector: @selector(animateBoard) withDelay: duration / [tiles count]];

    } else {
        if ([alphaBeta isGameOver]) {
            [self gameOverAlert];

        } else if ([alphaBeta currentPlayer] != [self ai] && [alphaBeta isForcedPass]) {
            [self passAlert];

        } else if ([alphaBeta currentPlayer] == [self ai]) {
            [self aiMove];
        }
    }

    [board setNeedsDisplay:YES];
}

- (void)updateViews
{
    unsigned p = [alphaBeta currentPlayer];
    SBReversiState *state = [alphaBeta currentState];
    [white setIntValue:p == ai ? [state opponentCount] : [state playerCount]];
    [black setIntValue:p == ai ? [state playerCount]   : [state opponentCount]];

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

    [self animateBoard];
}


/** Make the AI perform a move. */
- (void)aiMove
{
    if ([self ai] == [alphaBeta currentPlayer]) {
        [progressIndicator startAnimation:self];

        // This turns out to be a pretty good formula for going from
        // sequential levels to suitable intervals for search. At least
        // for Reversi, where x+1 often reaches one more ply than x.
        NSTimeInterval interval = exp(level) / 1000.0;
        [alphaBeta performMoveFromSearchWithInterval:interval];
        [self updateViews];

        [progressIndicator stopAnimation:self];
    }

    if ([self ai] == [alphaBeta currentPlayer])
        NSLog(@"AI cannot move!");
}

/** Figure out if the AI should move "by itself". */
- (void)autoMove
{
    [self updateViews];
    
    if ([self ai] == [alphaBeta currentPlayer]) {
        [self aiMove];
        [self updateViews];
    }
}


#pragma mark Alerts

/** Displays an alert when "Game Over" is detected. */
- (void)gameOverAlert
{
    NSAlert *alert = [[NSAlert new] autorelease];

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
    NSAlert *alert = [[NSAlert new] autorelease];
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
    NSAlert *alert = [[NSAlert new] autorelease];
    [alert setMessageText:@"No move possible"];
    [alert setInformativeText:@"You cannot make a move and are forced to pass."];
    [alert addButtonWithTitle:@"Ok"];
    [alert runModal];
    [alphaBeta performMove:[NSNull null]];
    [self aiMove];
}


#pragma mark IBActions

- (IBAction)moveAction:(id)sender
{
    int c = [sender selectedColumn];
    int r = [sender selectedRow];

    SBReversiState *state = [alphaBeta currentState];
    id move = [state moveForCol:r andRow:c];

    @try {
       [alphaBeta performMove:move];
       [self updateViews];
    }
    @catch (id e) {
        [[NSSound soundNamed:@"Basso"] play];
        NSLog(@"Not a legal move: [%d,%d]", r, c);
    }
}

/**
Performs undo twice (once for AI, once for human) 
and updates views in between.
*/
- (IBAction)undo:(id)sender
{
    if ([self ai] != [alphaBeta currentPlayer])
        [alphaBeta undoLastMove];
    [alphaBeta undoLastMove];
    [self updateViews];
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


@end
