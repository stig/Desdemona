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

- (id)lastMove;
- (id)currentState;
- (BOOL)isGameOver;
- (BOOL)currentPlayerMustPass;
- (unsigned)countMoves;
- (unsigned)playerTurn;
- (unsigned)winner;
- (id)applyMove:(id)m;
- (id)undoLastMove;

/* messages forwarded to the state */
- (double)currentFitness;
- (NSArray *)movesAvailable;

/* search methods */
- (id)moveFromSearchWithPly:(unsigned)ply;
- (id)moveFromSearchWithInterval:(NSTimeInterval)interval;
- (id)applyMoveFromSearchWithPly:(unsigned)ply;
- (id)applyMoveFromSearchWithInterval:(NSTimeInterval)interval;

/* metadata releated to search */
- (unsigned)countStatesVisited;
- (unsigned)plyReachedForSearch;

@end



/**
@file 
@brief Generic implementation of the Alpha-Beta algorithm.

@mainpage AlphaBeta

SBAlphaBeta encapsulates the Alpha-Beta algorithm (aka Minimax search with Alpha-Beta pruning) and can be used to create AIs for a large range of two-player games. No prior experience with Artificial Intelligence is necessary.

For the Alpha-Beta algorithm to be applicable to your game it needs to be a two-player <a href="http://en.wikipedia.org/wiki/Zero-sum">zero sum</a> <a href="http://en.wikipedia.org/wiki/Perfect_information">perfect information</a> game. The term <em>two-player</em> just means that there must be two opposing sides (football is considered two-player, for example). A <em>zero sum</em> game is one where an advantage for one player is an equally large disadvantage for the other. <em>Perfect information</em> basically rules out any game that has an element of chance. Yatzee? Right out the window. Poker? Forget about it. Jenga? Not even <em>close</em>.

For games that have these properties, for example Chess, Checkers, Go, Othello, Connect-4 and Tic-Tac-Toe, it is possible to set up a game tree to aid in the selection of the next move. For simplicity, consider the starting state of Tic-Tac-Toe to be the root of a tree. The root has nine branches, each leading to a successor state. Each of these has 8 branches leading to <em>its</em> successor states and so on. Some of the paths through the tree will end before others (a winning state is reached before all the slots have been filled) but some paths continue until there are no more legal moves. For Tic-Tac-Toe this will invariably happen at depth 9 (or <em>ply</em> 9 in game-tree terminology).

After having exhausted the search space of the game, it is easy to find the paths that will lead to victory for either player. Knowing the path that x can take to the fastest victory is generally of little use, because o can thwart x's plans of a swift victory any time it is her turn to move. Thus, instead of traversing the  path leading to the fastest possible victory, x's best aim is to pick a path  where her <em>worst</em> outcome will be victory (the <em>best worst-case</em> path).

The Minimax algorithm tries to find the best worst case path through a search tree. It is very time-consuming, and alpha-beta pruning is a way of speeding up the algorithm. I encourage you to read my article on <a href="http://blog.brautaset.org/2007/08/17/game-tree-search-the-minimax-and-alpha-beta-algorithms/">game-tree search, the Minimax algorithm and alpha-beta pruning</a> if you don't already know how it all hangs together.


@section example_sec Example

Assuming MyGameState implements SBAlphaBetaState, here's how one could implement a very simple game:

@code
id state = [MyGameState new];
id ab = [SBAlphaBeta newWithState:state];

while (![ab isGameOver]) {

    // This NSLog output will be boring
    // unless you override -description.
    NSLog(@"%@", [ab currentState]);

    if (1 == [ab playerTurn]) {
        // Spend 300 ms searching for the best move,
        // then apply that move to the current state
        [ab applyMoveFromSearchWithInterval:0.3];
        
    }
    else {
        // Get a move from a human player and apply that
        [ab applyMove:get_player_move()];
    }
}
@endcode

@section maturity_sec A note on code & interface maturity

Though the underlying code is quite mature and well tested, I'm still not entirely happy with the interface. Thus the API may still change between releases. The broad strokes are there, however, so you should find it relatively simple to update to any new versions.

@section users_sec Who/what uses SBAlphaBeta?

I maintain several Cocoa games for Mac OS X that all use SBAlphaBeta to provide their AIs. For example:

@li <a href="/Phage">Phage</a> - an abstract strategy game not <em>entirely</em> unlike Chess
@li <a href="/Auberon">Auberon</a> - a Connect-4 game
@li <a href="/Desdemona">Desdemona</a> - a Reversi (Othello) game

@section code_sec Getting the code

Download <a href="__DMGURL__">AlphaBeta __VERSION__</a>, containing an embeddable framework, or get the source from Subversion:

@verbatim
svn co http://svn.brautaset.org/trunk/AlphaBeta AlphaBeta
@endverbatim

If you're using a previous version, be sure to find out <a href="http://svn.brautaset.org/trunk/AlphaBeta/Changes">what has changed</a>.

@section feedback_sec Feedback / Bugreports

Please send praise and bile to <a href="mailto:stig@brautaset.org">stig@brautaset.org</a>.

@section lisence_sec Copyright & Lisence

AlphaBeta is released under the GPL2.

*/
