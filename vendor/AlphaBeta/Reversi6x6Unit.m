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


@implementation MutableReversi6x6Unit

- (void)setUp
{
    id state = [[SBMutableReversiState alloc] initWithBoardSize:6];
    ab = [SBAlphaBeta newWithState:state];
}

@end

@implementation Reversi6x6Unit

- (void)setUp
{
    id state = [[SBReversiState alloc] initWithBoardSize:6];
    ab = [SBAlphaBeta newWithState:state];
}

- (void)tearDown
{
    [ab release];
}

- (void)test01LegalMoves
{
    id st = [ab currentState];
    SBReversiStateCount c = [st countSquares];
    STAssertEquals(c.c[0], (unsigned)32, nil);
    STAssertEquals(c.c[1], (unsigned)2, nil);
    STAssertEquals(c.c[2], (unsigned)2, nil);
    
    id moves;
    STAssertNotNil(moves = [st movesAvailable], nil);
    STAssertEquals([moves count], (unsigned)4, nil);
    int i;
    for (i = 0; i < 4; i++) {
        id m2;
        switch (i) {
            case 0: m2 = [st moveWithCol:1 andRow:2]; break;
            case 1: m2 = [st moveWithCol:2 andRow:1]; break;
            case 2: m2 = [st moveWithCol:3 andRow:4]; break;
            case 3: m2 = [st moveWithCol:4 andRow:3]; break;
        }
        STAssertEqualObjects([[moves objectAtIndex:i] objectAtIndex:0], m2, nil);
    }
}

- (void)test02Trace
{
    STAssertEqualObjects([[ab currentState] description],
        @"1: 000000 000000 002100 001200 000000 000000", nil);
    
    id s, states = [[NSArray arrayWithObjects:
        @"2: 000000 000000 011100 001200 000000 000000",
        @"1: 000000 000000 011100 022200 000000 000000",
        @"2: 000000 000000 011100 021200 001000 000000",
        @"1: 000000 000200 012200 021200 001000 000000",
        @"2: 000000 000200 011110 021100 001000 000000",
        @"1: 000000 000200 011210 021200 001200 000000",
        @"2: 000000 000210 011110 021200 001200 000000",
        @"1: 000000 200210 021110 022200 001200 000000",
        @"2: 000000 200210 111110 012200 001200 000000",
        @"1: 000000 200210 211110 222200 001200 000000",
        @"2: 000000 200210 211110 212200 101200 000000",
        @"1: 000000 200210 211110 212200 201200 200000",
        @"2: 000100 200110 211110 212200 201200 200000",
        @"1: 000102 200120 211210 212200 201200 200000",
        @"2: 000102 200120 211210 211110 201200 200000",
        @"1: 000122 200220 212210 221110 201200 200000",
        @"2: 000122 200210 212211 221110 201200 200000",
        @"1: 000122 200222 212211 221110 201200 200000",
        @"2: 001122 200122 212211 221110 201200 200000",
        @"1: 022222 200122 212211 221110 201200 200000",
        @"2: 022222 201122 211111 221110 201200 200000",
        @"1: 022222 222222 221111 221110 201200 200000",
        @"2: 122222 212222 221111 221110 201200 200000",
        @"1: 122222 212222 222111 222110 202200 202000",
        @"2: 122222 212222 222111 222110 202100 202100",
        @"1: 122222 212222 222211 222120 202102 202100",
        @"2: 122222 212222 222211 222111 202102 202100",
        @"1: 122222 212222 222211 222111 202202 202220",
        @"2: 122222 212222 222211 222111 201202 212220",
        @"1: 122222 212222 222211 222111 222202 212220",
        @"2: 122222 212222 222211 222111 222201 211111",
        @"1: 122222 212222 222221 222221 222221 211111",
        nil] objectEnumerator];
    
    while (s = [states nextObject]) {
        STAssertEqualObjects([[ab applyMoveFromSearchWithPly:3] description], s, nil);
    }
    
    STAssertEquals([ab winner], (unsigned)2, @"player 2 won");
}

- (void)test03WeirdExceptionCase
{
    SBReversiBase *st = [ab currentState];
    st->player = 2;
    
    STAssertEqualObjects([st description], @"2: 000000 000000 002100 001200 000000 000000", nil);
    
    STAssertEqualObjects([st = [ab applyMove:[st moveForCol:2 andRow:4]] description], @"1: 000000 000000 002100 002200 002000 000000", nil);
    STAssertEqualObjects([st = [ab applyMove:[st moveForCol:3 andRow:4]] description], @"2: 000000 000000 002100 002100 002100 000000", nil);

    STAssertEqualObjects([st = [ab applyMove:[st moveForCol:4 andRow:4]] description], @"1: 000000 000000 002100 002200 002220 000000", nil);
    STAssertEqualObjects([st = [ab applyMove:[st moveForCol:3 andRow:5]] description], @"2: 000000 000000 002100 002100 002120 000100", nil);
    
    STAssertEqualObjects([st = [ab applyMove:[st moveForCol:4 andRow:3]] description], @"1: 000000 000000 002100 002220 002120 000100", nil);
    STAssertEqualObjects([st = [ab applyMove:[st moveForCol:5 andRow:4]] description], @"2: 000000 000000 002100 002210 002111 000100", nil);
    
    STAssertEqualObjects([st = [ab applyMove:[st moveForCol:4 andRow:5]] description], @"1: 000000 000000 002100 002210 002211 000120", nil);
    STAssertEqualObjects([st = [ab applyMove:[st moveForCol:5 andRow:5]] description], @"2: 000000 000000 002100 002210 002211 000111", nil);
    
    STAssertEqualObjects([st = [ab applyMove:[st moveForCol:4 andRow:2]] description], @"1: 000000 000000 002220 002210 002211 000111", nil);
    STAssertEqualObjects([st = [ab applyMove:[st moveForCol:2 andRow:5]] description], @"2: 000000 000000 002220 002210 002111 001111", nil);

    STAssertEqualObjects([st = [ab applyMove:[st moveForCol:5 andRow:3]] description], @"1: 000000 000000 002220 002222 002111 001111", nil);
    STAssertEquals([ab countMoves], (unsigned)11, nil);
    STAssertNotNil([ab applyMoveFromSearchWithPly:3], nil);
    STAssertEquals([ab countMoves], (unsigned)12, nil);

    /* Test for weird case where with finding moves */
    [ab undoLastMove];
    STAssertEqualObjects([st = [ab applyMove:[st moveForCol:5 andRow:2]] description], @"2: 000000 000000 002221 002211 002111 001111", nil);
    STAssertEquals([ab playerTurn], (unsigned)1, nil);
    NSArray *a = [[ab currentState] movesAvailable];
    STAssertEquals([a count], (unsigned)1, nil);
    STAssertTrue([[a lastObject] isKindOfClass:[NSNull class]], nil);
}

@end
