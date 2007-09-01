/*
Copyright (C) 2007 Stig Brautaset. All rights reserved.

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

/**
@file SBAlphaBetaState.h
@brief Protocols used for working with SBAlphaBeta.
*/

/**
Common methods for the state protocols.

This protocol exists solely because I hate duplication. Please pretend that it doesn't exist. You should look at the documentation for the protocols inheriting from this one instead.
*/
@protocol SBAlphaBetaStateCommon < NSObject >

/**
Should return the current fitness. The fitness is a number indicating for fortuitous the state is for the current player.

Use a high positive number for very good, high negative number for very bad.
*/
- (double)currentFitness;

/**
Indicates the result at an end state. Return a positive value if the receiving state is a winning state for the current player, negative for a loss, or 0 if it is a draw. The result of calling this method on a non-leaf state is undefined.

SBAlphaBeta only cares whether the values returned from this method are negative, positive or zero; but you may wish to implement it to return a score that you can use for a high-score list.
*/
- (double)endStateScore;

/** 
Returns an array of all the available moves for the current player. An empty array means that there are no moves possible and that this is an end state. Use NSNull instances for pass moves, if your game allows passing.
*/
- (NSArray *)movesAvailable;

@end

/**
Protocol for mutable states.

The following methods are required for SBAlphaBeta to work with mutable states.
*/
@protocol SBMutableAlphaBetaState < SBAlphaBetaStateCommon >

/**
Should apply the given move to the state, transforming it into its successor. Please make sure to handle pass moves, if your game allow those.
*/
- (void)transformWithMove:(id)m;

/** 
The opposite of -transformWithMove:. The move passed in will always be the <em>last</em> move that was applied to it with -transformWithMove:, and the effect of this method should be to produce the previous state.

This means that each move returned by -movesAvailable must contain enough information to revert the move. For Othello, for example, each move could be an of co-ordinates: the first is the slot to put the current piece, the remaining are for pieces to flip.

*/
- (void)undoTransformWithMove:(id)m;

@end

/**
Protocol for immutable states.

Your immutable states must implement the following methods.
*/
@protocol SBAlphaBetaState < SBAlphaBetaStateCommon >

/**
Return the receiver's successor state.

This should be a different object to the receiver, and is assumed to be autoreleased.

The <a href="http://developer.apple.com/documentation/Cocoa/Reference/Foundation/Miscellaneous/Foundation_Functions/Reference/reference.html#//apple_ref/c/func/NSCopyObject">NSCopyObject()</a> C-function may come in handy when implementing this method.
*/
- (id)stateByApplyingMove:(id)move;

@end
