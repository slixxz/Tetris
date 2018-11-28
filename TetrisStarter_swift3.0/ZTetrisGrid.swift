//
//  ZTetrisGrid.swift
//  TetrisStarter
//
//  Created by AAK on 9/27/17.
//  Copyright © 2017 SSU. All rights reserved.
//

import UIKit

class ZTetrisGrid: TetrisBlockModel {

    let zgrid = [
        [true, true, false],
        [false, true, true]
    ]
    
    init() {
        super.init(tetrisGrid: zgrid)
    }

}
