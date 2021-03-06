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


@implementation MutableReversi8x8Unit

- (void)setUp
{
    id state = [[SBMutableReversiState alloc] initWithBoardSize:8];
    ab = [SBAlphaBeta newWithState:state];
}

@end


@implementation Reversi8x8Unit

- (void)setUp
{
    ab = [SBAlphaBeta newWithState:[SBReversiState new]];
}

- (void)tearDown
{
    [ab release];
}

- (void)test01LegalMoves
{
    id st = [ab currentState];
    STAssertEquals([st playerCount], (unsigned)2, nil);
    STAssertEquals([st opponentCount], (unsigned)2, nil);

    id moves;
    STAssertNotNil(moves = [st legalMoves], nil);
    STAssertEquals([moves count], (unsigned)4, nil);
    int i;
    for (i = 0; i < 4; i++) {
        id m2;
        switch (i) {
            case 0: m2 = [st moveWithCol:2 andRow:3]; break;
            case 1: m2 = [st moveWithCol:3 andRow:2]; break;
            case 2: m2 = [st moveWithCol:4 andRow:5]; break;
            case 3: m2 = [st moveWithCol:5 andRow:4]; break;
        }
        STAssertEqualObjects([[moves objectAtIndex:i] objectAtIndex:0], m2, nil);
    }
}

- (void)test02IllegalMoveThrows
{
    STAssertEquals([ab currentPlayer], (unsigned)1, nil);
    id st = [ab currentState];
    
    STAssertThrows([ab performMove:[st moveForCol:0 andRow:0]], nil);
    STAssertEquals([ab currentPlayer], (unsigned)1, nil);
    STAssertEquals([ab countPerformedMoves], (unsigned)0, nil);

    STAssertThrows([ab performMove:[st moveForCol:0 andRow:-10]], nil);
    STAssertEquals([ab currentPlayer], (unsigned)1, nil);
    STAssertEquals([ab countPerformedMoves], (unsigned)0, nil);
    
    STAssertThrows([ab performMove:[st moveForCol:3 andRow:4]], nil);
    STAssertEquals([ab currentPlayer], (unsigned)1, nil);
    STAssertEquals([ab countPerformedMoves], (unsigned)0, nil);
}

- (void)test03currentPlayer
{
    STAssertEquals([ab currentPlayer], (unsigned)1, nil);

    [ab performMoveFromSearchWithDepth:1];
    STAssertEquals([ab currentPlayer], (unsigned)2, nil);

    [ab undoLastMove];
    STAssertEquals([ab currentPlayer], (unsigned)1, nil);
}

- (void)test04StateAndFitness
{
    STAssertTrue([ab currentPlayer] == 1, nil);
    STAssertTrue([ab currentFitness] == 0.0, @"got: %f", [ab currentFitness]);

    id st = [ab currentState];
    STAssertEquals([st playerCount], (unsigned)2, nil);
    STAssertEquals([st opponentCount], (unsigned)2, nil);

    STAssertEqualObjects([st description], @"1: 00000000 00000000 00000000 00021000 00012000 00000000 00000000 00000000", nil);

    st = [ab performMove:[st moveForCol:3 andRow:2]];
    STAssertEqualsWithAccuracy([ab currentFitness], (double)-3.0, 0.0001, @"got %f", [st currentFitness]);
    STAssertEqualObjects([st description], @"2: 00000000 00000000 00010000 00011000 00012000 00000000 00000000 00000000", nil);

    st = [ab performMove:[st moveForCol:4 andRow:2]];
    STAssertEqualsWithAccuracy([ab currentFitness], (double)0.0, 0.0001, @"got %f", [st currentFitness]);
    STAssertEqualObjects([st description], @"1: 00000000 00000000 00012000 00012000 00012000 00000000 00000000 00000000", nil);

    st = [ab performMove:[st moveForCol:5 andRow:5]];
    STAssertEqualsWithAccuracy([ab currentFitness], (double)-2.0, 0.0001, @"got %f", [st currentFitness]);
    STAssertEqualObjects([st description], @"2: 00000000 00000000 00012000 00012000 00011000 00000100 00000000 00000000", nil);
}

- (void)test05IterativeTimeKeeping
{
    id times = [@"0.05 0.1 0.2 0.5 1.0 2.0" componentsSeparatedByString:@" "];
    for (unsigned i = 0; i < [times count]; i++) {
        double interval = [[times objectAtIndex:i] doubleValue];

        NSDate *start = [NSDate date];
        [ab moveFromSearchWithInterval:interval];
        double duration = -[start timeIntervalSinceNow];

        /* _Must_ finish in less time than the interval */
        STAssertTrue( duration < interval, @"%f <= %f", duration, interval);

        /* We should really tolerate finishing up to 3% early... */
        double accuracy = interval * 0.97;
        STAssertTrue( duration > accuracy, @"%f <= %f", duration, accuracy);
    }
}

- (void)test06iterativeSearchAlwaysReachesPly1
{
    STAssertNotNil([ab moveFromSearchWithInterval:0.0], nil);
    STAssertEquals([ab stateCountForSearch], (unsigned)4, nil);
    STAssertEquals([ab depthForSearch], (unsigned)1, nil);
}

@end
