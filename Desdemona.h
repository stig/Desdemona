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

#import <Cocoa/Cocoa.h>
#import <SBAlphaBeta/SBAlphaBeta.h>
#import <SBReversi/SBReversiState.h>

#define WHITE 1
#define BLACK 2

@class BoardView;

@interface Desdemona : NSObject
{
    int ai, maxPly;
    double maxTime;
    SBAlphaBeta *ab;
    
    IBOutlet BoardView *board;
    IBOutlet NSButton *aiButton;

    IBOutlet NSStepper *levelStepper;
    IBOutlet NSTextField *level;

    IBOutlet NSStepper *sizeStepper;
    IBOutlet NSTextField *size;
    
    IBOutlet NSTextField *turn;
    IBOutlet NSTextField *black;
    IBOutlet NSTextField *white;
}

- (IBAction)changeAi:(id)sender;
- (IBAction)changeSize:(id)sender;
- (IBAction)changeLevel:(id)sender;
- (IBAction)newGame:(id)sender;
- (IBAction)undo:(id)sender;
- (IBAction)newGame:(id)sender;

- (id)state;
- (void)move:(id)move;
- (void)gameOverAlert;
- (void)aiMove;

- (void)updateViews;
- (void)autoMove;
- (void)resetGame;

- (void)clickAtRow:(int)r col:(int)c;

- (void)passAlert;

@end
