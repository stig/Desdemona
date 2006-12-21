/*
Copyright (C) 2006 Stig Brautaset. All rights reserved.

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

#import <Cocoa/Cocoa.h>
#import <SBReversi/SBReversiState.h>
#import <SBReversi/SBReversiMove.h>

#import "ABController.h"

@interface Desdemona : ABController
{    
    IBOutlet NSStepper *sizeStepper;
    
    IBOutlet NSTextField *size;
    IBOutlet NSTextField *black;
    IBOutlet NSTextField *white;
}
- (IBAction)changeSize:(id)sender;

- (void)passAlert;
- (BOOL)mustPass;

@end
