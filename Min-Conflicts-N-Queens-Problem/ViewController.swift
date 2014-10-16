//
//  ViewController.swift
//  Min-Conflicts-N-Queens-Problem
//
//  Created by Zackery leman & Ruben Martinez on 10/15/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import UIKit

class ViewController: UIViewController , chessBoardDelegate {
    var solver : minConflicts!
    @IBOutlet var board: chessBoard!
    override func viewDidLoad() {
        super.viewDidLoad()
        //sets self as the view's delegate
        self.board.delegate = self;
        //Creates a tap location detector
        let tap:UITapGestureRecognizer = UITapGestureRecognizer(self.board,
            action "tap")*/
        //Assigns detector to the view
        self.board.addGestureRecognizer(tap)
        solver = minConflicts(n: 9, maxSteps:5000)
 self.board.setNeedsDisplay()
        start()
    }
    
    func start() {
        //Shows final board positions
         self.board.setNeedsDisplay()
        if self.solver.minConflicts() {
            
            println("Solved!")
            println("Final Solution" + self.solver.columns.description)
        } else {
            println("Could no be solved in time!")
            println("Final Unsolved State " + self.solver.columns.description)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Takes a Col and Row and returns the number at that position
    func getContentAtRow(row : Int,col: Int ) -> NSString {
        if self.solver.columns[col] == row{
            return "1"
        }
    return "0"
    }
    
    // the number the user selected to place at a location
    func numberSelected(number: Int){

    }
    
    /*Takes a Col and Row and returns and sets the value at that
    * location to the last user selected number*/
    func squareSelectedAtRow(row : Int,col: Int ){
    //makes the hint disappear
    //does nothing
    }

}

