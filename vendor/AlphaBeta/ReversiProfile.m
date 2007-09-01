#include <Cocoa/Cocoa.h>
#include <AlphaBeta/AlphaBeta.h>
#include <SBReversi/SBReversiState.h>

int main(int argc, char **argv)
{
    NSAutoreleasePool *pool = [NSAutoreleasePool new];
    NSMutableDictionary *opts = [NSMutableDictionary dictionaryWithObjectsAndKeys:
        @"0",           @"--mutable",
        @"1",           @"--count",
        @"0",           @"--skip",
        @"5",           @"--ply",
        [NSNull null],  @"--time",
        nil];

    if (argc < 3 || !(argc % 2)) {
        fprintf(stderr, "Usage: %s [--opt value]\n", argv[0]);
        return EXIT_FAILURE;
    }
    for (int i = 1; i < argc; i += 2)
        [opts setObject:[NSString stringWithCString:argv[i+1]]
                 forKey:[NSString stringWithCString:argv[i]]];

    Class class = [[opts objectForKey:@"--mutable"] intValue]
        ? [SBMutableReversiState class]
        : [SBReversiState class];
    SBAlphaBeta *ab = [SBAlphaBeta newWithState:[class new]];

    int skip = [[opts objectForKey:@"--skip"] intValue];
    for (int i = 0; i < skip; i++)
        [ab applyMove:[[ab movesAvailable] objectAtIndex:0]];

    int fixed = [[opts objectForKey:@"--time"] isKindOfClass:[NSNull class]];
    int ply = [[opts objectForKey:@"--ply"] intValue];
    for (int i = 0; i < [[opts objectForKey:@"--count"] intValue]; i++) {
        NSDate *date = [NSDate date];
        if (fixed)
            [ab moveFromSearchWithPly:ply];
        else
            [ab moveFromSearchWithInterval:[[opts objectForKey:@"--time"] doubleValue]];

        printf("%u %lf %u %u (visited/time/ply/skip)\n",
            [ab countStatesVisited],
            (double)-[date timeIntervalSinceNow],
            fixed ? ply : [ab plyReachedForSearch],
            skip
        );
    }
    
    [pool release];
    return 0;
}
