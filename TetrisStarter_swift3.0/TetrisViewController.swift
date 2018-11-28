 //
//  TetrisViewController.swift
//  TetrisStarter
//
//  Created by AAK on 9/26/17.
//  Copyright © 2017 SSU. All rights reserved.
//

import UIKit

class TetrisViewController: UIViewController {
 
    public struct ObjectLocation {
        var row: Int
        var col: Int
        init(row: Int, col: Int){
            self.row = row
            self.col = col
        }
    }
    // standard Tetris board is 10 wide and 20 high.
    let boardGridHigh = 20
    let boardGridWide = 10
    let blockSize = 30
    
    var tetrisBoard: TetrisBoardView!
    var block: TetrisBlockView!
    
    var inMotion = false
    var paused = false
    var gameOver = false
    var rightMost = 0 // can be between 0 and 10
    var leftMost = 0 // can be between 0 and 10 ALWAYS STARTS AT 4 //4 blocks over
    var columnNumToSetin2D = 0
    var rowNumToSetin2D = 0
    var randoNumber = 0
    var rotatingRight = false
    var rotatingLeft = false
    var currentSide = 0
    var tempColor = UIColor()
    var completeRow = true
    
   // var objectLocationArray = [ObjectLocation]()
    var distanceOfBottomShape = [Int]()
    var distancesPossibiltys = [Int]()
    var twoDarray: [[Bool]] = Array(repeating: Array(repeating: false, count: 15), count: 22)
    var objectLocationArray = [ObjectLocation]()
    var twoDArrayOfViews = [[UIView]]()
 
    @IBAction func didTapTheView(_ sender: UITapGestureRecognizer) {
        if !inMotion  {
            inMotion = true
            block.startDescent()
            return
        }

        let location = sender.location(in: tetrisBoard)
        //print(location)
        
            block.rotateClockWise()
        
     }
    
    @IBAction func didSwipeView(_ sender: UISwipeGestureRecognizer) {
        if sender.direction == .left {
            if canIMoveLeft(){

            leftMost -= 1
            rightMost -= 1
                if(leftMost <= 0){
                    leftMost = 0
                    rightMost += 1
                }
                else{
                objectLocationArray[0].col = objectLocationArray[0].col-1
                objectLocationArray[1].col = objectLocationArray[1].col-1
                objectLocationArray[2].col = objectLocationArray[2].col-1
                objectLocationArray[3].col = objectLocationArray[3].col-1
                block.moveLeft()
                }
            }
        }
        else {
            if canIMoveRight(){
            rightMost += 1
            leftMost += 1
            if(rightMost >= 14)
            {
                rightMost = 14
                leftMost -= 1
            }
            else{
                objectLocationArray[0].col = objectLocationArray[0].col+1
                objectLocationArray[1].col = objectLocationArray[1].col+1
                objectLocationArray[2].col = objectLocationArray[2].col+1
                objectLocationArray[3].col = objectLocationArray[3].col+1
                block.moveRight()
            }
            
        }
       // distanceToTravel() update the distance to travel
    }
}
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        tetrisBoard = TetrisBoardView(withFrame: UIScreen.main.bounds, blockSize: blockSize, circleRadius: 1 )
       
