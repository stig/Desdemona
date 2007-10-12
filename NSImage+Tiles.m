/*
Copyright (C) 2007 Stig Brautaset. All rights reserved.

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

#import "NSImage+Tiles.h"

@implementation NSImage (NSImage_Tiles)

- (NSArray *)tilesWithSize:(NSSize)tilesize forRows:(unsigned)rows columns:(unsigned)columns
{
    id tiles = [NSMutableArray array];
    unsigned count = rows * columns;
    NSSize imgsize = [self size];
    
    for (unsigned i = 0; i < count; i++) {
        id tile = [[NSImage alloc] initWithSize:tilesize];

        /* fugly, but the simplest way of determining the source rectancle */
        NSRect src = NSMakeRect(imgsize.width / columns * (i % columns),
                                imgsize.height - (imgsize.height / rows) * (1 + i / columns),
                                imgsize.width / columns,
                                imgsize.height / rows);

        [tile lockFocus];
        [self drawInRect:NSMakeRect(0, 0, tilesize.width, tilesize.height)
                fromRect:src
               operation:NSCompositeCopy
                fraction:1.0];
        [tile unlockFocus];

        [tiles addObject:[tile autorelease]];
    }
    
    return tiles;
}

@end
