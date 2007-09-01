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

#import "TTTState.h"

@implementation TTTBase

- (id)init
{
    if (self = [super init]) {
        for (int i = 0; i < 3; i++) {
            for (int j = 0; j < 3; j++) {
                board[i][j] = 0;
            }
        }
        player = 1;
    }
    return self;
}

- (double)endStateScore
{
    int t1 = 3, t2 = 3;
    for (int i = 0; i < 3; i++) {
        int j, tv = 3, th = 3;
        for (j = 0; j < 3; j++) {
            th &= board[i][j];  /* horizontally? */
            tv &= board[j][i];  /* vertically? */
        }
        
        /* Vertical or Horisontal winning line? */
        if (tv || th)
            return (tv + th) == player ? 1.0 : -1.0;

        t1 &= board[i][i];      /* diagonally (1) */
        t2 &= board[i][2-i];    /* diagonally (2) */
    }
    if (t1 || t2)
        return (t1 + t2) == player ? 1.0 : -1.0;
    
    return 0.0;
}

static double calcFitness(int me, int counts[3])
{
    int you = 3 - me;
    double score = 0.0;
    if (counts[me] && !counts[you]) {
        score += counts[me] * counts[me];
    }
    else if (!counts[me] && counts[you]) {
        score -= counts[you] * counts[you];
    }
    return abs(score) == 9 ? score * 100 : score;
}


- (double)currentFitness
{
    int i, j, me;
    double score = 0.0;
    int countd1[3] = {0};
    int countd2[3] = {0};

    me = player;
    for (i = 0; i < 3; i++) {
        int counth[3] = {0};
        int countv[3] = {0};
        for (j = 0; j < 3; j++) {
            counth[board[i][j]]++;
            countv[board[j][i]]++;
        }
        countd1[board[i][i]]++;
        countd2[board[i][2-i]]++;
        score += calcFitness(me, counth);
        score += calcFitness(me, countv);
    }
    score += calcFitness(me, countd1);
    score += calcFitness(me, countd2);
    return score;
}

- (NSArray *)movesAvailable
{
    NSMutableArray *moves = [NSMutableArray array];
    if (abs([self currentFitness]) > 100) {
        return moves;
    }
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            if (!board[i][j]) {
                [moves addObject:[NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithInt: i], @"col",
                    [NSNumber numberWithInt: j], @"row",
                    nil]];
            }
        }
    }
    return moves;
}

- (NSString *)description
{
    NSMutableString *s = [NSMutableString string];
    for (int i = 0; i < 3; i++) {
        for (int j = 0; j < 3; j++) {
            [s appendFormat:@"%d", board[j][i]];
        }
        if (i < 2) {
            [s appendFormat:@" "];
        }
    }
    return s;
}

@end
