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
    var boardHeight = 9
    var boardWidth  = 9
    let FIELDINSET_Y = 780
    let FIELDINSET = 2
    let FONT_SIZE  = 24.0 as CGFloat
    var delegate : BoardDelegate?
    var cellSize : Int?

    override func drawRect(rect: CGRect) {
        cellSize = Int(self.frame.width/CGFloat(boardWidth))
        
        for i in 0..<boardWidth {
            for j in 1...boardHeight {
                var x = CGFloat(FIELDINSET + i * cellSize!)
                var y = CGFloat(FIELDINSET + (j-1) * cellSize!)
                
                var rectangle = CGRectMake(x,y,CGFloat(cellSize!),CGFloat(cellSize!))

                var context = UIGraphicsGetCurrentContext()
                CGContextBeginPath(context)
                CGContextStrokePath(context)
                CGContextStrokeRect(context, rectangle)

                //Asks for queen or a blank to place in each square
                var queen = self.delegate!.getContentAtRow(j, col: i)
                var textFont = UIFont.systemFontOfSize(CGFloat(cellSize!))
                
                //Determines if a queen is at a give location and colors the location appropriately
                self.colorPickerWithContext(context)
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
            for var i = 0; i < boardWidth && done == false; i++ {
                for var j = 0; j < boardHeight && done == false; j++ {
                    var x = CGFloat(FIELDINSET + i * cellSize!)
                    var y = CGFloat(FIELDINSET + (j-1) * cellSize!)
                    
                    var rectangle = CGRectMake(x,y,CGFloat(cellSize!),CGFloat(cellSize!))

                    //If a square contains the point the user tapped it will
                    //place a queen there
                    if CGRectContainsPoint(rectangle,tapPoint) {
                        NSLog("Point(%f, %f) is contained in rectangle %d,%d ", tapPoint.x, tapPoint.y,x,y)
                        done = true
                        //INSERT CALL TO DELEGATE METHOD THAT ADDS A QUEEN AT THIS i and j
                        break
                    }
                }
            }
            
        }
    }
    
    /*Randomly asisgns a queen a color*/
    func colorPickerWithContext(context : CGContextRef) {
        var random = Int.random(boardHeight+1)
        switch random {
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