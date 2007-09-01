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

#import "TTTUnit.h"

@implementation TTTMutableUnit

- (void)setUp
{
    ab = [SBAlphaBeta newWithState:[TTTMutableState new]];
}

@end

@implementation TTTUnit

- (void)setUp
{
    ab = [SBAlphaBeta newWithState:[TTTState new]];
}

- (void)tearDown
{
    [ab release];
}

/* Helper method */
- (id)moveWithCol:(int)c andRow:(int)r
{
    return [NSDictionary dictionaryWithObjectsAndKeys:
        [NSNumber numberWithInt: r], @"row",
        [NSNumber numberWithInt: c], @"col",
        nil];
}

/* -currentState, -lastMove, -countMoves & -playerTurn are heavily
interlinked, so it makes sense to test them together. -applyMove and
-undoLastMove are also tested here, albeit implicitly.
*/
- (void)test01Basics
{
    STAssertNil([ab lastMove], nil);
    STAssertEquals([ab countMoves], (unsigned)0, nil);
    STAssertEquals([ab playerTurn], (unsigned)1, nil);
    STAssertEqualObjects([[ab currentState] description], @"000 000 000", nil);

    id m1 = [self moveWithCol:0 andRow:0];
    [ab applyMove:m1];
    STAssertEqualObjects([ab lastMove], m1, nil);
    STAssertEquals([ab countMoves], (unsigned)1, nil);
    STAssertEquals([ab playerTurn], (unsigned)2, nil);
    STAssertEqualObjects([[ab currentState] description], @"100 000 000", nil);
    
    id m2 = [self moveWithCol:1 andRow:0];
    [ab applyMove:m2];
    STAssertEqualObjects([ab lastMove], m2, nil);
    STAssertEquals([ab countMoves], (unsigned)2, nil);
    STAssertEquals([ab playerTurn], (unsigned)1, nil);
    STAssertEqualObjects([[ab currentState] description], @"120 000 000", nil);

    [ab undoLastMove];
    STAssertEqualObjects([ab lastMove], m1, nil);
    STAssertEquals([ab countMoves], (unsigned)1, nil);
    STAssertEquals([ab playerTurn], (unsigned)2, nil);
    STAssertEqualObjects([[ab currentState] description], @"100 000 000", nil);

    id m3 = [self moveWithCol:1 andRow:1];
    [ab applyMove:m3];
    STAssertEqualObjects([ab lastMove], m3, nil);
    STAssertEquals([ab countMoves], (unsigned)2, nil);
    STAssertEquals([ab playerTurn], (unsigned)1, nil);
    STAssertEqualObjects([[ab currentState] description], @"100 020 000", nil);
}

/* Case 1: game over because one of the players won.
   We reach a win state for player 1, then for player 2.
   Test current player's low fitness at end of the game.
*/
- (void)test02GameOverWithWin
{
    NSArray *moves = [NSArray arrayWithObjects:
        [self moveWithCol:0 andRow:0],
        [self moveWithCol:0 andRow:1],
        [self moveWithCol:1 andRow:0],
        [self moveWithCol:1 andRow:1],
        [self moveWithCol:2 andRow:0],
        nil];
    for (int i = 0; i < [moves count]; i++) {
        STAssertFalse([ab isGameOver], nil);
        STAssertThrows([ab winner], nil);
        [ab applyMove:[moves objectAtIndex:i]];
    }
    STAssertTrue([ab isGameOver], nil);
    STAssertEquals([ab winner], (unsigned)1, nil);
    STAssertEqualsWithAccuracy([ab currentFitness], (double)-897.0, 0.001, nil);

    [ab undoLastMove];
    [ab applyMove:[self moveWithCol:2 andRow:2]];
    [ab applyMove:[self moveWithCol:2 andRow:1]];
    STAssertTrue([ab isGameOver], nil);
    STAssertEquals([ab winner], (unsigned)2, nil);
    STAssertEqualsWithAccuracy([ab currentFitness], (double)-896.0, 0.001, nil);
}

