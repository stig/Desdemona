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

#import "SBAlphaBeta.h"

@implementation SBAlphaBeta

#pragma mark Creation & Cleanup

- (id)init
{
    [NSException raise:@"abort"
                format:@"Use -initWithState: instead"];
    return nil;
}


- (id)initWithState:(id)this
{
    if (self = [super init]) {
        if ([this conformsToProtocol:@protocol(SBUndoableAlphaBetaSearching)])
            mutableStates = YES;
        
        if (![this conformsToProtocol:@protocol(SBAlphaBetaSearching)])
            [NSException raise:@"not-a-state"
                        format:@"State %@ lacks necessary methods", this];

        stateHistory = [[NSMutableArray arrayWithObject:this] retain];
        moveHistory = [NSMutableArray new];
    }
    return self;
}

+ (id)newWithState:(id)this
{
    return [[self alloc] initWithState:this];
}

- (void)dealloc
{
    [stateHistory release];
    [moveHistory release];
    [super dealloc];
}


#pragma mark Private methods

- (id)successorByApplying:(id)m to:(id)state
{
    if (!mutableStates)
        state = [[state copy] autorelease];

    [state applyMove:m];
    return state;
}

- (void)undoApplying:(id)m to:(id)state
{
    if (mutableStates)
        [state undoMove:m];
}

- (double)abWithState:(id)current alpha:(double)alpha beta:(double)beta plyLeft:(unsigned)ply
{
    statesVisited++;
    
    /* If we're doing iterative search and have run out of time, return.
       It doesn't matter what value we return, because it will be
       ignored. Benchmarks reveals this test is quite cheap, so taking
       the tiny performance hit is certainly worth it for the accuracy
       it gives us in timekeeping.
     */
    if (dateLimit && [dateLimit compare:[NSDate date]] < 0)
        return 0.0;
    
    /* For correctness we should really check for end of the game before
       we check if we have reached max ply, but doing this speeds up
       fixed-depth search by 33% (for Reversi).
     */
    if (!ply) {
        foundEnd = NO;
        return [current fitness];
    }
    
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSArray *mvs = [current legalMoves];
    if (![mvs count])
        return [current fitness];
    
    id iter = [mvs objectEnumerator];
    for (id m; m = [iter nextObject];) {

        id successor = [self successorByApplying:m to:current];
        double sc = -[self abWithState:successor alpha:-beta beta:-alpha plyLeft:ply-1];
        [self undoApplying:m to:successor];

        alpha = alpha > sc ? alpha : sc;
        
        if (alpha >= beta)
            goto cut;
    }

cut:
    [pool release];
    return alpha;
}

#pragma mark Search methods

- (id)moveFromSearchWithDepth:(unsigned)ply
{
    double alpha = -INFINITY;
    double beta  = +INFINITY;
    
    if (ply < 1)
        [NSException raise:@"ply-too-low" format:@"Ply must be 1 or greater"];
    
    statesVisited = 0;
    dateLimit = nil;
    
    id best = nil;
    id current = [[self currentState] copy];

    NSArray *mvs = [current legalMoves];
    NSEnumerator *iter = [mvs objectEnumerator];
    for (id m; ply && (m = [iter nextObject]); ) {
        
        id successor = [self successorByApplying:m to:current];
        double sc = -[self abWithState:successor alpha:-beta beta:-alpha plyLeft:ply-1];
        [self undoApplying:m to:successor];

        if (sc > alpha) {
            alpha = sc;
            best = m;
        }
    }
    
    [current release];
    return best;
}

- (id)performMoveFromSearchWithDepth:(unsigned)ply
{
    id best = [self moveFromSearchWithDepth:ply];
    return best ? [self performMove:best] : nil;
}

