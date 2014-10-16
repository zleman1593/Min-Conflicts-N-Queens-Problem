// // This view draws the  initial chess board  and refreshes it when
//  the computer solution is shown.

#import "chessBoard.h"

@interface chessBoard ()
//Assigns a color to a given square containg a number
-(void)colorPickerWithContext:(CGContextRef)context;
@end
@implementation chessBoard

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
//Darws the board and where there are Queens
- (void)drawRect:(CGRect)rect{
    for (int i = 0; i < BOARD_WIDTH; i++) {
        for (int j = 1; j <= BOARD_HEIGHT; j++) {
            int x = FIELDINSET + i * CELLSIZE;
            int y = FIELDINSET + (j-1) * CELLSIZE;
            CGRect rectangle = CGRectMake(x,y,CELLSIZE,CELLSIZE);
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextBeginPath(context);
            CGContextStrokePath(context);
            CGContextStrokeRect(context, rectangle);
            //Asks for queen or a blank to place in each square
            NSString *queen = [NSString stringWithFormat:@"%d", [[self.delegate getContentAtRow:j Col:i ]intValue]];
            UIFont *textFont = [UIFont systemFontOfSize:FONT_SIZE];
            //Determines if a queen is at a give location and colors the location appropriately
            [self colorPickerWithContext:context];
            NSLog(@"i: %i j: %i", i, j);
            if ([[self.delegate getContentAtRow:j Col:i ] isEqual:@"Q"]) {
                CGContextFillRect(context, rectangle);
                [queen drawInRect:rectangle withAttributes:@{NSFontAttributeName:textFont}];
            }
        }
    }
}
/*This registers that the user has tapped in a specific location and allows a queen to be placed there*/
- (void)tap:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        CGPoint tapPoint = [gesture locationInView:self];
        NSLog(@"digit pressed is X:%f and Y: %f", tapPoint.x, tapPoint.y);
        BOOL done=NO;
        for (int i = 0; i < BOARD_WIDTH && done==NO; i++) {
            for (int j = 0; j < BOARD_HEIGHT && done==NO; j++) {
                int x = FIELDINSET + i * CELLSIZE;
                int y = FIELDINSET + j * CELLSIZE;
                CGRect rectangle = CGRectMake(x,y,CELLSIZE,CELLSIZE);
                //If a square contains the point the user tapped it will
                //place a queen there
                if (CGRectContainsPoint(rectangle,tapPoint)) {
                    NSLog(@"Point(%f, %f) is contained in rectangle %d,%d ", tapPoint.x, tapPoint.y,x,y);
                    done=YES;
                    break;
                }
            }
        }
        //If a square contains the point the user tapped it will
        //update the most recently slected number to that value
        int numbers=0;
        for (int i = 0; i < NUMBERS_WIDTH && done==NO; i++) {
            numbers++;
            int x = FIELDINSET + i * CELLSIZE;
            CGRect rectangle = CGRectMake(x,FIELDINSET_Y,CELLSIZE,CELLSIZE);
            if (CGRectContainsPoint(rectangle,tapPoint)) {
                done=YES;
                NSLog(@"Point(%f, %f) is contained in rectangle %d,0 ", tapPoint.x, tapPoint.y,x);
            }
        }
        
    }
}
/*Is given the current context and the number at a*
 location and sets that location to the correct color*/
-(void)colorPickerWithContext:(CGContextRef)context{
    int random = arc4random_uniform(BOARD_HEIGHT+1);
    switch (random) {
        case 1:
            CGContextSetRGBFillColor(context,0.6,0.6, 0.0, 1.0);
            break;
        case 2:
            CGContextSetRGBFillColor(context,1.0,0.0, 0.0, 1.0);
            break;
        case 3:
            CGContextSetRGBFillColor(context,0.0,1.0, 0.0, 1.0);
            break;
        case 4:
            CGContextSetRGBFillColor(context,0.0,0.0, 1.0, 1.0);
            break;
        case 5:
            CGContextSetRGBFillColor(context,0.8,0.4, 1.0, 1.0);
            break;
        case 6:
            CGContextSetRGBFillColor(context,1.0,0.8, 0.0, 1.0);
            break;
        case 7:
            CGContextSetRGBFillColor(context,0.2,0.0, 0.8, 1.0);
            break;
        case 8:
            CGContextSetRGBFillColor(context,0.3,.3, 0.3, 1.0);
            break;
        case 9:
            CGContextSetRGBFillColor(context,0.4,0.0, 0.8, 1.0);
            break;
        default:
            break;
    }
}

@end
