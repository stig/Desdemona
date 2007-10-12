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

#import <Foundation/Foundation.h>

// Required protocol for states. Your States *must* implement this
// protocol to be used with SBAlphaBeta.
@protocol SBAlphaBetaSearching < NSCopying >

- (double)fitness;
- (NSArray *)legalMoves;
- (void)applyMove:(id)m;

@end

// Additional *optional* protocol for states. If you implement this
// then SBAlphaBeta will make fewer copies of your states during
// search. (Which could be useful if copy is an expensive operation.)
@protocol SBUndoableAlphaBetaSearching

- (void)undoMove:(id)m;

@end

// Yet another additional *optional* protocol for states. If you
// implement this then SBAlphaBeta will be able to tell you which
// player won at the end of the game. Otherwise you'd have to query
// the state itself manually. The methods here will only ever be
// called after the game has ended.
@protocol SBAlphaBetaStatus

- (BOOL)isDraw;
- (BOOL)isWin;

@end


@interface SBAlphaBeta : NSObject {
    @private
    BOOL mutableStates;
    NSMutableArray *stateHistory;
    NSMutableArray *moveHistory;

    NSDate *dateLimit;
    unsigned plyReached;
    unsigned statesVisited;
    BOOL foundEnd;
}

+ (id)newWithState:(id)this;
- (id)initWithState:(id)this;

- (id)currentState;
- (double)currentFitness;
- (NSArray *)currentLegalMoves;
- (unsigned)currentPlayer;

- (id)performMove:(id)m;
- (id)undoLastMove;

- (id)lastMove;
- (unsigned)countPerformedMoves;

- (BOOL)isGameOver;
- (BOOL)isForcedPass;
- (unsigned)winner;

/* search methods */
- (id)moveFromSearchWithDepth:(unsigned)ply;
- (id)moveFromSearchWithInterval:(NSTimeInterval)interval;
- (id)performMoveFromSearchWithDepth:(unsigned)ply;
- (id)performMoveFromSearchWithInterval:(NSTimeInterval)interval;

/* metadata releated to previous search */
- (unsigned)stateCountForSearch;
- (unsigned)depthForSearch;

@end

