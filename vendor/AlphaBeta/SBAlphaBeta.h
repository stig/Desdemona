/*
Copyright (c) 2006,2007 Stig Brautaset. All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

  Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

  Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

  Neither the name of the author nor the names of its contributors may be used
  to endorse or promote products derived from this software without specific
  prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
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

- (void)setState:(id)x;

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

