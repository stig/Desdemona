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

#import "SBReversiState.h"

typedef struct {
    unsigned c[3];
} SBReversiStateCount;

#define opponent(x) (3 - player)

@implementation SBReversiState


- (id)init
{
    return [self initWithBoardSize:8];
}

- (id)initWithBoardSize:(int)theSize
{

    if (theSize > MAXSIZE)
        [NSException raise:@"size-too-large"
                    format:@"Size (%d) is larger than maximum (%d)", theSize, MAXSIZE];

    if (self = [super init]) {
        size = theSize;
        player = 1;

        for (int i = 0; i < size; i++) {
            for (int j = 0; j < size; j++) {
                board[i][j] = 0;
            }
        }
        board[size/2-1][size/2] = player;
        board[size/2][size/2-1] = player;
        board[size/2-1][size/2-1] = opponent(player);
        board[size/2][size/2] = opponent(player);
    }
    return self;
}

- (id)initWithBoardSize:(int)sz andPlayer:(int)p
{
    self = [self initWithBoardSize:sz];
    player = p;
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return NSCopyObject(self, 0, zone);
}

- (int)boardSize
{
    return size;
}

- (SBReversiStateCount)countSquares
{
    SBReversiStateCount count = {{0}};
    for (unsigned i = 0; i < size; i++) {
        for (unsigned j = 0; j < size; j++) {
            count.c[ board[i][j] ]++;
        }
    }
    return count;
}

- (unsigned)playerCount
{
    SBReversiStateCount count = [self countSquares];
    return count.c[player];
}

- (unsigned)opponentCount
{
    SBReversiStateCount count = [self countSquares];
    return count.c[opponent(player)];
}

- (BOOL)isDraw
{
    return [self playerCount] == [self opponentCount];
}

- (BOOL)isWin
{
    return [self playerCount] > [self opponentCount];
}

- (double)fitness
{
    NSArray *moves;
    int mine, diff, me, you;
    SBReversiStateCount counts;

    me = player;
    you = opponent(me);

    moves = [self legalMoves];
    if (!moves) {
        [NSException raise:@"unexpected" format:@"Unexpected return"];
    }
    else if (![moves count]) {
        counts = [self countSquares];
        mine = counts.c[me] - counts.c[you];
        return (float)(mine > 0 ? +100000.0 :
                       mine < 0 ? -100000.0 : 0);
    }

    mine = [moves count];

    player = opponent(player);
    moves = [self legalMoves];
    player = opponent(player);

    diff = mine - [moves count];

    counts = [self countSquares];
    mine = counts.c[me] - counts.c[you];

    return (float)(diff + mine);
}

// This code is adapted from code that existed in Gnome Iagno
// once upon a time. It was written by Ian Peters <itp@gnu.org>.
- (BOOL)validMove:(int)me col:(int)x row:(int)y
{
    int tx, ty;
    int opponent = opponent(me);

    /* slot must not already be occupied */
    if (board[x][y] != 0)
        return NO;

    /* left */
    for (tx = x - 1; tx >= 0 && board[tx][y] == opponent; tx--)
        ;
    if (tx >= 0 && tx != x - 1 && board[tx][y] == me)
        return YES;

    /* right */
    for (tx = x + 1; tx < size && board[tx][y] == opponent; tx++)
        ;
    if (tx < size && tx != x + 1 && board[tx][y] == me)
        return YES;

    /* up */
    for (ty = y - 1; ty >= 0 && board[x][ty] == opponent; ty--)
        ;
    if (ty >= 0 && ty != y - 1 && board[x][ty] == me)
        return YES;

    /* down */
    for (ty = y + 1; ty < size && board[x][ty] == opponent; ty++)
        ;
    if (ty < size && ty != y + 1 && board[x][ty] == me)
        return YES;

    /* up/left */
    tx = x - 1;
    ty = y - 1;
    while (tx >= 0 && ty >= 0 && board[tx][ty] == opponent) {
        tx--;
        ty--;
    }
    if (tx >= 0 && ty >= 0 && tx != x - 1 && ty != y - 1 && board[tx][ty] == me)
        return YES;

    /* up/right */
    tx = x - 1;
    ty = y + 1;
    while (tx >= 0 && ty < size && board[tx][ty] == opponent) {
        tx--;
        ty++;
    }
    if (tx >= 0 && ty < size && tx != x - 1 && ty != y + 1 && board[tx][ty] == me)
        return YES;

    /* down/right */
    tx = x + 1;
    ty = y + 1;
    while (tx < size && ty < size && board[tx][ty] == opponent) {
        tx++;
        ty++;
    }
    if (tx < size && ty < size && tx != x + 1 && ty != y + 1 && board[tx][ty] == me)
        return YES;

    /* down/left */
    tx = x + 1;
    ty = y - 1;
    while (tx < size && ty >= 0 && board[tx][ty] == opponent) {
        tx++;
        ty--;
    }
    if (tx < size && ty >= 0 && tx != x + 1 && ty != y - 1 && board[tx][ty] == me)
        return YES;

    return NO;
}

