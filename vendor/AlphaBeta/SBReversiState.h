/*
Copyright (C) 2006,2007 Stig Brautaset. All rights reserved.

This file is part of AlphaBeta.

AlphaBeta is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

AlphaBeta is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with AlphaBeta; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

*/

#import <AlphaBeta/AlphaBeta.h>

typedef struct _ReversiStateCount {
    unsigned c[3];
} SBReversiStateCount;

#define MAXSIZE 20

@interface SBReversiBase : NSObject <SBAlphaBetaStateCommon> {
@public
    int player;
    int size;
    int board[MAXSIZE][MAXSIZE];
}

- (NSArray *)board;
- (int)boardSize;
- (id)initWithBoardSize:(int)theSize;
- (SBReversiStateCount)countSquares;
- (id)moveForCol:(int)x andRow:(int)y;

- (BOOL)isPassMove:(id)m;
- (void)validateMove:(id)move;

- (NSDictionary *)moveWithCol:(int)c andRow:(int)r;

/* for the View */
- (int)pieceAtRow:(int)row col:(int)col;
- (void)getRows:(int*)rows cols:(int*)cols;

@end

@interface SBReversiState : SBReversiBase <SBAlphaBetaState>
@end

@interface SBMutableReversiState : SBReversiBase <SBMutableAlphaBetaState>
@end
