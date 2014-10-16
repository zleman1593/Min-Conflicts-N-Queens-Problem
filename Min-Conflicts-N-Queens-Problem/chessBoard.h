//
//  sudoku.h
//  Leman_Sudoku!
//
// // This view draws the  initial chess board  and refreshes it when
//  the computer solution is shown.

#import <UIKit/UIKit.h>
#define BOARD_HEIGHT 9
#define BOARD_WIDTH 18
#define NUMBERS_WIDTH 9
#define CELLSIZE 80
#define NUMBER_CELLSIZE 80
#define  FIELDINSET_Y 780
#define FIELDINSET 2
#define NO_POSSIBLE_SOLUTION_FROM_POINT 90
#define NO_MORE_SPOTS 60
#define INPUT_SIZE 50
#define DUMMY 0
#define FONT_SIZE 48.0

@class chessBoard;

@protocol chessBoardDelegate
-(NSString*)getContentAtRow:(int)row Col:(int)col;
@end

@interface chessBoard : UIView
@property (nonatomic) id <chessBoardDelegate> delegate;
- (void)tap:(UITapGestureRecognizer *)gesture;
@end
