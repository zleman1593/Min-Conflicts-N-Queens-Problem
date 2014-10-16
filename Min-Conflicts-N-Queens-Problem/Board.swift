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
    let FIELDINSET_Y = 30
    let FIELDINSET_X = 8
    var delegate : BoardDelegate?
    var boardHeight : Int?
    var boardWidth  : Int?
    var cellSize : Int?
    var fontSize : CGFloat?
    @IBOutlet var activity: UIActivityIndicatorView!
    @IBOutlet var solveButton: UIButton!
    
    override func drawRect(rect: CGRect) {
        for i in 0..<boardWidth! {
            for j in 0..<boardHeight! {
                var x = CGFloat(FIELDINSET_X + i * cellSize!)
                var y = CGFloat(FIELDINSET_Y + j * cellSize!)
                
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
                    queen.drawInRect(rectangle, withAttributes: [NSFontAttributeName:textFont])
                }
            }
        }
    }
    
    @IBAction func solveConstraints(sender: AnyObject) {
        self.delegate!.start()
    }
    
    func startSolving() {
        self.activity.startAnimating()
        self.solveButton.enabled = false
        self.solveButton.backgroundColor = UIColor.lightGrayColor()
        self.solveButton.setTitle("Solving...", forState: UIControlState.Normal)
    }
    
    func doneSolving(solved: Bool) {
        self.activity.stopAnimating()
        if solved {
            self.solveButton.backgroundColor = UIColor(red: 0, green: 0.8, blue: 0.2, alpha: 1)
            self.solveButton.setTitle("Solved!", forState: UIControlState.Normal)
        } else {
            self.solveButton.backgroundColor = UIColor.redColor()
            self.solveButton.setTitle("Unsolved", forState: UIControlState.Normal)
        }
    }
    
    func setBoardSize(rowsAndColumns: Int) {
        self.boardHeight = rowsAndColumns
        self.boardWidth  = rowsAndColumns
        self.cellSize = Int(self.frame.width/CGFloat(self.boardWidth!))
        self.fontSize = CGFloat(self.cellSize!-5)
    }
    
    /*This registers that the user has tapped in a specific location and allows a queen to be placed there*/
    func tap(gesture : UITapGestureRecognizer) {
        if (gesture.state == UIGestureRecognizerState.Ended) {
            var tapPoint = gesture.locationInView(self)
            NSLog("digit pressed is X:%f and Y: %f", tapPoint.x, tapPoint.y)
            
            var done = false
            for var i = 0; i < boardWidth && done == false; i++ {
                for var j = 0; j < boardHeight && done == false; j++ {
                    var x = CGFloat(FIELDINSET_X + i * cellSize!)
                    var y = CGFloat(FIELDINSET_Y + (j-1) * cellSize!)
                    
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
        var r = CGFloat(Int.random(255))/255
        var g = CGFloat(Int.random(255))/255
        var b = CGFloat(Int.random(255))/255
        CGContextSetRGBFillColor(context, r, g, b, 1)
    }
}

protocol BoardDelegate {
    func getContentAtRow(row : Int, col : Int) -> String
    func start()
}