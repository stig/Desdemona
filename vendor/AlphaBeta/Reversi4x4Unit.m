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

#import "ReversiUnit.h"

@implementation MutableReversi4x4Unit

- (void)setUp
{
    id state = [[SBMutableReversiState alloc] initWithBoardSize:4];
    ab = [SBAlphaBeta newWithState:state];
}

@end

@implementation Reversi4x4Unit

- (void)setUp
{
    id state = [[SBReversiState alloc] initWithBoardSize:4];
    ab = [SBAlphaBeta newWithState:state];
}

- (void)tearDown
{
    [ab release];
}

/* -currentState, -lastMove, -countPerformedMoves & -currentPlayer are heavily
interlinked, so it makes sense to test them together. -applyMove and
-undoLastMove are also tested here, albeit implicitly.
*/
- (void)test01Basics
{
    STAssertNil([ab lastMove], nil);
    STAssertEquals([ab countPerformedMoves], (unsigned)0, nil);
    STAssertEquals([ab currentPlayer], (unsigned)1, nil);
    STAssertEqualObjects([[ab currentState] description], @"1: 0000 0210 0120 0000", nil);

    id m1 = [[ab currentState] moveForCol:0 andRow:1];
    [ab performMove:m1];
    STAssertEqualObjects([ab lastMove], m1, nil);
    STAssertEquals([ab countPerformedMoves], (unsigned)1, nil);
    STAssertEquals([ab currentPlayer], (unsigned)2, nil);
    STAssertEqualObjects([[ab currentState] description], @"2: 0000 1110 0120 0000", nil);
    
    id m2 = [[ab currentState] moveForCol:0 andRow:2];
    [ab performMove:m2];
    STAssertEqualObjects([ab lastMove], m2, nil);
    STAssertEquals([ab countPerformedMoves], (unsigned)2, nil);
    STAssertEquals([ab currentPlayer], (unsigned)1, nil);
    STAssertEqualObjects([[ab currentState] description], @"1: 0000 1110 2220 0000", nil);

    [ab undoLastMove];
    STAssertEqualObjects([ab lastMove], m1, nil);
    STAssertEquals([ab countPerformedMoves], (unsigned)1, nil);
    STAssertEquals([ab currentPlayer], (unsigned)2, nil);
    STAssertEqualObjects([[ab currentState] description], @"2: 0000 1110 0120 0000", nil);

    id m3 = [[ab currentState] moveForCol:2 andRow:0];
    [ab performMove:m3];
    STAssertEqualObjects([ab lastMove], m3, nil);
    STAssertEquals([ab countPerformedMoves], (unsigned)2, nil);
    STAssertEquals([ab currentPlayer], (unsigned)1, nil);
    STAssertEqualObjects([[ab currentState] description], @"1: 0020 1120 0120 0000", nil);
}

- (void)test02StateAndFitness
{
    id st = [ab currentState];
    STAssertEquals([ab currentPlayer], (unsigned)1, nil);
    STAssertEquals([ab currentFitness], (double)0.0, nil);

    STAssertEqualObjects([st description], @"1: 0000 0210 0120 0000", nil);

    STAssertNoThrow(st = [ab performMove:[st moveForCol:1 andRow:0]], nil);
    STAssertEqualObjects([st description], @"2: 0100 0110 0120 0000", nil);
    STAssertEqualsWithAccuracy([ab currentFitness], (double)-3.0, 0.0001, @"got %f", [st currentFitness]);
    STAssertEquals([ab currentPlayer], (unsigned)2, nil);

    STAssertNoThrow(st = [ab performMove:[st moveForCol:2 andRow:0]], nil);
    STAssertEqualObjects([st description], @"1: 0120 0120 0120 0000", nil);
    STAssertEqualsWithAccuracy([ab currentFitness], (double)0.0, 0.0001, @"got %f", [st currentFitness]);
    STAssertEquals([ab currentPlayer], (unsigned)1, nil);

    STAssertNoThrow(st = [ab performMove:[st moveForCol:3 andRow:3]], nil);
    STAssertEqualObjects([st description], @"2: 0120 0120 0110 0001", nil);
    STAssertEqualsWithAccuracy([ab currentFitness], (double)-1.0, 0.0001, @"got %f", [st currentFitness]);
    STAssertEquals([ab currentPlayer], (unsigned)2, nil);
}

- (void)test03MustPass
{
    SBReversiState *st = [ab currentState];
    
    for (int i = 0; i < 4; i++)
        for (int j = 0; j < 4; j++)
            st->board[i][j] = 0;

    st->board[0][0] = 2;
    st->board[1][0] = 1;

    STAssertEquals([ab currentPlayer], (unsigned)1, @"it is player 1");
    STAssertTrue([ab isForcedPass], @"must pass");
    
    STAssertNotNil([ab performMove:[NSNull null]], @"can apply pass move");
    STAssertEquals([ab currentPlayer], (unsigned)2, @"it is player 1");
    STAssertFalse([ab isForcedPass], @"must NOT pass");
}

@end
