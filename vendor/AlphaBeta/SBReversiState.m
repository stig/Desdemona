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

#import "SBReversiState.h"

@implementation SBReversiState

-(id)stateByApplyingMove:(id)move
{
    SBReversiState *copy = (SBReversiState*)NSCopyObject(self, 0, [self zone]);

    if (![self isPassMove:move]) {
        [self validateMove:move];
        NSEnumerator *e = [move objectEnumerator];
        for (id m; m = [e nextObject];) {
            int row = [[m objectForKey:@"row"] intValue];
            int col = [[m objectForKey:@"col"] intValue];
            copy->board[ col ][ row ] = player;
        }
    }

    copy->player = 3 - player;

    return [copy autorelease];
}


@end
