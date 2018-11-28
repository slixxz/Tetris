//
//  TTetrisGrid.swift
//  TetrisStarter_swift3.0
//
//  Created by student on 10/26/17.
//  Copyright © 2017 Ali A. Kooshesh. All rights reserved.
//

import UIKit

class TTetrisGrid: TetrisBlockModel {
    let tgrid = [
        [true, true, true],
        [false, true, false]
    ]
    
    init() {
        super.init(tetrisGrid: tgrid)
    }
    


}
