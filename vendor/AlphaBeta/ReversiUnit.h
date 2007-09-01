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

#import <SenTestingKit/SenTestingKit.h>
#import <AlphaBeta/AlphaBeta.h>
#import <SBReversi/SBReversiState.h>

@interface Reversi8x8Unit : SenTestCase {
    SBAlphaBeta *ab;
}
@end

@interface Reversi6x6Unit : SenTestCase {
    SBAlphaBeta *ab;
}
@end

@interface Reversi4x4Unit : SenTestCase {
    SBAlphaBeta *ab;
}
@end


@interface MutableReversi8x8Unit : Reversi8x8Unit
@end

@interface MutableReversi6x6Unit : Reversi6x6Unit
@end

@interface MutableReversi4x4Unit : Reversi4x4Unit
@end
