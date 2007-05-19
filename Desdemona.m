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

    [self setAlphaBeta:[[SBAlphaBeta alloc] initWithState:st]];

    [super resetGame];
}

- (void)awakeFromNib
{
    [[board window] makeKeyAndOrderFront:self];
    [board setDelegate:self];
    [board setTheme:[NSImage imageNamed:@"classic"]];
    [self resetGame];
}



#pragma mark IBActions

#pragma mark Actions

- (void)updateViews
{
    SBReversiState *s = [self state];
    SBReversiStateCount counts = [s countSquares];
    [white setIntValue:counts.c[3 - [self ai]]];
    [black setIntValue:counts.c[[self ai]]];
    [board setBoard:[[self state] board]];
    [board setNeedsDisplay:YES];
    [[board window] display];
}

- (void)clickAtRow:(int)y col:(int)x
{
    [self move:[[self state] moveForCol:y andRow:x]];
}

@end
