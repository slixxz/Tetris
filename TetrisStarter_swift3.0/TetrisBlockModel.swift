//
//  TetrisGrid.swift
//  TetrisStarter
//
//  Created by AAK on 9/26/17.
//  Copyright © 2017 SSU. All rights reserved.
//

import UIKit


enum OffsetTraversal {
    case forward
    case backward
}

class TetrisBlockModel: NSObject {
    private let grid: [[Bool]]  // Every row is expected to have the same number of columns
    private var blockEdgeAttributes: GridEdgeAttributes!
    private var blockEdges = [TetrisBlockEdge]() // stores my left right 0 1 and 001 ect.
    private let edges: [Edges] = [.bottom, .left, .top, .right]  // Any order will work
    private let bottomEdgeIdx = 0
    private var currentDirection: OffsetTraversal

    init(tetrisGrid: [[Bool]]) {
        grid = tetrisGrid
        currentDirection = .forward
        super.init()
        blockEdgeAttributes = GridEdgeAttributes(grid: smallestVisibleGrid()!)
        for edge in edges {
            blockEdges.append( blockEdgeAttributes.edgeAttributes(edgeName: edge)! )
        }
        
    }
    
    func printEdges() {
        for edge in edges {
            let edgeAttr = edgeAttributes(edge: edge)

            //print(edgeAttr.edgeName, edgeAttr.direction)
            //print(edgeAttr.edgeOffsets())
        }
    }
    
    func didRotateClockwise() {
        let lastIdx = blockEdges.count - 1

        print("begin printing edges before rotating them cw")
        printEdges()
        print("end printing edges before rotating them cw")

        blockEdges = [blockEdges[lastIdx]] + blockEdges[0 ... lastIdx - 1]
        blockEdges[0].reverseOffsets()
        blockEdges[2].reverseOffsets()
        
        print("begin printing edges after rotating them cw")
        printEdges()
        print("end printing edges after rotating them cw")
        

    }
    
    func didRotateCounterClockwise() {
        let lastIdx = blockEdges.count - 1
        print("begin printing edges before rotating them ccw")
        printEdges()
        print("end printing edges before rotating them ccw")
        print()
        blockEdges = blockEdges[1 ... lastIdx] + [blockEdges[0]]
        blockEdges[1].reverseOffsets()
        blockEdges[3].reverseOffsets()
        print("begin printing edges after rotating them ccw")
        printEdges()
        print("end printing edges after rotating them ccw")
    }
    
    func edgeAttributes(edge: Edges) -> TetrisBlockEdge {
        var idx = 0
        switch edge {
        case Edges.bottom:
            idx = 0
        case Edges.left:
            idx = 1
        case Edges.top:
            idx = 2
        case Edges.right:
            idx = 3
        }
        blockEdges[idx].direction = currentDirection
        return blockEdges[idx]
    }
    
    func hasBlockAt(row: Int, column: Int) -> Bool {
        return grid[row][column]
    }
    
    func numRows() -> Int {
        return grid.count
    }
    
    func numColumns() -> Int {
        // pre-condition: every row has the same number of columns.
        return grid[0].count
    }
    
    func blocksWide() -> Int {
        return numColumns()
    }
    
    func blocksHeigh() -> Int {
        return numRows()
    }
    
    func smallestVisibleGrid() -> [[Bool]]? {
        return smallestSpanningGrid()
    }
    
}

private extension TetrisBlockModel {
    func rowHasAVisibleBlock(row: Int) -> Bool {
        for column in 0 ..< numColumns() {
            if hasBlockAt(row: row, column: column) {
                return true
            }
        }
        return false
    }
    
    func columnHasAVisibleBlock(column: Int) -> Bool {
        for row in 0 ..< numRows() {
            if hasBlockAt(row: row, column: column) {
                return true
            }
        }
        return false
    }
    
    func smallestSpanningGrid() -> [[Bool]]? {
        // Finds the smallest two dimentional array that contains all
        // squares of the Tetris grid.
        var firstRow = 0
        while firstRow < numRows() && !rowHasAVisibleBlock(row: firstRow) {
            firstRow += 1
        }
        if firstRow == numRows() {
            return nil
        }
        var firstColumn = 0
        while firstColumn < numColumns() && !columnHasAVisibleBlock(column: firstColumn) {
            firstColumn += 1
        }
        if firstColumn == numColumns() {
            return nil
        }
        
        var lastVisibleRow = 0, lastVisibleColumn = 0
        for row in firstRow ..< numRows() {
            var didSeeAVisibleBlock = false
            for column in firstColumn ..< numColumns() {
                if hasBlockAt(row: row, column: column) && column > lastVisibleColumn {
                    lastVisibleColumn = column
                    didSeeAVisibleBlock = true
                }
            }
            if didSeeAVisibleBlock {
                lastVisibleRow = row
            }
        }
        let numVisibleRows = lastVisibleRow - firstRow + 1
        let numVisibleColumns = lastVisibleColumn - firstColumn + 1
        
        var visibleBlock = [[Bool]]()
        for row in 0 ..< numVisibleRows {
            var currentRow = [Bool]()
            for column in 0 ..< numVisibleColumns {
                currentRow.append( hasBlockAt(row: row + firstRow, column: column + firstColumn) )
            }
            visibleBlock.append(currentRow)
        }
        return visibleBlock
    }

}
