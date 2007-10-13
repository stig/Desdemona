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

#import <Cocoa/Cocoa.h>

@class BoardView;
@class SBAlphaBeta;

#define MAXBOARDSIZE 16

@interface Desdemona : NSObject
{
    unsigned current[MAXBOARDSIZE][MAXBOARDSIZE];
    unsigned ai, level;
    SBAlphaBeta *alphaBeta;
    NSArray *tiles;

    IBOutlet NSProgressIndicator *progressIndicator;
    IBOutlet NSMatrix *board;
    IBOutlet NSTextField *black;
    IBOutlet NSTextField *white;
}

- (IBAction)moveAction:(id)sender;
- (IBAction)undo:(id)sender;
- (IBAction)newGame:(id)sender;

- (void)setLevel:(unsigned)x;
- (unsigned)level;

- (void)setAi:(unsigned)x;
- (unsigned)ai;

- (void)move:(id)move;
- (void)aiMove;
- (void)updateViews;
- (void)autoMove;
- (void)resetGame;

- (void)gameOverAlert;
- (void)passAlert;

@end
