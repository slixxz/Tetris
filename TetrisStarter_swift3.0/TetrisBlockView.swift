//
//  TetrisBlock.swift
//  TetrisStarter
//
//  Created by AAK on 9/26/17.
//  Copyright © 2017 SSU. All rights reserved.
//

import UIKit

class TetrisBlockView: UIView {

    let blockColor: UIColor
    let blockModel: TetrisBlockModel
    let blockSize: Int
    var animator: UIViewPropertyAnimator!
    var angle = CGFloat(0.0)
    var blockBounds: CGSize
    var newInstance: TetrisViewController
    var nextShapePlease = false
    var turn: Bool

    
    
    init(color: UIColor, grid: TetrisBlockModel, blockSize: Int, startY: CGFloat, boardCenterX: CGFloat, tetView: TetrisViewController) {
        blockColor = color
        blockModel = grid
        turn = false
        self.blockSize = blockSize
        newInstance = tetView
        let width = CGFloat(blockSize * grid.blocksWide())
        let height = CGFloat(blockSize * grid.blocksHeigh())
        blockBounds = CGSize(width: width, height: height)
        var x = boardCenterX
        if grid.blocksWide() % 2 != 0 {  // pieces with odd number of sub-blocks will be shifted by blockSize/2 so they start on grid lines.
            x -= CGFloat(blockSize) / CGFloat(2.0)
        }
        x = x - CGFloat(blockSize/2)
        //let centerOfObject = Int(self.center.y)
        //let toTravel = CGFloat(newInstance.distanceToTravel(distanceToCenter: centerOfObject)) //checks how far it needs to go.
        let frame = CGRect(x: x, y: startY, width: width, height: height)
        super.init(frame: frame)
        let centerOfObject = Int(self.center.y)
        //let toTravel = 600//CGFloat(newInstance.distanceToTravel()) //checks how far it needs to go.
        backgroundColor = UIColor.clear
        addSubBlocksToView(grid: grid, blockSize: blockSize)

       /*
        animator = UIViewPropertyAnimator(duration: 1.0, curve: .linear) { [unowned self] in
            self.center.y += CGFloat(blockSize)
            self.startDescent()
            
            self.animator.addCompletion { _ in
            self.ContinueMoving()
           }
        }*/
        self.ContinueMoving()
    }

     public func ContinueMoving(){
        if self.newInstance.canIContinueMoving() {
            animator = UIViewPropertyAnimator(duration: 0.2, curve: .linear) { [unowned self] in
                self.center.y += CGFloat(self.blockSize)
                self.newInstance.updateShapeLocation()
                self.startDescent()
            }
            animator.addCompletion {_ in
                self.ContinueMoving()
                self.startDescent()
            }
        }
        else{
            newInstance.updateTwoDArray()
            newInstance.addRandomShapeToBoard()
        }
         //newInstance.addRandomShapeToBoard()
    }
   
    func startDescent() {
        animator.startAnimation()
        blockModel.printEdges()
    }
    
    func pauseAnimation() {
        if animator.state == .active {
            animator.pauseAnimation()
        }
    }
    
    func startAnimation() {
        if animator.state == .active {
            animator.startAnimation()
        }
    }
    
    func moveSideWays(offset: Int) { // need to check bounds in this
        if animator.state == .active {
            animator.pauseAnimation()
            UIView.animate(withDuration: 0.8, animations: { [unowned self, offset] in
                self.center.x += CGFloat(offset)
                }, completion: { [unowned self] (_) in
                    self.animator.startAnimation()
            })
        }
    }
    
    func printEdgeValues(edge: Edges) {
        let bottom = blockModel.edgeAttributes(edge: edge)
       // print(bottom.direction)
      //  print(bottom.edgeOffsets())
    }
    
    func moveRight() {
        moveSideWays(offset: blockSize)
    }
    
    func moveLeft() {
        moveSideWays(offset: -blockSize)
    }
    
    func rotateBlock(rotationAngle: CGFloat) {
        animator.pauseAnimation()
        
        let aPoint = CGPoint(x: 0.0, y: 0.0)  // upper-left
        let aPointInSuperView = superview!.convert(aPoint, from: self)
        print("Choosing reference point \(aPoint) to calculate the x-offset after the rotation.")
        print("The above reference point translated into the superview (board) is \(aPointInSuperView)")

        // Set up a new animation for the purpose of rotating the block.
        angle += rotationAngle
        let rotation = UIViewPropertyAnimator(duration: 1.0, curve: .easeInOut) { [unowned self, angle] in
            self.transform = CGAffineTransform(rotationAngle: angle)
        }
        
        // Once the rotation is complete, we will have to make sure that the block is aligned on the edge
        // of some vertical gridline. The gridlines are blockSize apart and logically divide the board.
        rotation.addCompletion { [unowned self] (_) in
            let aPointTranslated = self.superview!.convert(aPoint, from: self)
            print("After rotation, we translate \(aPointInSuperView) in the superview to get \(aPointTranslated).")
            let diffX = Int(abs(aPointInSuperView.x - aPointTranslated.x)) % self.blockSize
            print("We are \(diffX) points off from a vertical gridline.")
            UIView.animate(withDuration: 0.5, animations: {
                if self.turn{
                    self.center = CGPoint(x: self.center.x  + CGFloat(diffX), y: self.center.y)
                }
                else{
                    self.center = CGPoint(x: self.center.x - CGFloat(diffX), y: self.center.y)
                }
            })
            self.turn = !self.turn
            self.animator.startAnimation()
        }
        rotation.startAnimation()

    }
    
    func rotateCounterClockwise() {
        print("rotating counterclockwise")
        newInstance.rotatingLeft = true
        self.newInstance.updateShapeLocationAfterRotation()
        newInstance.rotatingLeft = false
        if animator.state != .active {
            return
        }
        animator.pauseAnimation()
        rotateBlock(rotationAngle: -CGFloat.pi / 2.0)
        blockModel.didRotateCounterClockwise()
       // printEdgeValues(edge: Edges.bottom)
        animator.startAnimation()
    }
    
    func rotateClockWise() {
        print("rotating clockwise")
        newInstance.rotatingRight = true
        self.newInstance.updateShapeLocationAfterRotation()
        newInstance.rotatingRight = false
        if animator.state != .active {
            return
        }
        animator.pauseAnimation()
        rotateBlock(rotationAngle: CGFloat.pi / 2.0)
        blockModel.didRotateClockwise()
       // printEdgeValues(edge: Edges.bottom)
    }
    
    func addSubBlocksToView(grid: TetrisBlockModel, blockSize: Int) {
        var topLeftY = 0
        for row in 0 ..< grid.blocksHeigh() {
            var topLeftX = 0
            for column in 0 ..< grid.blocksWide() {
                let bView = UIView(frame: CGRect(x: topLeftX, y: topLeftY, width: blockSize, height: blockSize))
                addSubview(bView)

                if grid.hasBlockAt(row: row, column: column) {
                    bView.backgroundColor = blockColor
                } else {
                    bView.backgroundColor = UIColor.clear 
                }
                topLeftX += blockSize
            }
            topLeftY += blockSize
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