/* Case 2: game over because there are no more legal moves.
   We reach a draw state, where fitness is zero.
*/
- (void)test02GameOverWithDraw
{
    NSArray *moves = [NSArray arrayWithObjects:
        [self moveWithCol:0 andRow:0],
        [self moveWithCol:0 andRow:1],
        [self moveWithCol:1 andRow:0],
        [self moveWithCol:1 andRow:1],
        [self moveWithCol:2 andRow:1],
        [self moveWithCol:2 andRow:0],
        [self moveWithCol:0 andRow:2],
        [self moveWithCol:1 andRow:2],
        [self moveWithCol:2 andRow:2],
        nil];
    for (int i = 0; i < [moves count]; i++) {
        STAssertFalse([ab isGameOver], nil);
        STAssertThrows([ab winner], nil);
        [ab applyMove:[moves objectAtIndex:i]];
    }
    STAssertTrue([ab isGameOver], nil);
    STAssertEquals([ab winner], (unsigned)0, nil);
    STAssertEqualsWithAccuracy([ab currentFitness], (double)0.0, 0.000001, nil);
}

- (void)test03Fitness
{
    STAssertEquals([ab currentFitness], (double)0.0, nil);

    [ab applyMove:[self moveWithCol:0 andRow:0]];
    STAssertEqualsWithAccuracy([ab currentFitness], (double)-3.0, 0.0001, nil);

    [ab applyMove:[self moveWithCol:0 andRow:1]];
    STAssertEqualsWithAccuracy([ab currentFitness], (double)1.0, 0.0001, nil);

    [ab applyMove:[self moveWithCol:1 andRow:1]];
    STAssertEqualsWithAccuracy([ab currentFitness], (double)-7.0, 0.0001, nil);
}


- (void)test04LegalMoves
{
    id moves;
    STAssertNotNil(moves = [ab movesAvailable], nil);
    STAssertEquals([moves count], (unsigned)9, nil);
    
    for (int i = 0; i < [moves count]; i++) {
        id m2;
        switch (i) {
            case 0: m2 = [self moveWithCol:0 andRow:0]; break;
            case 1: m2 = [self moveWithCol:0 andRow:1]; break;
            case 2: m2 = [self moveWithCol:0 andRow:2]; break;
            case 3: m2 = [self moveWithCol:1 andRow:0]; break;
            case 4: m2 = [self moveWithCol:1 andRow:1]; break;
            case 5: m2 = [self moveWithCol:1 andRow:2]; break;
            case 6: m2 = [self moveWithCol:2 andRow:0]; break;
            case 7: m2 = [self moveWithCol:2 andRow:1]; break;
            case 8: m2 = [self moveWithCol:2 andRow:2]; break;
        }
        id m = [moves objectAtIndex:i];
        STAssertEqualObjects(m, m2, nil);
    }
    
    [ab applyMove:[self moveWithCol:0 andRow:0]];
    [ab applyMove:[self moveWithCol:1 andRow:0]];
    [ab applyMove:[self moveWithCol:0 andRow:1]];
    [ab applyMove:[self moveWithCol:2 andRow:0]];
    [ab applyMove:[self moveWithCol:0 andRow:2]];
    
    STAssertEqualObjects([[ab currentState] description], @"122 100 100", nil);
    STAssertEquals([[ab movesAvailable] count], (unsigned)0, nil);
    
    [ab undoLastMove];
    [ab undoLastMove];
    [ab applyMove:[self moveWithCol:0 andRow:2]]; // player 2
    [ab applyMove:[self moveWithCol:2 andRow:0]];
    [ab applyMove:[self moveWithCol:1 andRow:1]];
    [ab applyMove:[self moveWithCol:2 andRow:1]];

    STAssertEqualObjects([[ab currentState] description], @"121 121 200", nil);
    STAssertEquals([[ab movesAvailable] count], (unsigned)2, nil);

    [ab applyMove:[self moveWithCol:2 andRow:2]];
    [ab applyMove:[self moveWithCol:1 andRow:2]];
    
    STAssertEqualObjects([[ab currentState] description], @"121 121 212", nil);
    STAssertEquals([[ab movesAvailable] count], (unsigned)0, nil);
}

- (void)test05StateAndMoves
{
    STAssertEqualObjects([[ab currentState] description], @"000 000 000", nil);
    unsigned i;
    for (i = 9; i > 2; i--) {
        id moves;
        STAssertNotNil(moves = [ab movesAvailable], nil);
        STAssertEquals([moves count], i, nil);
        id m = [moves objectAtIndex:0];
        id st = [ab applyMove:m];
        
        id s = nil;
        switch (i) {
            case 9: s = @"100 000 000"; break;
            case 8: s = @"100 200 000"; break;
            case 7: s = @"100 200 100"; break;
            case 6: s = @"120 200 100"; break;
            case 5: s = @"120 210 100"; break;
            case 4: s = @"120 210 120"; break;
            case 3: s = @"121 210 120"; break;
        }
        STAssertEqualObjects([st description], s, nil);
    }
    STAssertEquals([ab winner], (unsigned)1, nil);
}

