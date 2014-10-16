//
//  ViewController.swift
//  Min-Conflicts-N-Queens-Problem
//
//  Created by Zackery leman & Ruben Martinez on 10/15/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import UIKit

class ViewController: UIViewController, BoardDelegate {
    let DIMENSION : Int = 20
    var solver : minConflicts!
    @IBOutlet var board : Board!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //sets self as the view's delegate
        self.board.delegate = self
        self.board.setBoardSize(DIMENSION, cols: DIMENSION)
        
        //Creates a tap location detector
        /*let tap:UITapGestureRecognizer = UITapGestureRecognizer(self.board,
            action "tap")*/
        
        //Assigns detector to the view
        //self.board.addGestureRecognizer(tap)
        solver = minConflicts(n: DIMENSION, maxSteps:5000)
        
        //Update Board with starting Positions
        self.board.setNeedsDisplay()
    }
    
    func start() {
        self.board.startSolving()
        //in background thread
        dispatch_async(dispatch_queue_create("Solving queue", nil)) {
            if self.solver.minConflicts() {
                println("Solved!")
                println("Final Solution" + self.solver.columns.description)
                
                //in main thread, update view
                dispatch_async(dispatch_get_main_queue()) {
                    self.board.doneSolving(true)
                    //Shows final board positions
                    self.board.setNeedsDisplay()
                }
            } else {
                println("Could no be solved in time!")
                println("Final Unsolved State " + self.solver.columns.description)
                
                //in main thread, update view
                dispatch_async(dispatch_get_main_queue()) {
                    self.board.doneSolving(false)
                    //Shows final board positions
                    self.board.setNeedsDisplay()
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Takes a Col and Row and returns whether there is a queen at that position or not
    func getContentAtRow(row : Int, col: Int) -> String {
        if self.solver == nil {
            return "0"
        }
        if self.solver.columns[col] == row {
            return "Q"
        }
        return "0"
    }
    
}