- (NSArray *)legalMoves
{
    NSMutableArray *moves = [NSMutableArray array];
    int me, i, j;

    me = player;
again:
    for (i = 0; i < size; i++) {
        for (j = 0; j < size; j++) {
            id m = [self moveForCol:i andRow:j];
            if (m != nil) {
                [moves addObject:m];
            }
        }
    }

    if (![moves count]) {
        if (me == player) {
            player = opponent(player);
            goto again;
        }
    }
    else if (me != player) {
        [moves removeAllObjects];
        [moves addObject:[NSNull null]];
    }

    player = me;
    return moves;
}



- (NSNumber *)moveWithCol:(int)c andRow:(int)r
{
    return [NSNumber numberWithInt: r * [self boardSize] + c];
}

// This code is adapted from code that existed in Gnome Iagno
// once upon a time. It was written by Ian Peters <itp@gnu.org>.

- (id)moveForCol:(int)x andRow:(int)y
{
    int me = player;
    int opponent = opponent(me);
    int tx, ty;

    if (x == -1 && y == -1) {
        /* pass move */
        return [NSArray arrayWithObject:[NSNull null]];
    }
    else if (x < 0 || x > (size-1) || y < 0 || y > (size-1)) {
        return nil;
        [NSException raise:@"illegal move" format:@"Illegal move"];
    }
    else if (board[x][y] != 0) {
         return nil;
        [NSException raise:@"square busy" format:@"Square busy"];
    }

    /* A "move" is an array of coordinates;
       the first is the actual move, the subsequent is all flipped pieces */
    NSMutableArray *arr = [NSMutableArray arrayWithObject:[self moveWithCol:x andRow:y]];

    /* left */
    for (tx = x - 1; tx >= 0 && board[tx][y] == opponent; tx--)
        ;
    if (tx >= 0 && tx != x - 1 && board[tx][y] == me) {
        tx = x - 1;
        while (tx >= 0 && board[tx][y] == opponent) {
            [arr addObject:[self moveWithCol:tx andRow:y]];
            tx--;
        }
    }

    /* right */
    for (tx = x + 1; tx < size && board[tx][y] == opponent; tx++)
        ;
    if (tx < size && tx != x + 1 && board[tx][y] == me) {
        tx = x + 1;
        while (tx < size && board[tx][y] == opponent) {
            [arr addObject:[self moveWithCol:tx andRow:y]];
            tx++;
        }
    }

    /* up */
    for (ty = y - 1; ty >= 0 && board[x][ty] == opponent; ty--)
        ;
    if (ty >= 0 && ty != y - 1 && board[x][ty] == me) {
        ty = y - 1;
        while (ty >= 0 && board[x][ty] == opponent) {
            [arr addObject:[self moveWithCol:x andRow:ty]];
            ty--;
        }
    }

    /* down */
    for (ty = y + 1; ty < size && board[x][ty] == opponent; ty++)
        ;
    if (ty < size && ty != y + 1 && board[x][ty] == me) {
        ty = y + 1;
        while (ty < size && board[x][ty] == opponent) {
            [arr addObject:[self moveWithCol:x andRow:ty]];
            ty++;
        }
    }

    /* up/left */
    tx = x - 1;
    ty = y - 1;
    while (tx >= 0 && ty >= 0 && board[tx][ty] == opponent) {
        tx--;
        ty--;
    }
    if (tx >= 0 && ty >= 0 && tx != x - 1 && ty != y - 1 && board[tx][ty] == me) {
        tx = x - 1;
        ty = y - 1;
        while (tx >= 0 && ty >= 0 && board[tx][ty] == opponent) {
            [arr addObject:[self moveWithCol:tx andRow:ty]];
            tx--;
            ty--;
        }
    }

    /* up/right */
    tx = x - 1;
    ty = y + 1;
    while (tx >= 0 && ty < size && board[tx][ty] == opponent) {
        tx--;
        ty++;
    }
    if (tx >= 0 && ty < size && tx != x - 1 && ty != y + 1 && board[tx][ty] == me) {
        tx = x - 1;
        ty = y + 1;
        while (tx >= 0 && ty < size && board[tx][ty] == opponent) {
            [arr addObject:[self moveWithCol:tx andRow:ty]];
            tx--;
            ty++;
        }
    }

    /* down/right */
    tx = x + 1;
    ty = y + 1;
    while (tx < size && ty < size && board[tx][ty] == opponent) {
        tx++;
        ty++;
    }
    if (tx < size && ty < size && tx != x + 1 && ty != y + 1 && board[tx][ty] == me) {
        tx = x + 1;
        ty = y + 1;
        while (tx < size && ty < size && board[tx][ty] == opponent) {
            [arr addObject:[self moveWithCol:tx andRow:ty]];
            tx++;
            ty++;
        }
    }

    /* down/left */
    tx = x + 1;
    ty = y - 1;
    while (tx < size && ty >= 0 && board[tx][ty] == opponent) {
        tx++;
        ty--;
    }
    if (tx < size && ty >= 0 && tx != x + 1 && ty != y - 1 && board[tx][ty] == me) {
        tx = x + 1;
        ty = y - 1;
        while (tx < size && ty >= 0 && board[tx][ty] == opponent) {
            [arr addObject:[self moveWithCol:tx andRow:ty]];
            tx++;
            ty--;
        }
    }

    if ([arr count] < 2) {
        /* didn't flip any pieces; not a valid move */
        return nil;
    }
    return arr;
}

