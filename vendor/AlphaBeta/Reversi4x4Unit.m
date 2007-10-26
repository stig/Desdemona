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
