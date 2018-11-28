//
//  QTetrisGrid.swift
//  TetrisStarter_swift3.0
//
//  Created by student on 10/2/17.
//  Copyright © 2017 Ali A. Kooshesh. All rights reserved.
//

import UIKit

class QTetrisGrid: TetrisBlockModel {

    let qgrid = [
        [true, true],
        [true, true]
    ]
    
    init() {
        super.init(tetrisGrid: qgrid)
    }
}
