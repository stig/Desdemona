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

@implementation TTTState

- (id)stateByApplyingMove:(id)m
{
    int row = [[m objectForKey:@"row"] intValue];
    int col = [[m objectForKey:@"col"] intValue];

    if (row > 2 || row < 0 || col > 2 || col < 0) {
        [NSException raise:@"not a valid move" format:@"Invalid move (%d, %d)", row, col];

    } else if (board[col][row]) {
        [NSException raise:@"square busy" format:@"Move already taken (%d, %d)", row, col];
    }
    
    id copy = NSCopyObject(self, 0, [self zone]);
    ((TTTState *)copy)->board[col][row] = player;
    ((TTTState *)copy)->player = 3 - player;

    return copy;
}

@end
