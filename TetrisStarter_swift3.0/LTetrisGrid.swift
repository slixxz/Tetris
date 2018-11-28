//
//  LTetrisGrid.swift
//  TetrisStarter_swift3.0
//
//  Created by student on 10/26/17.
//  Copyright © 2017 Ali A. Kooshesh. All rights reserved.
//

import UIKit

class LTetrisGrid: TetrisBlockModel {

    let lgrid = [
        [true, true, true],
        [true, false, false]
    ]
    
    init() {
        super.init(tetrisGrid: lgrid)
    }

}