- (void)test06SearchWithPly0
{
    STAssertNil([ab applyMoveFromSearchWithPly:0], nil);
}

- (void)test06SearchWithPly1
{
    STAssertNotNil([ab applyMoveFromSearchWithPly:1], nil);
    STAssertEqualObjects([[ab currentState] description], @"000 010 000", nil);
    STAssertEqualsWithAccuracy([ab currentFitness], (double)-4.0, 0.1, nil);
}

- (NSArray *)states
{
    return [NSArray arrayWithObjects:
        @"100 000 000", @"100 020 000", @"100 120 000",
        @"100 120 200", @"101 120 200", @"121 120 200",
        @"121 120 210", @"121 122 210", @"121 122 211",
        nil];
}

- (void)test06SearchWithPly9
{
    id states = [self states];
    for (unsigned i = 0; i < [states count]; i++) {
        id s = [[ab applyMoveFromSearchWithPly:9] description];
        STAssertEqualObjects(s, [states objectAtIndex:i], nil);
    }
}

- (void)test07SearchWithInterval0
{
    STAssertNil([ab applyMoveFromSearchWithInterval:0.0], nil);
}

/* This tests relies on being able to search to ply 9 in 300 seconds.
   The time should be more than adequate... */
- (void)test07SearchWithInterval300
{
    id states = [self states];
    for (unsigned i = 0; i < [states count]; i++) {
        id s = [[ab applyMoveFromSearchWithInterval:300.0] description];
        STAssertEqualObjects(s, [states objectAtIndex:i], nil);
        STAssertEquals([ab plyReachedForSearch], 9-i, nil);
    }
}

/* This test relies on NOT being able to search to ply 9 in 0.5 second. */
- (void)test08PlyReachedForSearch
{
    for (unsigned i = 9; i > 0; i--) {
        id m1 = [ab moveFromSearchWithInterval:0.5];
        unsigned plyReached = [ab plyReachedForSearch];
        STAssertTrue(plyReached > 0, nil);
        STAssertTrue(plyReached < 9, nil);

        id m2 = [ab moveFromSearchWithPly:plyReached];
        STAssertEqualObjects([m1 description], [m2 description], @"iter: %u", i );

        STAssertNotNil([ab applyMove:m2], nil);
    }
    STAssertEquals([ab countMoves], (unsigned)9, nil);
}

- (void)test09fixedDepthVisitedStates
{

    /* Counts of states doesn't increase much at higher plies because we're getting close to the end of the game. */
    id stateCounts = [NSArray arrayWithObjects: /* minimax numbers in comments */
        @"1:9",     @"2:35",    @"3:166",       /*  9       81      585     */
        @"4:629",   @"5:2776",  @"6:4707",      /*  3609    18729   73449   */
        @"7:16263", @"8:18566", @"9:25597",     /*  221625  422073  549945  */
        @"99:25597",    /* Test that searching past end of game has no effect. */
        nil];

    for (int i = 0; i < [stateCounts count]; i++) {
        id cnt = [[stateCounts objectAtIndex:i] componentsSeparatedByString:@":"];
        STAssertNotNil([ab moveFromSearchWithPly:[[cnt objectAtIndex:0] intValue]], nil);
        STAssertEquals([ab countStatesVisited], (unsigned)[[cnt objectAtIndex:1] intValue], nil);
    }
}

- (void)test09iterativeVisitedStates
{
    STAssertNotNil([ab moveFromSearchWithInterval:0.3], nil);
    unsigned visited = [ab countStatesVisited];
    unsigned ply = [ab plyReachedForSearch];
    STAssertTrue(ply > 1, @"reached more than 1 ply");
    STAssertTrue(ply < 9, @"reached more than 9 ply");
    
    unsigned acc = 0;
    for (int i = 1; i <= ply; i++) {
        [ab moveFromSearchWithPly:i];
        acc += [ab countStatesVisited];
//        NSLog(@"ply/acc: %u %u", i, acc);
    }
    STAssertEquals(visited, acc, @"ply: %u, acc: %u", ply, acc);
}



@end