        view.addSubview(tetrisBoard)
        createMy2DView()
        addRandomShapeToBoard()
        //print("Center of block before animation: \(block.center)")
        //print("Bounds of main screen is \(UIScreen.main.bounds)")
    }
    

    func createMy2DView(){
        
        for i in 0..<22 {
            var tempRowView = [UIView]()
            for j in 0..<14 {
                let Arblock = CGRect(x: j * blockSize, y: i * blockSize, width: blockSize, height: blockSize)
                let frame = UIView(frame: Arblock)
                view.backgroundColor = UIColor.clear
                tetrisBoard.addSubview(frame)
                tempRowView.append(frame)
            }
            twoDArrayOfViews.append(tempRowView)
        }
    }
    
    
    public func updateTwoDArray(){
       
        twoDarray[objectLocationArray[0].row][objectLocationArray[0].col] = true
        twoDarray[objectLocationArray[1].row][objectLocationArray[1].col] = true
        twoDarray[objectLocationArray[2].row][objectLocationArray[2].col] = true
        twoDarray[objectLocationArray[3].row][objectLocationArray[3].col] = true
        print("1 Box afer landing row x,y: \(objectLocationArray[0].row) \(objectLocationArray[0].col)")
        print("2 Box after landing row x,y: \(objectLocationArray[1].row) \(objectLocationArray[1].col)")
        print("3 Box after landing row x,y: \(objectLocationArray[2].row) \(objectLocationArray[2].col)")
        print("4 Box after landing row x,y: \(objectLocationArray[3].row) \(objectLocationArray[3].col)")
        
        createViewsAtDestination()
        printTruthTwoDArray()
    }
    
   func createViewsAtDestination(){
    
    //make views at the 4 locations you just hit.
    let myNewView1 = UIView(frame: CGRect(x: (objectLocationArray[0].col - 1) * 30, y: (objectLocationArray[0].row + 1) * 30, width: 30, height: 30))
    let myNewView2 = UIView(frame: CGRect(x: (objectLocationArray[1].col - 1) * 30, y: (objectLocationArray[1].row + 1) * 30, width: 30, height: 30))
    let myNewView3 = UIView(frame: CGRect(x: (objectLocationArray[2].col - 1) * 30, y: (objectLocationArray[2].row + 1) * 30, width: 30, height: 30))
    let myNewView4 = UIView(frame: CGRect(x: (objectLocationArray[3].col - 1) * 30, y: (objectLocationArray[3].row + 1) * 30, width: 30, height: 30))
    // Change UIView background colour
    myNewView1.backgroundColor = tempColor
    myNewView2.backgroundColor = tempColor
    myNewView3.backgroundColor = tempColor
    myNewView4.backgroundColor = tempColor
    
    self.view.addSubview(myNewView1)
    self.view.addSubview(myNewView2)
    self.view.addSubview(myNewView3)
    self.view.addSubview(myNewView4)


    
    self.block.removeFromSuperview()
  
    /*
    twoDArrayOfViews[objectLocationArray[0].col][objectLocationArray[0].row].backgroundColor = tempColor
    twoDArrayOfViews[objectLocationArray[1].col][objectLocationArray[1].row].backgroundColor = tempColor
    twoDArrayOfViews[objectLocationArray[2].col][objectLocationArray[2].row].backgroundColor = tempColor
    twoDArrayOfViews[objectLocationArray[3].col][objectLocationArray[3].row].backgroundColor = tempColor
    */
    isThereARowComplete()//check for complete rows
        
        
    }
    
    
    func canIContinueMoving() ->Bool {
        //if the cordinants next spot for any of them is a UIview color return false
        if objectLocationArray[0].row > 20 || objectLocationArray[1].row > 20 || objectLocationArray[2].row > 20 || objectLocationArray[3].row > 20{
            updateTwoDArray()
            return false
        }
        if self.twoDarray[objectLocationArray[0].row + 1][objectLocationArray[0].col] == true && objectLocationArray[0].row == 0{
            print("YOU Lose")
        }
        if      self.twoDarray[objectLocationArray[0].row + 1][objectLocationArray[0].col] == true ||
                self.twoDarray[objectLocationArray[1].row + 1][objectLocationArray[1].col] == true ||
                self.twoDarray[objectLocationArray[2].row + 1][objectLocationArray[2].col] == true ||
                self.twoDarray[objectLocationArray[3].row + 1][objectLocationArray[3].col] == true {
                updateTwoDArray()
         return false
        }
            
        else{
            return true
        }
    }
    
   // func nextShape(){
   //      self.addRandomShapeToBoard()
   // }

    
  public func addRandomShapeToBoard() {
    print("    NEXT BLOCK     ")
    randoNumber = randomShapeGenerator()
     var blockColor = randomColor()

    if randoNumber == 0{
        self.whatShapeAmIInit()
       //a color = randomColor(randomColor)
        rightMost = 6
        let grid = QTetrisGrid()
        block = TetrisBlockView(color: blockColor, grid: grid, blockSize: blockSize,
                                    startY: 30.0, boardCenterX: CGFloat(105.0), tetView: self)
        view.addSubview(block)
         block.startDescent()
        }
    if randoNumber == 1{
    //set struct cordinates for object
        self.whatShapeAmIInit()
        rightMost = 7
        let grid = ZTetrisGrid()
            block = TetrisBlockView(color: blockColor, grid: grid, blockSize: blockSize,
                                    startY: 30.0, boardCenterX: CGFloat(120.0), tetView: self)
        view.addSubview(block)
        block.startDescent()
        }
    if randoNumber == 2{
        //set struct cordinates for object
        self.whatShapeAmIInit()
        rightMost = 7
        let grid = JTetrisGrid()
        block = TetrisBlockView(color: blockColor, grid: grid, blockSize: blockSize,
                                    startY: 30.0, boardCenterX: CGFloat(120.0), tetView: self)
         view.addSubview(block)
        block.startDescent()
        }
    if randoNumber == 3{
        //set struct cordinates for object
         self.whatShapeAmIInit()
        rightMost = 8
        let grid = ITetrisGrid()
        block = TetrisBlockView(color: blockColor, grid: grid, blockSize: blockSize,
                                    startY: 30.0, boardCenterX: CGFloat(105.0), tetView: self)
         view.addSubview(block)
        block.startDescent()
        }
    if randoNumber == 4{
        //set struct cordinates for object
        self.whatShapeAmIInit()
        rightMost = 7
        let grid = STetrisGrid()
        block = TetrisBlockView(color: blockColor, grid: grid, blockSize: blockSize,
                                    startY: 30.0, boardCenterX: CGFloat(120.0), tetView: self)
        view.addSubview(block)
        block.startDescent()
        }
    if randoNumber == 5{ //L
        //set struct cordinates for object
        self.whatShapeAmIInit()
        rightMost = 7
        let grid = LTetrisGrid()
        block = TetrisBlockView(color: blockColor, grid: grid, blockSize: blockSize,
                                startY: 30.0, boardCenterX: CGFloat(120.0), tetView: self)
        view.addSubview(block)
        block.startDescent()
    }
    if randoNumber == 6{ // T
        //set struct cordinates for object
        self.whatShapeAmIInit()
        rightMost = 7
        let grid = TTetrisGrid()
        block = TetrisBlockView(color: blockColor, grid: grid, blockSize: blockSize,
                                startY: 30.0, boardCenterX: CGFloat(120.0), tetView: self)
        view.addSubview(block)
        block.startDescent()
    }
    
        self.block.ContinueMoving()

    }
    
    func isThereARowComplete(){
        
        for i in 0..<20 {
            for j in 0..<13 {
                if twoDarray[i][j] == false {
                    completeRow = false
                }
            }
            if completeRow == true{
                swapRows(tempRow: i)
            }
        }
    }
    
    func swapRows(tempRow: Int){
      
        //  for x in 0..<13{
        
      //  }
    }
    
    public func updateShapeLocation(){
        //print("1 Box Before update row x,y: \(objectLocationArray[0].row) \(objectLocationArray[0].col)")
        //print("2 Box Before update row x,y: \(objectLocationArray[1].row) \(objectLocationArray[1].col)")
        //print("3 Box Before update row x,y: \(objectLocationArray[2].row) \(objectLocationArray[2].col)")
        //print("4 Box Before update row x,y: \(objectLocationArray[3].row) \(objectLocationArray[3].col)")
        objectLocationArray[0].row = objectLocationArray[0].row+1
        objectLocationArray[1].row = objectLocationArray[1].row+1
        objectLocationArray[2].row = objectLocationArray[2].row+1
        objectLocationArray[3].row = objectLocationArray[3].row+1
        //print("1 After \(objectLocationArray[0].row) \(objectLocationArray[0].col)")
        //print("2 After \(objectLocationArray[1].row) \(objectLocationArray[1].col)")
        //print("3 After \(objectLocationArray[2].row) \(objectLocationArray[2].col)")
        //print("4 After \(objectLocationArray[3].row) \(objectLocationArray[3].col)")
    }
    
    func updateShapeLocationAfterRotation(){
        switch randoNumber{
            
        case 0://SQUARE
            print("squares dont need to rotate sily")
        case 1://Z
                switch currentSide{
                case 0:
                    if  twoDarray[objectLocationArray[0].row][objectLocationArray[0].col+1] == true ||
                        twoDarray[objectLocationArray[1].row+1][objectLocationArray[1].col] == true ||
                        twoDarray[objectLocationArray[2].row][objectLocationArray[2].col-1] == true ||
                        twoDarray[objectLocationArray[3].row+1][objectLocationArray[3].col-2] == true{
                    }
                    else{
                        objectLocationArray[0].col += 1
                        objectLocationArray[1].row += 1
                        objectLocationArray[2].col -= 1
                        objectLocationArray[3].row += 1
                        objectLocationArray[3].col -= 2
                        //update the cords
                        currentSide = 1
                    }
                case 1:
                    if  twoDarray[objectLocationArray[0].row][objectLocationArray[0].col-1] == true ||
                        twoDarray[objectLocationArray[1].row-1][objectLocationArray[1].col] == true ||
                        twoDarray[objectLocationArray[2].row][objectLocationArray[2].col+1] == true ||
                        twoDarray[objectLocationArray[3].row-1][objectLocationArray[3].col+2] == true{
                    }
                    else{
                        objectLocationArray[0].col -= 1
                        objectLocationArray[1].row -= 1
                        objectLocationArray[2].col += 1
                        objectLocationArray[3].row -= 1
                        objectLocationArray[3].col += 2
                        //update the cords
                        currentSide = 0
                    }
                default: print("problems")
            }
        case 2://J
                switch currentSide{
                case 0:
                    if  twoDarray[objectLocationArray[0].row][objectLocationArray[0].col+1] == true ||
                        twoDarray[objectLocationArray[1].row-1][objectLocationArray[1].col] == true ||
                        twoDarray[objectLocationArray[2].row][objectLocationArray[2].col-1] == true ||
                        twoDarray[objectLocationArray[3].row+1][objectLocationArray[3].col-2] == true{
                    }
                    else{
                        //update the cords
                        objectLocationArray[0].col += 1
                        objectLocationArray[1].row -= 1
                        objectLocationArray[2].col -= 1
                        objectLocationArray[3].row += 1
                        objectLocationArray[3].col -= 2
                        currentSide = 1
                    }
                case 1:
                    if  twoDarray[objectLocationArray[0].row+1][objectLocationArray[0].col+1] == true ||
                        twoDarray[objectLocationArray[1].row][objectLocationArray[1].col+2] == true ||
                        twoDarray[objectLocationArray[2].row-1][objectLocationArray[2].col+1] == true ||
                        twoDarray[objectLocationArray[3].row-2][objectLocationArray[3].col] == true{
                    }
                    else{
                        //update the cords
                        objectLocationArray[0].row += 1
                        objectLocationArray[0].col += 1
                        objectLocationArray[1].col += 2
                        objectLocationArray[2].col += 1
                        objectLocationArray[2].row -= 1
                        objectLocationArray[3].row -= 2
                        currentSide = 2
                    }
                case 2:
                    if  twoDarray[objectLocationArray[0].row+1][objectLocationArray[0].col-2] == true ||
                        twoDarray[objectLocationArray[1].row+2][objectLocationArray[1].col-1] == true ||
                        twoDarray[objectLocationArray[2].row+1][objectLocationArray[2].col] == true ||
                        twoDarray[objectLocationArray[3].row][objectLocationArray[3].col+1] == true{
                    }
                    else{
                        //update the cords
                        objectLocationArray[0].row += 1
                        objectLocationArray[0].col -= 2
                        objectLocationArray[1].row += 2
                        objectLocationArray[1].col -= 1
                        objectLocationArray[2].row += 1
                        objectLocationArray[3].col += 1
                        currentSide = 3
                    }
                case 3:
                    if  twoDarray[objectLocationArray[0].row-2][objectLocationArray[0].col] == true ||
                        twoDarray[objectLocationArray[1].row-1][objectLocationArray[1].col-1] == true ||
                        twoDarray[objectLocationArray[3].row+1][objectLocationArray[3].col+1] == true{
                    }
                    else{
                        //update the cords
                        objectLocationArray[0].row -= 2
                        objectLocationArray[1].col -= 1
                        objectLocationArray[1].row -= 1
                        objectLocationArray[3].col += 1
                        objectLocationArray[3].row += 1
                        currentSide = 0
                    }
                default: print("problems")
            }
        case 3://I
             switch currentSide{
                case 0:
                    if  twoDarray[objectLocationArray[0].row+1][objectLocationArray[0].col+1] == true ||
                        twoDarray[objectLocationArray[2].row-1][objectLocationArray[2].col-1] == true ||
                        twoDarray[objectLocationArray[3].row-2][objectLocationArray[3].col-2] == true{
                    }
                    else{
                        objectLocationArray[0].row += 1
                        objectLocationArray[0].col += 1
                        objectLocationArray[2].row -= 1
                        objectLocationArray[2].col -= 1
                        objectLocationArray[3].row -= 2
                        objectLocationArray[3].col -= 2
                        currentSide = 1
                }
                case 1:
                    if  twoDarray[objectLocationArray[0].row][objectLocationArray[0].col+2] == true ||
                        twoDarray[objectLocationArray[1].row+1][objectLocationArray[1].col+1] == true ||
                        twoDarray[objectLocationArray[2].row+2][objectLocationArray[2].col] == true ||
                        twoDarray[objectLocationArray[3].row+3][objectLocationArray[3].col-1] == true{
                    }
                    else{
                        //update the cords
                        objectLocationArray[0].col += 2
                        objectLocationArray[1].col += 1
                        objectLocationArray[1].row += 1
                        objectLocationArray[2].row += 2
                        objectLocationArray[3].row += 3
                        objectLocationArray[3].col -= 1
                        currentSide = 2
                }
                case 2:
                    if  twoDarray[objectLocationArray[0].row+1][objectLocationArray[0].col-2] == true ||
                        twoDarray[objectLocationArray[1].row][objectLocationArray[1].col-1] == true ||
                        twoDarray[objectLocationArray[2].row-1][objectLocationArray[2].col] == true ||
                        twoDarray[objectLocationArray[3].row-2][objectLocationArray[3].col+1] == true{
                    }
                    else{
                        //update the cords
                        objectLocationArray[0].row += 1
                        objectLocationArray[0].col -= 2
                        objectLocationArray[1].col -= 1
                        objectLocationArray[2].row -= 1
                        objectLocationArray[3].row -= 2
                        objectLocationArray[3].col += 1
                        currentSide = 3
                }
                case 3:
                    if  twoDarray[objectLocationArray[0].row-2][objectLocationArray[0].col-1] == true ||
                        twoDarray[objectLocationArray[1].row-1][objectLocationArray[1].col] == true ||
                        twoDarray[objectLocationArray[2].row-2][objectLocationArray[2].col+3] == true ||
                        twoDarray[objectLocationArray[3].row][objectLocationArray[3].col+1] == true{
                    }
                    else{
                        objectLocationArray[0].row -= 2
                        objectLocationArray[0].col -= 1
                        objectLocationArray[1].row -= 1
                        objectLocationArray[2].row -= 2
                        objectLocationArray[2].col += 3
                        objectLocationArray[3].col += 1
                        //update the cords
                        currentSide = 0
                }
                default: print("problems")
            }
        case 4://S
                switch currentSide{
                   
                    
                case 0:
                    if  twoDarray[objectLocationArray[0].row+1][objectLocationArray[0].col] == true ||
                        twoDarray[objectLocationArray[1].row+2][objectLocationArray[1].col-1] == true ||
                        twoDarray[objectLocationArray[2].row-1][objectLocationArray[2].col] == true ||
                        twoDarray[objectLocationArray[3].row][objectLocationArray[3].col-1] == true{
                    }
                    else{
                        objectLocationArray[0].row += 1
                        objectLocationArray[1].row += 2
                        objectLocationArray[1].col -= 1
                        objectLocationArray[2].row -= 1
                        objectLocationArray[3].col -= 1
                        currentSide = 1
                    }
                case 1:
                    if  twoDarray[objectLocationArray[0].row-1][objectLocationArray[0].col] == true ||
                        twoDarray[objectLocationArray[1].row-2][objectLocationArray[1].col+1] == true ||
                        twoDarray[objectLocationArray[2].row+1][objectLocationArray[2].col] == true ||
                        twoDarray[objectLocationArray[3].row][objectLocationArray[3].col+1] == true{
                    }
                    else{
                        //update the cords
                        objectLocationArray[0].row -= 1
                        objectLocationArray[1].row -= 2
                        objectLocationArray[1].col += 1
                        objectLocationArray[2].row += 1
                        objectLocationArray[3].col += 1
                        currentSide = 0
                    }
                    
                default:
                    objectLocationArray[0].row += 1
                    objectLocationArray[1].row += 2
                    objectLocationArray[1].col -= 1
                    objectLocationArray[2].row -= 1
                    objectLocationArray[3].col -= 1
                    
            }
        case 5://L
                switch currentSide{
                case 0:
                    if  twoDarray[objectLocationArray[0].row][objectLocationArray[0].col+1] == true ||
                        twoDarray[objectLocationArray[1].row+1][objectLocationArray[1].col] == true ||
                        twoDarray[objectLocationArray[2].row+2][objectLocationArray[2].col-1] == true ||
                        twoDarray[objectLocationArray[3].row-1][objectLocationArray[3].col] == true{
                    }
                    else{
                        objectLocationArray[0].col += 1
                        objectLocationArray[1].row += 1
                        objectLocationArray[2].row += 2
                        objectLocationArray[2].col -= 1
                        objectLocationArray[3].row -= 1
                        //update the cords
                        currentSide = 1
                    }
                case 1:
                    if  twoDarray[objectLocationArray[0].row+1][objectLocationArray[0].col+1] == true ||
                        twoDarray[objectLocationArray[2].row-1][objectLocationArray[2].col-1] == true ||
                        twoDarray[objectLocationArray[3].row][objectLocationArray[3].col+2] == true{
                    }
                    else{
                        //update the cords
                        objectLocationArray[0].row += 1
                        objectLocationArray[0].col += 1
                        objectLocationArray[2].row -= 1
                        objectLocationArray[2].col -= 1
                        objectLocationArray[3].col += 2
                        currentSide = 2
                    }
                case 2:
                    if  twoDarray[objectLocationArray[0].row+1][objectLocationArray[0].col-2] == true ||
                        twoDarray[objectLocationArray[1].row][objectLocationArray[1].col-1] == true ||
                        twoDarray[objectLocationArray[2].row-1][objectLocationArray[2].col] == true ||
                        twoDarray[objectLocationArray[3].row+2][objectLocationArray[3].col-1] == true{
                    }
                    else{
                        //update the cords
                        objectLocationArray[0].row += 1
                        objectLocationArray[0].col -= 2
                        objectLocationArray[1].col -= 1
                        objectLocationArray[2].row -= 1
                        objectLocationArray[3].row += 2
                        objectLocationArray[3].col -= 1
                        currentSide = 3
                    }
                case 3:
                    if  twoDarray[objectLocationArray[0].row-2][objectLocationArray[0].col] == true ||
                        twoDarray[objectLocationArray[1].row-1][objectLocationArray[1].col+1] == true ||
                        twoDarray[objectLocationArray[2].row][objectLocationArray[2].col+2] == true ||
                        twoDarray[objectLocationArray[3].row][objectLocationArray[3].col-1] == true{
                    }
                    else{
                        //update the cords
                        objectLocationArray[0].row -= 2
                        objectLocationArray[1].col += 1
                        objectLocationArray[1].row -= 1
                        objectLocationArray[2].col += 2
                        objectLocationArray[3].row -= 1
                        objectLocationArray[3].col -= 1
                        currentSide = 0
                    }
                default: print("problems")
                }
            
        case 6://T
                print("rotating right T")
                print("0 Box Before rotate row, col: \(objectLocationArray[0].row) \(objectLocationArray[0].col)")
                print("1 Box Before rotate row, col: \(objectLocationArray[1].row) \(objectLocationArray[1].col)")
                print("2 Box Before rotate row, col: \(objectLocationArray[2].row) \(objectLocationArray[2].col)")
                print("3 Box Before update row, col: \(objectLocationArray[3].row) \(objectLocationArray[3].col)")
                switch currentSide{
                case 0:
                    print("case 0")
                    if  twoDarray[objectLocationArray[0].row][objectLocationArray[0].col+1] == true ||
                        twoDarray[objectLocationArray[1].row+1][objectLocationArray[1].col] == true ||
                        twoDarray[objectLocationArray[2].row+2][objectLocationArray[2].col-1] == true ||
                        twoDarray[objectLocationArray[3].row][objectLocationArray[3].col-1] == true{
                    }
                    else{
                        objectLocationArray[0].col += 1
                        objectLocationArray[1].row += 1
                        objectLocationArray[2].col -= 1
                        objectLocationArray[2].row += 2
                        objectLocationArray[3].col -= 1
                    }
                    //update the cords
                    currentSide = 1
                case 1:
                    if twoDarray[objectLocationArray[0].row+1][objectLocationArray[0].col+1] == true ||
                        twoDarray[objectLocationArray[2].row-1][objectLocationArray[2].col-1] == true ||
                        twoDarray[objectLocationArray[3].row-1][objectLocationArray[3].col+1] == true{
                    }
                    else{
                        objectLocationArray[0].col += 1
                        objectLocationArray[0].row += 1
                        objectLocationArray[2].col -= 1
                        objectLocationArray[2].row -= 1
                        objectLocationArray[3].col += 1
                        objectLocationArray[3].row -= 1
                    //update the cords
                    currentSide = 2
                    }
                case 2:
                    if  twoDarray[objectLocationArray[0].row+1][objectLocationArray[0].col-2] == true ||
                        twoDarray[objectLocationArray[1].row][objectLocationArray[1].col-1] == true ||
                        twoDarray[objectLocationArray[2].row-1][objectLocationArray[2].col] == true ||
                        twoDarray[objectLocationArray[3].row+1][objectLocationArray[3].col] == true{
                    }
                    else{
                        objectLocationArray[0].row += 1
                        objectLocationArray[0].col -= 2
                        objectLocationArray[1].col -= 1
                        objectLocationArray[2].row -= 1
                        objectLocationArray[3].row += 1
                        //update the cords
                        currentSide = 3
                    }
                case 3:
                    if  twoDarray[objectLocationArray[0].row-2][objectLocationArray[0].col] == true ||
                        twoDarray[objectLocationArray[1].row-1][objectLocationArray[1].col+1] == true ||
                        twoDarray[objectLocationArray[2].row][objectLocationArray[2].col+2] == true{
                    }
                    else{
                        objectLocationArray[0].row -= 2
                        objectLocationArray[1].col += 1
                        objectLocationArray[1].row -= 1
                        objectLocationArray[2].col += 2
                        //update the cords
                        currentSide = 0
                    }
                default: print("problems")
                }
            default: print("default")
        }
        print("0 After \(objectLocationArray[0].row) \(objectLocationArray[0].col)")
        print("1 After \(objectLocationArray[1].row) \(objectLocationArray[1].col)")
        print("2 After \(objectLocationArray[2].row) \(objectLocationArray[2].col)")
        print("3 After \(objectLocationArray[3].row) \(objectLocationArray[3].col)")
        
    }
   
    
    
    func whatShapeAmIInit(){
        currentSide = 0 //need to update when rotating
        leftMost = 4 // need to update after shifting or rotating
        if objectLocationArray.isEmpty == false {
            objectLocationArray.removeAll()
        }
        if randoNumber == 0 { //square
            self.objectLocationArray.append(ObjectLocation(row: 0, col: 4))
            self.objectLocationArray.append(ObjectLocation(row: 0, col: 5))
            self.objectLocationArray.append(ObjectLocation(row: 1, col: 4))
            self.objectLocationArray.append(ObjectLocation(row: 1, col: 5))
        }
        if randoNumber == 1 { //Z
            self.objectLocationArray.append(ObjectLocation(row: 0, col: 4))
            self.objectLocationArray.append(ObjectLocation(row: 0, col: 5))
            self.objectLocationArray.append(ObjectLocation(row: 1, col: 5))
            self.objectLocationArray.append(ObjectLocation(row: 1, col: 6))
        }
        if randoNumber == 2 {//J
            self.objectLocationArray.append(ObjectLocation(row: 0, col: 4))
            self.objectLocationArray.append(ObjectLocation(row: 1, col: 4))
            self.objectLocationArray.append(ObjectLocation(row: 1, col: 5))
            self.objectLocationArray.append(ObjectLocation(row: 1, col: 6))
        }
        if randoNumber == 3 {//I
            self.objectLocationArray.append(ObjectLocation(row: 0, col: 4))
            self.objectLocationArray.append(ObjectLocation(row: 0, col: 5))
            self.objectLocationArray.append(ObjectLocation(row: 0, col: 6))
            self.objectLocationArray.append(ObjectLocation(row: 0, col: 7))
        }
        if randoNumber == 4 {//S
            self.objectLocationArray.append(ObjectLocation(row: 0, col: 5))
            self.objectLocationArray.append(ObjectLocation(row: 0, col: 6))
            self.objectLocationArray.append(ObjectLocation(row: 1, col: 4))
            self.objectLocationArray.append(ObjectLocation(row: 1, col: 5))
        }
        if randoNumber == 5 {//L
            self.objectLocationArray.append(ObjectLocation(row: 0, col: 4))
            self.objectLocationArray.append(ObjectLocation(row: 0, col: 5))
            self.objectLocationArray.append(ObjectLocation(row: 0, col: 6))
            self.objectLocationArray.append(ObjectLocation(row: 1, col: 4))
        }
        if randoNumber == 6 {//T looking one
            self.objectLocationArray.append(ObjectLocation(row: 0, col: 4))
            self.objectLocationArray.append(ObjectLocation(row: 0, col: 5))
            self.objectLocationArray.append(ObjectLocation(row: 0, col: 6))
            self.objectLocationArray.append(ObjectLocation(row: 1, col: 5))
        }
    }
    
    func printTruthTwoDArray(){
        for i in twoDarray{
            for j in twoDarray{
            print(i)
            print(j)
            }
        }
    }
    
    func canIMoveLeft() -> Bool{
      if self.twoDarray[objectLocationArray[0].row][objectLocationArray[0].col-1] == true {
           return false
        }
    if self.twoDarray[objectLocationArray[1].row][objectLocationArray[1].col-1] == true {
        return false
        }
    if self.twoDarray[objectLocationArray[2].row][objectLocationArray[2].col-1] == true {
        return false
        }
    if self.twoDarray[objectLocationArray[3].row][objectLocationArray[3].col-1] == true {
            return false
        }
       return true
    }
    
    func canIMoveRight() -> Bool{
        if self.twoDarray[objectLocationArray[0].row][objectLocationArray[0].col+1] == true {
            return false
        }
        if self.twoDarray[objectLocationArray[1].row][objectLocationArray[1].col+1] == true {
            return false
        }
        if self.twoDarray[objectLocationArray[2].row][objectLocationArray[2].col+1] == true {
            return false
        }
        if self.twoDarray[objectLocationArray[3].row][objectLocationArray[3].col+1] == true {
            return false
        }
        return true
    }
    

    
    
 override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func randomShapeGenerator() -> Int{
        let randoNumber = Int(arc4random_uniform(7))
        return randoNumber
    }
    
    func randomColor() -> UIColor{
        let randoNumber = Int(arc4random_uniform(6))
        switch randoNumber{
        case 0:
            tempColor = UIColor.blue
        case 1:
            tempColor = UIColor.red
        case 2:
            tempColor = UIColor.green
        case 3:
            tempColor = UIColor.yellow
        case 4:
            tempColor = UIColor.orange
       case 5:
            tempColor = UIColor.purple
        default:
            tempColor = UIColor.orange
        }
        return tempColor
    }

}
