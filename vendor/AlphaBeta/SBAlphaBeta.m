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


#import "SBAlphaBeta.h"
#import "SBAlphaBetaState.h"

/** 
Encapsulation of the Alpha-Beta algorithm.

SBAlphaBeta is a generic implementation of the Alpha-Beta algorithm. It doesn't need to know anything at all about the rules of your game; other than that it is between two players that takes turn moving. It can be used to create AIs for a whole host of games.

To use SBAlphaBeta you need to initialise it with an instance of your game state class; this will be used as the initial state of the game. A state is a discrete game state--a point in time between moves. A move contains the information required for transforming a state into its successor.

SBAlphaBeta cares not what the types of your states and moves are. States can be immutable or mutable and must implement either the SBAlphaBetaState or the SBMutableAlphaBetaState protocol. The section @ref statemutability_sec has a short discussion on the pros and cons of each.

Moves must implement the below informal protocol. Personally I like using  NSArray, NSDictionary, NSString and NSNumber; these classes already implement the required protocol. I've also found NSNull convenient for pass moves.

@code
-(BOOL)isEqual:(id)object;
-(unsigned)hash;
@endcode

Though not required it is advised that you override -description to return something sensible for both states and moves. This can make debugging easier if you make a false step and feed SBAlphaBeta unexpected data, as the exceptions thrown will make more sense.

@section statemutability_sec Should I use mutable or immutable states?

It's a good question. I've toyed with the idea of only supporting one, to avoid the dilemma of having to choose. The problem is that I can't pick which one to support. They each have their own pros and cons. 

If you go with mutable states, the moves you return from -movesAvailable must contain enough information to undo the effects of a move; with immutable states they don't. This can mean your moves must contain more information. On the other hand, having more information in the moves might make applying the move cheaper.

Consider Reversi: if you use mutable states your moves must contain a list of all the slots that were flipped, in addition to the slot where you put your piece, because it is impossible to deduce that when the time comes to revert the move. This uses more memory and if your game has a high branching factor this might become significant. On the other hand if you use immutable states there is no need to implement undo; SBAlphaBeta has a copy of the previous state on its history stack already, so it just pops off the current one. Your moves don't need to contain anything but the coordinates of the slot you're putting your piece. However, your routine to perform a move must now be more clever and find which pieces to flip; with rich moves you just have to flip the pieces specified in the move.

With immutable states you have to make a complete copy of the entire state, which can be expensive; on the other hand undo is extremely cheap, and you don't have to write any code to do it. Again, SBAlphaBeta just pops a stack.

*/

@implementation SBAlphaBeta

#pragma mark Creation & Cleanup

- (id)init
{
    [NSException raise:@"abort"
                format:@"Use -initWithState: instead"];
    return nil;
}

/** Initialise an SBAlphaBeta object with a starting state. */
- (id)initWithState:(id)this
{
    if (self = [super init]) {
        if ([this conformsToProtocol:@protocol(SBMutableAlphaBetaState)]) {
            mutableStates = YES;
        
        } else if ([this conformsToProtocol:@protocol(SBAlphaBetaState)]) {
            mutableStates = NO;

        } else {
            [NSException raise:@"not-a-state"
                        format:@"State %@ lacks necessary methods", this];
        }
        stateHistory = [[NSMutableArray arrayWithObject:this] retain];
        moveHistory = [NSMutableArray new];
    }
    return self;
}

/** Shortcut for calling alloc & initWithState:. */
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

- (id)move:(id)m
{
    id state = [self currentState];
    if (mutableStates) {
        [state transformWithMove:m];
    
    } else {
        state = [state stateByApplyingMove:m];
        [stateHistory addObject:state];
    }
    return state;
}

- (id)undo:(id)m
{
    if (mutableStates) {
        [[self currentState] undoTransformWithMove:m];

    } else {
        [stateHistory removeLastObject];
    }
    
    return [self currentState];
}

- (double)abWithState:(id)state alpha:(double)alpha beta:(double)beta plyLeft:(unsigned)ply
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
        return [self currentFitness];
    }
    
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSArray *mvs = [self movesAvailable];
    if (![mvs count])
        return [self currentFitness];
    
    id iter = [mvs objectEnumerator];
    for (id m; m = [iter nextObject];) {
        id nextState = [self move:m];
        double sc = -[self abWithState:nextState alpha:-beta beta:-alpha plyLeft:ply-1];
        alpha = alpha > sc ? alpha : sc;
        [self undo:m];
        
        if (alpha >= beta)
            goto cut;
    }

cut:
    [pool release];
    return alpha;
}

#pragma mark Search methods

/**
Performs a fixed-depth search to the given @p ply.
Returns the best move found.
 */
- (id)moveFromSearchWithPly:(unsigned)ply
{
    double alpha = -INFINITY;
    double beta  = +INFINITY;
    
    statesVisited = 0;
    dateLimit = nil;
    
    id best = nil;
    NSArray *mvs = [self movesAvailable];
    NSEnumerator *iter = [mvs objectEnumerator];
    for (id m; ply && (m = [iter nextObject]); ) {
        
        id state = [self move:m];
        double sc = -[self abWithState:state alpha:-beta beta:-alpha plyLeft:ply-1];
        if (sc > alpha) {
            alpha = sc;
            best = m;
        }
        [self undo:m];
    }
    
    return best;
}

