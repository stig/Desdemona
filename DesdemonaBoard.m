#import "Desdemona.h"
#import "DesdemonaBoard.h"
#import <Reversi/ReversiState.h>
#import <Reversi/ReversiMove.h>

@implementation DesdemonaBoard

- (id)initWithFrame:(NSRect)frameRect
{
	if ((self = [super initWithFrame:frameRect]) != nil) {
        controller = nil;
        board = NULL;
    }
	return self;
}

- (void)setBoard
{
    ReversiState *st = [controller state];
    if (st) {
        board = [st board];
        size = [st size];
    }
    else {
        board = NULL;
    }
}

- (void)setController:(id)ctrl
{
    controller = ctrl;
}

- (float)yStep
{
	NSRect r = [self bounds];
	return r.size.height / size;
}

- (float)xStep
{
	NSRect r = [self bounds];
	return r.size.width / size;
}

- (void)drawGrid
{
	NSRect bounds = [self bounds];
	NSBezierPath *path = [[NSBezierPath alloc] init];
	int i;
    
	[[NSColor grayColor] set];
	
	[path setLineWidth: 2.3];
	for (i = 0; i < size; i++) {
		NSPoint p;
		
		p.y = i * [self yStep];
		p.x = 0;
		[path moveToPoint: p];
        
		p.x = bounds.size.width;
		[path lineToPoint: p];
		
		p.y = 0;
		p.x = i * [self xStep];
		[path moveToPoint: p];
		
		p.y = bounds.size.height;
		[path lineToPoint: p];
	}
	[path stroke];
	[path release];
}

- (NSRect)getSquare:(int)x:(int)y
{
	NSRect r;
	r.origin.y = y * [self yStep];
	r.origin.x = x * [self xStep];
	r.size.height = [self yStep];
	r.size.width = [self xStep];	
	return r;
}


- (void)drawDisk:(NSRect)rect:(NSColor*)colour
{
	NSRect bounds = [self bounds];
	
	[colour set];
	rect.origin.y += bounds.size.height / 100.0;
	rect.origin.x += bounds.size.width / 100.0;
	rect.size.height -= bounds.size.height / 50.0;
	rect.size.width -= bounds.size.width / 50.0;
	
	[NSBezierPath fillRect: rect];
}

- (void)drawState
{
	int x, y;
    
	[self drawGrid];
	for (x = 0; x < size; x++) {
		for (y = 0; y < size; y++) {
			int square = board[y][x];
			NSColor *colour;
			
			if (!square) continue;
            
			colour = square == 1 ? [NSColor whiteColor] : [NSColor blackColor];
			[self drawDisk:[self getSquare:x:y]:colour];
		}
	}
}

- (void)mouseDown:(NSEvent *)event
{
	NSPoint p = [self convertPoint:[event locationInWindow] fromView:nil];
	NSRect bounds = [self bounds];
	int x, y;
	
	if (!board) return;
    
	x = p.x / (bounds.size.width / size);
	y = p.y / (bounds.size.height / size);
	//printf("[%f, %f] => [%d, %d]\n", p.x, p.y, x, y);
    
	[controller move:[[ReversiMove alloc] initWithCol:y andRow:x]];
}

- (void)drawRect:(NSRect)rect
{
    [[NSColor blueColor] set];
    [NSBezierPath fillRect:[self bounds]];
    
    [self setBoard];
	if (board) {
		[self drawState];
	}	
}

@end
