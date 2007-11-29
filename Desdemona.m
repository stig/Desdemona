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
#import "DesdemonaState.h"

#import <SBReversi/SBReversiState.h>

@interface Desdemona (Private)

- (void)invokeSelector:(SEL)selector withDelay:(NSTimeInterval)theInterval;
- (void)animateFlips;

@end

// Keys for use in preferences
static NSString * const aiLevel          = @"ai_level";
static NSString * const boardSize        = @"boardsize";
static NSString * const animationDelay   = @"animationDelay";
static NSString * const aiPlayerStarts   = @"aiPlayerStarts";

@implementation Desdemona

+ (void)initialize
{
    // Register default preferences.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
        @"3",   aiLevel,
        @"8",   boardSize,
        @"0.6", animationDelay,
        @"0",   aiPlayerStarts,
        nil]];
}

- (void)awakeFromNib
{
    // The different states we can be in.
    aiTurn = [[ComputerTurn alloc] initWithDelegate:self];
    humanTurn = [[HumanTurn alloc] initWithDelegate:self];

    // The default state we start in.
    currentState = humanTurn;
    
    NSImage *theme = [NSImage imageNamed:@"classic"];
    tiles = [theme tilesWithSize:NSMakeSize(100, 100) forRows:4 columns:8];
    [tiles retain];
    
    alphaBeta = [SBAlphaBeta new];
	
    [self resetGame];

    // Make the window show now we've painted it for the first time
    [[board window] makeKeyAndOrderFront:self];
}

#pragma mark Private

- (void)resetGame
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id st = [[SBReversiState alloc] initWithBoardSize:
                [defaults integerForKey:boardSize]];

    [alphaBeta setState:[st autorelease]];

    // Set AI level so it stays the same throughout the game.
    [self setLevel:[defaults integerForKey:aiLevel]];
    
    // Set AI to be player 1 or 2, depending on whether it starts.
    [self setAi:[defaults boolForKey:aiPlayerStarts] ? 1 : 2 ];

    // We _might_ have to make the AI the starter
    if ([alphaBeta currentPlayer] == [self ai])
        currentState = aiTurn;
    
    [self updateViews];
}

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

- (void)animateFlips
{
    id state = [alphaBeta currentState];
    unsigned size = [state boardSize];

    unsigned done = YES;
    for (unsigned r = 0; r < size; r++) {
        for (unsigned c = 0; c < size; c++) {
            int target = [state pieceAtRow:r col:c];
            if (target == 2)
                target = [tiles count]-1;
            
            if (current[r][c] != target) {
                done = NO;

                if      (!current[r][c] || !target) current[r][c] = target;
                else if (current[r][c] > target)    current[r][c]--;
                else                                current[r][c]++;
            }
        }
    }

    if (!done) {

        for (unsigned r = 0; r < size; r++) {
            for (unsigned c = 0; c < size; c++) {
                NSImageCell *ic = [board cellAtRow:r column:c];
                [ic setImage:[tiles objectAtIndex:current[r][c]]];
                [ic setImageFrameStyle:NSImageFrameNone];
            }
        }

        float duration = [[NSUserDefaults standardUserDefaults] floatForKey:animationDelay];
        [self invokeSelector: @selector(animateFlips) withDelay: duration / [tiles count]];

    } else {
        [self autoMove];

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

    [self animateFlips];
}


/** Figure out if the AI should move "by itself". */
- (void)autoMove
{
    if ([alphaBeta isGameOver]) {
        [self gameOverAlert];

    } else if ([alphaBeta currentPlayer] != [self ai] && [alphaBeta isForcedPass]) {
        [self passAlert];

    } else if ([alphaBeta currentPlayer] == [self ai]) {
        [progressIndicator startAnimation:self];

        // This turns out to be a pretty good formula for going from
        // sequential levels to suitable intervals for search. At least
        // for Reversi, where x+1 often reaches one more ply than x.
        NSTimeInterval interval = exp([self level]) / 1000.0;
        id move = [alphaBeta moveFromSearchWithInterval:interval];
        [currentState computerMove:move];

        [progressIndicator stopAnimation:self];
    }
}


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
    [currentState humanMove:[NSNull null]];
    [self autoMove];
}


#pragma mark IBActions

- (IBAction)moveAction:(id)sender
{
    int c = [sender selectedColumn];
    int r = [sender selectedRow];

    SBReversiState *state = [alphaBeta currentState];
    id move = [state moveForCol:r andRow:c];

    [currentState humanMove:move];
}

/**
Performs undo twice (once for AI, once for human) 
and updates views in between.
*/
- (IBAction)undo:(id)sender
{
    [currentState performUndo];
}    

/** Initiate a new game. */
- (IBAction)newGame:(id)sender
{
    [currentState performReset];
}


#pragma mark Accessors

- (void)setAi:(unsigned)x { ai = x; }
- (unsigned)ai { return ai; }

- (void)setLevel:(unsigned)x { level = x; }
- (unsigned)level { return level; }

- (id)alphaBeta
{
    return alphaBeta;
}

- (id)humanTurn
{
    return humanTurn;
}

- (id)aiTurn
{
    return aiTurn;
}

- (void)setCurrentState:(id)x
{
    currentState = x;
}

@end
