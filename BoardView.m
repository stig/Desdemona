/*
 Copyright (C) 2006,2007 Stig Brautaset. All rights reserved.
 
 This file is part of Desdemona.
 
 Desdemona is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 Desdemona is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Desdemona; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 
 */
#import "BoardView.h"
#import "Desdemona.h"
#import "NSImage+Tiles.h"

@implementation BoardView

- (void)setTheme:(id)this
{
    id sq = [this tilesWithSize:NSMakeSize(100, 100) forRows:4 columns:8];
    [disks release];
    disks = [sq retain];
}

- (void)drawState
{
    int r, c;
    for (r = 0; r < rows; r++) {
        for (c = 0; c < cols; c++) {
            int square = [[[state objectAtIndex:r] objectAtIndex:c] intValue];
            square = square == 1 
                ? 1 : square == 2
                    ? 31 : 0;

            NSImageCell *ic = [self cellAtRow:r column:c];
            [ic setImage:[disks objectAtIndex:square]];
            [ic setImageFrameStyle:NSImageFrameNone];
            [self drawCell:ic];
        }
    }
    [self setNeedsDisplay:YES];
}

- (void)setBoard:(id)this
{
    if (state != this) {
        [state release];
        state = [this retain];
        
        rows = [this count];
        cols = [[this lastObject] count];
        
        int r, c;
        [self getNumberOfRows:&r columns:&c];
        if (r != rows || c != cols) {
            [self renewRows:rows columns:cols];
            
            /* such.. a.. hack... - make the matrix resize, as this is
               the only way I've found to get the cells to resize. */
            NSSize s = [self frame].size;
            [self setFrameSize:NSMakeSize(100,100)];
            [self setFrameSize:s];
        }
    }
    [self drawState];
}

- (void)mouseDown:(NSEvent *)event
{
    if ([self delegate]) {
        NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
        int r, c;
        [self getRow:&r column:&c forPoint:p];
        [[self delegate] clickAtRow:r col:c];

    } else {
        NSLog(@"No delegate set.");
    
    }
}

@end
