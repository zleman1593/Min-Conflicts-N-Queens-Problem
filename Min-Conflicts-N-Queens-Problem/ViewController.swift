//
//  ViewController.swift
//  Min-Conflicts-N-Queens-Problem
//
//  Created by Zackery leman & Ruben Martinez on 10/15/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import UIKit

class ViewController: UIViewController, BoardDelegate {
    var solver : minConflicts!
    @IBOutlet var board : Board!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //sets self as the view's delegate
        self.board.delegate = self
        
        //Creates a tap location detector
    /*let tap:UITapGestureRecognizer = UITapGestureRecognizer(self.board,
            action "tap")*/
        
        //Assigns detector to the view
        //self.board.addGestureRecognizer(tap)
        solver = minConflicts(n: 9, maxSteps:5000)
        //Update Board with starting Positions
        self.board.setNeedsDisplay()
    
        start()
    }
    
    func start() {
        if self.solver.minConflicts() {
            //Shows final board positions
            self.board.setNeedsDisplay()
            println("Solved!")
            println("Final Solution" + self.solver.columns.description)
        } else {
            //Shows final board positions
            self.board.setNeedsDisplay()
            println("Could no be solved in time!")
            println("Final Unsolved State " + self.solver.columns.description)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Takes a Col and Row and returns whether there is a queen at that position or not
    func getContentAtRow(row : Int, col: Int) -> String {
        if self.solver.columns[col] == row {
            return "Q"
        }
        return "0"
    }
    
}

