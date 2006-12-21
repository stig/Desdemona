/*
 Copyright (C) 2006 Stig Brautaset. All rights reserved.
 
 This file is part of CocoaGames.
 
 CocoaGames is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.
 
 CocoaGames is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with CocoaGames; if not, write to the Free Software
 Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 
 */
#import "BoardView.h"

@implementation BoardView

- (void)dealloc
{
    [controller release];
    [super dealloc];
}

- (void)setController:(id)this
{
    if (controller != this) {
        [controller release];
        controller = [this retain];
    }
}

- (void)setTheme:(id)this
{
    id sq = [NSMutableArray array];
    
    /* create array of images for animation of square flippings */
    NSSize imgsize = [this size];
    for (int i = 0; i < 32; i++) {
        id img = [[NSImage alloc] initWithSize:NSMakeSize(100, 100)];
        
        /* fugly, but the simplest way of determining the source rectancle */
        NSRect src = NSMakeRect(imgsize.width / 8.0 * (i % 8),
                                imgsize.height - (imgsize.height / 4.0) * (1 + i / 8),
                                imgsize.width / 8.0,
                                imgsize.height / 4.0);
        
        [img lockFocus];
        [this drawInRect:NSMakeRect(0, 0, 100, 100)
                fromRect:src
               operation:NSCompositeCopy
                fraction:1.0];
        [img unlockFocus];
        [sq addObject:[img autorelease]];
    }
    
    [disks release];
    disks = [sq copy];
}

- (void)drawState
{
    int r, c;
    for (r = 0; r < rows; r++) {
        for (c = 0; c < cols; c++) {
            int square = [[[state objectAtIndex:r] objectAtIndex:c] intValue];
            square = square == 1 ? 31 : square == 2 ? 1  : 0;

            NSImageCell *ic = [self cellAtRow:r column:c];
            [ic setImage:[disks objectAtIndex:square]];
            [ic setImageFrameStyle:NSImageFrameNone];
            [self drawCell:ic];
        }
    }
    [self setNeedsDisplay:YES];
}

- (void)setState:(id)this
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
    if (!controller)
        return;
    NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
    int r, c;
    [self getRow:&r column:&c forPoint:p];
    [controller clickAtRow:r col:c];
}

@end
