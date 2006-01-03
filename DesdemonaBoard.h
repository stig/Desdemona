/* DesdemonaBoard */

#import <Cocoa/Cocoa.h>

#define WHITE 1
#define BLACK 2

@class Desdemona;

@interface DesdemonaBoard : NSView
{
    Desdemona *controller;
    int size;
    int **board;
}

- (void)setController:(id)controller;
- (void)setBoard;
@end
