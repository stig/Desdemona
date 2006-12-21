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
#import <SBAlphaBeta/SBAlphaBeta.h>
#import <SBReversi/SBReversiState.h>
#import <SBReversi/SBReversiMove.h>

@implementation Desdemona


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

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self changeSize:sizeStepper];
    [self changeLevel:levelStepper];
    [self resetGame];
}

- (void)updateViews
{
    SBReversiState *s = [self state];
    SBReversiStateCount counts = [s countSquares];
    [white setIntValue:counts.c[3 - ai]];
    [black setIntValue:counts.c[ai]];
    [turn setStringValue: ai == [s player] ? @"Desdemona is searching for a move..." : @"Your move"];
    [aiButton setEnabled: [ab countMoves] ? NO : YES];
    [sizeStepper setEnabled: [ab countMoves] ? NO : YES];
    [levelStepper setEnabled: [ab countMoves] ? NO : YES];
    
    [board setState:[self buildState]];
    [board setNeedsDisplay:YES];
    [[board window] display];
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
    [self move:[[ab state] moveForCol:y andRow:x]];
}

@end
