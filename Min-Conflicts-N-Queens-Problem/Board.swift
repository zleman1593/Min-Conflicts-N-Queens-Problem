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
    var delegate : BoardDelegate?
    var boardHeight : Int?
    var boardWidth  : Int?
    var cellSize : Int?
    var xPadding : CGFloat?
    var yPadding : CGFloat? = 30
    var fontSize : CGFloat?
    
    override func drawRect(rect: CGRect) {
        if boardWidth != nil && boardHeight != nil {
            //draw board
            for i in 0..<boardWidth! {
                for j in 0..<boardHeight! {
                    var x = xPadding! + CGFloat(i * cellSize!)
                    var y = yPadding! + CGFloat(j * cellSize!)
                    
                    var rectangle = CGRectMake(x,y,CGFloat(cellSize!),CGFloat(cellSize!))
                    
                    var context = UIGraphicsGetCurrentContext()
                    CGContextBeginPath(context)
                    CGContextStrokePath(context)
                    CGContextStrokeRect(context, rectangle)
                    
                    //Asks for queen or a blank to place in each square
                    var queen = self.delegate!.getContentAtRow(j, col: i)
                    var textFont = UIFont.systemFontOfSize(fontSize!)
                    
                    //Determines if a queen is at a give location and colors the location appropriately
                    self.colorPickerWithContext(context)
                    if queen == "Q" {
                        CGContextFillRect(context, rectangle)
                        queen = "👑"
                        queen.drawInRect(rectangle, withAttributes: [NSFontAttributeName:textFont])
                    }
                }
            }
        } else {
            //draw grayed-out board
            var rectangle = CGRectMake(0,30,self.frame.width,self.frame.width)
            var context = UIGraphicsGetCurrentContext()
            CGContextSetRGBFillColor(context, 0.5, 0.5, 0.5, 1)
            CGContextFillRect(context, rectangle)
        }
    }
    
    func setBoardSize(rowsAndColumns: Int) {
        self.boardHeight = rowsAndColumns
        self.boardWidth  = rowsAndColumns
        self.cellSize = Int(self.frame.width / CGFloat(rowsAndColumns))
        self.xPadding = (self.frame.width - (CGFloat(boardWidth!)*CGFloat(cellSize!)))/2
        self.fontSize = CGFloat(self.cellSize!-5)
    }
    
    /*This registers that the user has tapped in a specific location and allows a queen to be placed there*/
    func tap(gesture : UITapGestureRecognizer) {
        if (gesture.state == UIGestureRecognizerState.Ended) {
            var tapPoint = gesture.locationInView(self)
            NSLog("digit pressed is X:%f and Y: %f", tapPoint.x, tapPoint.y)
            
            var done = false
            for var i = 0; i < boardWidth && done == false; i++ {
                for var j = 0; j < (boardHeight! + 1) && done == false; j++ {
                    var x = xPadding! + CGFloat(i * cellSize!)
                    var y = yPadding! + CGFloat(j * cellSize!)
                    
                    var rectangle = CGRectMake(x,y,CGFloat(cellSize!),CGFloat(cellSize!))

                    //If a square contains the point the user tapped it will
                    //place a queen there
                    if CGRectContainsPoint(rectangle,tapPoint) {
                        NSLog("Point(%f, %f) is contained in rectangle %d,%d ", tapPoint.x, tapPoint.y,x,y)
                        done = true
                      self.delegate!.updateColumn(i,row: j-1)
                        println("i: \(i)  j: \(j-1)")
                        break
                    }
                }
            }
            
        }
    }
    
    /*Randomly asisgns a queen a color*/
    func colorPickerWithContext(context : CGContextRef) {
        var r = CGFloat(Int.random(255))/255
        var g = CGFloat(Int.random(255))/255
        var b = CGFloat(Int.random(255))/255
        CGContextSetRGBFillColor(context, r, g, b, 1)
    }
}

protocol BoardDelegate {
    func getContentAtRow(row : Int, col : Int) -> String
    func updateColumn(column : Int, row : Int )
}