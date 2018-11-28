//
//  STetrisGrid.swift
//  TetrisStarter_swift3.0
//
//  Created by student on 10/2/17.
//  Copyright © 2017 Ali A. Kooshesh. All rights reserved.
//

import UIKit

class STetrisGrid: TetrisBlockModel {
   
    let sgrid = [
        [false, true, true],
        [true, true, false]
    ]
    
    init() {
        super.init(tetrisGrid: sgrid)
    }
}
