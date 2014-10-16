//
//  Board.swift
//  Min-Conflicts-N-Queens-Problem
//
//  Created by Ruben on 10/16/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import Foundation
import UIKit

class Board : UIView {
    let BOARD_HEIGHT = 9
    let BOARD_WIDTH  = 18
    let NUMBERS_WIDTH = 9
    let CELLSIZE = 80
    let NUMBER_CELLSIZE = 80
    let FIELDINSET_Y = 780
    let FIELDINSET = 2
    let NO_POSSIBLE_SOLUTION_FROM_POINT = 90
    let NO_MORE_SPOTS = 60
    let INPUT_SIZE = 50
    let DUMMY = 0
    let FONT_SIZE = 48.0 as CGFloat
    var delegate : BoardDelegate?

    override func drawRect(rect: CGRect) {
        for (var i = 0; i < BOARD_WIDTH; i++) {
            for (var j = 1; j <= BOARD_HEIGHT; j++) {
                var x = CGFloat(FIELDINSET + i * CELLSIZE)
                var y = CGFloat(FIELDINSET + (j-1) * CELLSIZE)
                
                var rectangle = CGRectMake(x,y,CGFloat(CELLSIZE),CGFloat(CELLSIZE))
                var context = UIGraphicsGetCurrentContext()
                CGContextBeginPath(context)
                CGContextStrokePath(context)
                CGContextStrokeRect(context, rectangle)
                //Asks for queen or a blank to place in each square
                
                //----------------------------THIS IS CAUSING CRASH
                var queen = NSString(format: "%d", self.delegate!.getContentAtRow(j, col: i).toInt()!)
                
                var textFont = UIFont.systemFontOfSize(FONT_SIZE)
                
                //Determines if a queen is at a give location and colors the location appropriately
                self.colorPickerWithContext(context)
                // NSLog(@"i: %i j: %i", i, j);
                if queen == "Q" {
                    CGContextFillRect(context, rectangle)
                    queen.drawInRect(rectangle, withAttributes: [NSFontAttributeName:textFont])
                }
            }
        }
    }
    
    /*This registers that the user has tapped in a specific location and allows a queen to be placed there*/
    func tap(gesture : UITapGestureRecognizer) {
        if (gesture.state == UIGestureRecognizerState.Ended) {
            var tapPoint = gesture.locationInView(self)
            NSLog("digit pressed is X:%f and Y: %f", tapPoint.x, tapPoint.y)
            
            var done = false
            for var i = 0; i < BOARD_WIDTH && done == false; i++ {
                for var j = 0; j < BOARD_HEIGHT && done == false; j++ {
                    var x = CGFloat(FIELDINSET + i * CELLSIZE)
                    var y = CGFloat(FIELDINSET + (j-1) * CELLSIZE)
                    
                    var rectangle = CGRectMake(x,y,CGFloat(CELLSIZE),CGFloat(CELLSIZE))
                    //If a square contains the point the user tapped it will
                    //place a queen there
                    if CGRectContainsPoint(rectangle,tapPoint) {
                        NSLog("Point(%f, %f) is contained in rectangle %d,%d ", tapPoint.x, tapPoint.y,x,y)
                        done = true
                        break
                    }
                }
            }
            //If a square contains the point the user tapped it will
            //update the most recently slected number to that value
            var numbers = 0
            for var i = 0; i < NUMBERS_WIDTH && done == false; i++ {
                numbers++
                var x = CGFloat(FIELDINSET + i * CELLSIZE)
                var rectangle = CGRectMake(x,CGFloat(FIELDINSET_Y),CGFloat(CELLSIZE),CGFloat(CELLSIZE))
                
                if CGRectContainsPoint(rectangle,tapPoint) {
                    done = true
                    NSLog("Point(%f, %f) is contained in rectangle %d,0 ", tapPoint.x, tapPoint.y,x)
                }
            }
        }
    }
    
    /*Randomly asisgns a queen a color*/
    func colorPickerWithContext(context : CGContextRef) {
        var random = Int.random(BOARD_HEIGHT+1)
        switch (random) {
            case 1:
                CGContextSetRGBFillColor(context,0.6,0.6, 0.0, 1.0)
            case 2:
                CGContextSetRGBFillColor(context,1.0,0.0, 0.0, 1.0)
            case 3:
                CGContextSetRGBFillColor(context,0.0,1.0, 0.0, 1.0)
            case 4:
                CGContextSetRGBFillColor(context,0.0,0.0, 1.0, 1.0)
            case 5:
                CGContextSetRGBFillColor(context,0.8,0.4, 1.0, 1.0)
            case 6:
                CGContextSetRGBFillColor(context,1.0,0.8, 0.0, 1.0)
            case 7:
                CGContextSetRGBFillColor(context,0.2,0.0, 0.8, 1.0)
            case 8:
                CGContextSetRGBFillColor(context,0.3,0.3, 0.3, 1.0)
            case 9:
                CGContextSetRGBFillColor(context,0.4,0.0, 0.8, 1.0)
            default:
                break
        }
    }
}

protocol BoardDelegate {
    func getContentAtRow(row : Int, col : Int) -> String
}