/**
Performs a fixed-depth search to the given @p ply and applies the best move found.
 */
- (id)applyMoveFromSearchWithPly:(unsigned)ply
{
    id best = [self moveFromSearchWithPly:ply];
    return best ? [self applyMove:best] : nil;
}

/**
Performs an iterative search for up to @p interval seconds.
Return the best move found.

Fractional seconds are supported, so an interval of 0.3 makes for a
search that lasts up to 300 milliseconds.
 */
- (id)moveFromSearchWithInterval:(NSTimeInterval)interval
{
    id best = nil;
    unsigned accumulatedStatesVisited = 0;
    
    dateLimit = [NSDate dateWithTimeIntervalSinceNow:interval * .98];
    NSArray *mvs = [self movesAvailable];
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

            id state = [self move:m];
            double sc = -[self abWithState:state alpha:-beta beta:-alpha plyLeft:ply-1];
            if (sc > alpha) {
                alpha = sc;
                bestAtThisPly = m;
            }
            [self undo:m];

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
           don't need to search deeper.
         */
        if (leafCount == [mvs count]) {
            /* See note above in the internal ab method. */
            plyReached--;
            break;
        }
    }

time_is_up:
    statesVisited = accumulatedStatesVisited;
    return best;
}

/**
Performs an iterative search for up to @p interval seconds and applies the best move found.

Fractional seconds are supported, so an interval of 0.3 makes for a
search that lasts up to 300 milliseconds.
 */
- (id)applyMoveFromSearchWithInterval:(NSTimeInterval)interval
{
    id best = [self moveFromSearchWithInterval:interval];
    return best ? [self applyMove:best] : nil;
}    

#pragma mark Methods

/**
Apply the given move to the current state.
Returns the new current state.
*/
- (id)applyMove:(id)m
{
    id moves = [self movesAvailable];
    if (NSNotFound == [moves indexOfObject:m]) {
        /* Check that move is in the current allowed move list */
        [NSException raise:@"illegalmove"
                    format:@"%@ is not one of the legal moves: %@", m, moves];
    }

    [moveHistory addObject:m];
    return [self move:m];
}


/**
Undo one position from the given state.
Returns the new current state.
*/
- (id)undoLastMove
{
    if (![moveHistory count]) {
        [NSException raise:@"undo"
                    format:@"No moves to undo"];
    }
    [self undo:[self lastMove]];
    [moveHistory removeLastObject];
    return [self currentState];
}

/** Returns the current state. */
- (id)currentState
{
    return [stateHistory lastObject];
}

/** Returns the last move that was applied. */
- (id)lastMove
{
    return [moveHistory lastObject];
}

/** Returns a count of the number of moves since the initial state. */
- (unsigned)countMoves
{
    return [moveHistory count];
}

/**
Returns 1 or 2, depending on whose turn it is to move.
Player "1" is arbitrarily defined to be the player whose turn it is to play at the start of the game, which is not necessarily the same as the state itself thinks of as player 1 (if it thinks of the players in those terms; it may use @"a" or @"b" instead).
*/
- (unsigned)playerTurn
{
    return ([self countMoves] % 2) + 1;
}

/**
Returns 1 or 2 for the winning player, or 0 if the game ended in a draw.
*/
- (unsigned)winner
{
    if (![self isGameOver])
        [NSException raise:@"game-not-over"
                    format:@"Cannot determine winner; game has not ended yet"];

    double score = [[self currentState] endStateScore];
    if (!score)
        return 0;
    unsigned player = [self playerTurn];
    return score > 0 ? player : 3 - player;
}


/** Returns true if the game is finished, false otherwise. */
- (BOOL)isGameOver
{
    NSArray *a = [self movesAvailable];
    return [a count] ? NO : YES;
}

/**
Return the depth reached by the last iterative search. The returned value is undefined if no iterative search has been executed yet.
 */
- (unsigned)plyReachedForSearch
{
    return plyReached;
}

/**
Return the number of states visited by the last search.

If the last search was an iterative one, the number of visited states is accumulated across all the *completed* iterations.
*/
- (unsigned)countStatesVisited
{
    return statesVisited;
}


/** Returns true if the current player has no option but to pass. */
- (BOOL)currentPlayerMustPass
{
    id mvs = [self movesAvailable];
    if (mvs && [mvs count] == 1)
        if ([[mvs lastObject] isKindOfClass:[NSNull class]])
            return YES;
    return NO;
}

#pragma mark Simple forwarders

/** Returns currentFitness from the current state. */
- (double)currentFitness
{
    return [[self currentState] currentFitness];
}

/** Returns available moves from the current state. */
- (NSArray *)movesAvailable
{
    return [[self currentState] movesAvailable];
}


@end

