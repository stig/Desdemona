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

@implementation BoardView

- (void)setTheme:(id)this
{
    if (tiles != this) {
        [tiles release];
        tiles = [this retain];
    }
}

- (void)drawState
{
    int rows, cols;
    [self getNumberOfRows:&rows columns:&cols];

    unsigned up = 0;
    for (unsigned r = 0; r < rows; r++) {
        for (unsigned c = 0; c < cols; c++) {
            if (current[r][c] != target[r][c]) {
                up++;

                if (!current[r][c])
                    current[r][c] = target[r][c];

                else if (current[r][c] > target[r][c])
                    current[r][c]--;

                else
                    current[r][c]++;

            }
        }
    }

    for (unsigned r = 0; r < rows; r++) {
        for (unsigned c = 0; c < cols; c++) {
            NSImageCell *ic = [self cellAtRow:r column:c];
            [ic setImage:[tiles objectAtIndex:current[r][c]]];
            [ic setImageFrameStyle:NSImageFrameNone];
            [self drawCell:ic];
        }
    }
	
	if (up)
		[self drawState];
}

- (void)setBoard:(id)this
{ 
    // translate from player number to tile number
    for (unsigned r = 0; r < [this count]; r++) {
        NSArray *row = [this objectAtIndex:r];
        for (unsigned c = 0; c < [row count]; c++) {
            int player = [[row objectAtIndex:c] intValue];
            target[r][c] = !player ? 0 : player == 1 ? 1 : 31;
        }
    }

    // Resize the matrix if we have different dimensions from before.
    int r, c;
    [self getNumberOfRows:&r columns:&c];
    if (r != [this count] || c != [[this lastObject] count]) {
        [self renewRows:[this count] columns:[[this lastObject] count]];
        
        /* such.. a.. hack... - make the matrix resize, as this is
           the only way I've found to get the cells to resize. */
        NSSize s = [self frame].size;
        [self setFrameSize:NSMakeSize(100,100)];
        [self setFrameSize:s];
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
