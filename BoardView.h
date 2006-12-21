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
#import <Cocoa/Cocoa.h>

#import "ABController.h"

@interface BoardView : NSMatrix
{
    NSArray *disks;
    ABController *controller;
    NSArray *state;
    int rows, cols;
}

- (void)setController:(id)ctrl;
- (void)setState:(id)this;

@end