- (NSString *)description
{
    NSMutableString *s = [NSMutableString stringWithFormat: @"%d: ", player];
    int i, j;
    for (i = 0; i < size; i++) {
        for (j = 0; j < size; j++) {
            [s appendFormat:@"%d", board[j][i]];
        }
        if (i < size - 1) {
            [s appendFormat:@" "];
        }
    }
    return s;
}

- (BOOL)isPassMove:(id)move
{
    if ([move isKindOfClass:[NSNull class]])
        return YES;
        
    /* trying to get rid of this case ... */
    if ([move isKindOfClass:[NSArray class]] && [move count] == 1 && [[move lastObject] isKindOfClass:[NSNull class]])
        return YES;
    return NO;
}

- (void)validateMove:(id)move
{
    if (![move isKindOfClass:[NSArray class]]) {
        [NSException raise:@"broken move" format:@"not an array"];

    } else if ([move count] < 2) {
        [NSException raise:@"broken move" format:@"not flipping pieces?"];
    }
}

-(void)applyMove:(id)move
{
    if (![self isPassMove:move]) {
        [self validateMove:move];
        NSEnumerator *e = [move objectEnumerator];
        id m;
        while (m = [e nextObject]) {
            int row = [m intValue] / size;
            int col = [m intValue] % size;
            board[ col ][ row ] = player;
        }
    }
    player = opponent(player);
}

- (int)pieceAtRow:(int)r col:(int)c
{
    return board[r][c];
}


@end