- (id)moveFromSearchWithInterval:(NSTimeInterval)interval
{
    id best = nil;
    unsigned accumulatedStatesVisited = 0;
    
    dateLimit = [NSDate dateWithTimeIntervalSinceNow:interval * .975];
    
    id current = [[self currentState] copy];
    NSArray *mvs = [current legalMoves];
    
    for (unsigned ply = 1;; ply++) {

        unsigned leafCount = 0;
        id bestAtThisPly = nil;

        double alpha = -INFINITY;
        double beta  = +INFINITY;
        statesVisited = 0;

        /** @todo When searching to ply N+1, order the moves so we
            search the most promising one from search to ply N.
            This has the potential of speeding up search a lot.
         */
        NSEnumerator *iter = [mvs objectEnumerator];

        for (id m; m = [iter nextObject]; ) {
        
            /* Reset the 'reached a leaf state' indicator. */
            foundEnd = YES;

            id successor = [self successorByApplying:m to:current];
            double sc = -[self abWithState:successor alpha:-beta beta:-alpha plyLeft:ply-1];
            if (sc > alpha) {
                alpha = sc;
                bestAtThisPly = m;
            }
            [self undoApplying:m to:successor];

            /* Check if we have any time left. */
            if ([dateLimit compare:[NSDate date]] < 0)
                goto time_is_up;
            
            if (foundEnd)
                leafCount++;
        }

        /* If we got here then we should replace the current best move,
           since we just finished a search to a deeper level than before.
         */
        best = bestAtThisPly;
        plyReached = ply;
        accumulatedStatesVisited += statesVisited;

        /* If we found a leaf state for every move, then we're done. We
           don't need to search deeper. */
        if (leafCount == [mvs count]) {
            /* See note above in the internal ab method. */
            plyReached--;
            break;
        }
    }

time_is_up:
    [current release];
    if (statesVisited = accumulatedStatesVisited)
        return best;

    /* If we got here then we didn't even finish searching to 1 ply. This is
       probably because someone gave a ridiculously low interval. Simply set
       plyReached and perform a fixed-depth search in that case. */
    plyReached = 1;
    return [self moveFromSearchWithDepth:1];
}

- (id)performMoveFromSearchWithInterval:(NSTimeInterval)interval
{
    id best = [self moveFromSearchWithInterval:interval];
    return best ? [self performMove:best] : nil;
}    

#pragma mark Methods

- (id)performMove:(id)m
{
    id moves = [self currentLegalMoves];
    if (NSNotFound == [moves indexOfObject:m]) {
        /* Check that move is in the current allowed move list */
        [NSException raise:@"illegalmove"
                    format:@"%@ is not one of the legal moves: %@", m, moves];
    }

    id state = [[self currentState] copy];
    [state applyMove:m];
    [stateHistory addObject:[state autorelease]];
    [moveHistory addObject:m];
    return state;
}


- (id)undoLastMove
{
    [moveHistory removeLastObject];
    [stateHistory removeLastObject];
    return [self currentState];
}

- (id)currentState
{
    return [stateHistory lastObject];
}

- (id)lastMove
{
    return [moveHistory lastObject];
}

- (unsigned)countPerformedMoves
{
    return [moveHistory count];
}

- (unsigned)currentPlayer
{
    return ([self countPerformedMoves] % 2) + 1;
}

- (unsigned)winner
{
    if (![self isGameOver])
        [NSException raise:@"game-not-over"
                    format:@"Cannot determine winner; game has not ended yet"];

    id state = [self currentState];
    if ([state isDraw])
        return 0;

    return [state isWin]
        ? [self currentPlayer]
        : 3 - [self currentPlayer];
}


- (BOOL)isGameOver
{
    NSArray *a = [self currentLegalMoves];
    return [a count] ? NO : YES;
}

- (unsigned)depthForSearch
{
    return plyReached;
}

- (unsigned)stateCountForSearch
{
    return statesVisited;
}


- (BOOL)isForcedPass
{
    id mvs = [self currentLegalMoves];
    if (mvs && [mvs count] == 1)
        if ([[mvs lastObject] isKindOfClass:[NSNull class]])
            return YES;
    return NO;
}

#pragma mark Simple forwarders

- (double)currentFitness
{
    return [[self currentState] fitness];
}

- (NSArray *)currentLegalMoves
{
    return [[self currentState] legalMoves];
}


@end

