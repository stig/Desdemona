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

#import "Desdemona.h"
#import "BoardView.h"

@implementation Desdemona

+ (void)initialize
{
    [super initialize];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
        @"8",           @"boardsize",
        nil]];
}

- (void)resetGame
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    id st = [[[SBReversiState alloc] initWithBoardSize:
                [defaults integerForKey:@"boardsize"]]
                    autorelease];
    [ab release];
    ab = [[SBAlphaBeta alloc] initWithState:st];

    [super resetGame];
}

- (void)awakeFromNib
{
    [[board window] makeKeyAndOrderFront:self];
    [board setController:self];
    [board setTheme:[NSImage imageNamed:@"classic"]];
    [self resetGame];
}



#pragma mark Alerts

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

#pragma mark Actions

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
    
    if ([self ai] == [ab playerTurn]) {
        [progressIndicator startAnimation:self];
        [self aiMove];
        [progressIndicator stopAnimation:self];
        [self updateViews];
    }
}

- (void)updateViews
{
    SBReversiState *s = [self state];
    SBReversiStateCount counts = [s countSquares];
    [white setIntValue:counts.c[3 - [self ai]]];
    [black setIntValue:counts.c[[self ai]]];
    [board setBoard:[[ab currentState] board]];
    [board setNeedsDisplay:YES];
    [[board window] display];
}

- (void)clickAtRow:(int)y col:(int)x
{
    [self move:[[self state] moveForCol:y andRow:x]];
}

@end
