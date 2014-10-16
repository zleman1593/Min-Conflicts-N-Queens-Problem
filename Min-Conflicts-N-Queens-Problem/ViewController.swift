//
//  ViewController.swift
//  Min-Conflicts-N-Queens-Problem
//
//  Created by Zackery leman & Ruben Martinez on 10/15/14.
//  Copyright (c) 2014 Zackery leman. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var solver : minConflicts!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        solver = minConflicts(n: 9, maxSteps:5000)
        start()
    }
    
    func start() {
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
    

}

