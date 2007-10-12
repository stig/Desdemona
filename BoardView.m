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
    [tiles release];
    tiles = [sq retain];
}

- (void)drawState
{
    for (unsigned r = 0; r < [target count]; r++) {
        NSArray *row = [target objectAtIndex:r];
        for (unsigned c = 0; c < [row count]; c++) {
            int square = [[row objectAtIndex:c] intValue];
            NSImageCell *ic = [self cellAtRow:r column:c];
            [ic setImage:[tiles objectAtIndex:square]];
            [ic setImageFrameStyle:NSImageFrameNone];
            [self drawCell:ic];
        }
    }
//    [self setNeedsDisplay:YES];
}

- (void)setBoard:(id)this
{ 
    // translate from player number to tile number
    NSMutableArray *board = [NSMutableArray new];
    for (unsigned r = 0; r < [this count]; r++) {
        NSArray *row = [this objectAtIndex:r];
        NSMutableArray *newRow = [NSMutableArray array];
        for (unsigned c = 0; c < [row count]; c++) {
            int player = [[row objectAtIndex:c] intValue];
            int tile = !player ? 0 : player == 1 ? 1 : 31;
            [newRow addObject:[NSNumber numberWithInt:tile]];
        }
        [board addObject:newRow];
    }

    [target release];
    target = board;

    // Resize the matrix if we have different dimensions from before.
    int r, c;
    unsigned rows = [this count];
    unsigned cols = [[this lastObject] count];
    [self getNumberOfRows:&r columns:&c];
    if (r != rows || c != cols) {
        [self renewRows:rows columns:cols];
        
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
