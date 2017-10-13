//
//  GameModel.swift
//  Swift-TicTacToe
//
//  Created by Lahiru Lakmal on 2016-12-22.
//  Copyright © 2016 SoundofCode. All rights reserved.
//

import UIKit

struct Game {
    struct Board {
        static let Size = 3
    }
    
    enum GridItem {
        case Free
        case Locked
    }
    
    enum Player : String {
        case X = "X"
        case O = "O"
        case E = "E"
        
        func spriteName() -> String {
            return self.rawValue
        }
        
        func flip() -> Player {
            switch self {
            case .O:
                return .X
            case .X:
                return .O
            default:
                return .E
            }
        }
    }
    
    enum Status {
        case Active
        case Won
        case Draw
    }
}

class GridItem {
    
    var status = Game.GridItem.Free
    var ownedPlayer = Game.Player.E
    
    func reset() {
        status = Game.GridItem.Free
    }
}

class GameBoard {
    
    private let gridItems: [GridItem] = {
        var items = [GridItem]()
        let boardSize = Game.Board.Size * Game.Board.Size
        for _ in 0..<boardSize {
            items.append(GridItem())
        }
        return items
    }()
    
    // maps 2D grid position to linear position
    //
    func get1DPosition(from point:(x: Int, y: Int)) -> Int {
        return point.x + Game.Board.Size * point.y;
    }
    
    // maps linear position to 2D grid position
    //
    func get2DPosition(from index: Int) -> (x: Int, y: Int) {
        let x = index % Game.Board.Size;
        let y = index / Game.Board.Size;
        return (x, y)
    }
    
    func reset() {
        for gridItem in gridItems {
            gridItem.reset()
        }
    }
    
    // mark grid item locked, if a valid move is made with 2D position
    //
    func markGridItem(at pos:(x: Int, y: Int), with player: Game.Player) -> Bool {
        let index = get1DPosition(from: pos)
        return markGridItem(at: index, with: player)
    }
    
    // mark grid item locked, if a valid move is made with 1D index
    //
    func markGridItem(at index: Int, with player: Game.Player) -> Bool {
        let gridItem = gridItems[index]
        
        if gridItem.status == Game.GridItem.Locked {
            return false
        }
        
        gridItem.status = Game.GridItem.Locked
        gridItem.ownedPlayer = player
        
        return true
    }
}

class GameSession {
    
    var wins = [Game.Player.O: 0, Game.Player.X: 0]
    var draws = 0
}

class Score {
    
    var matrix = Array(repeating: Array(repeating: Int(0), count: 3), count: 3)

    func reset () {
        for row in 0...Game.Board.Size - 1 {
            for col in 0...Game.Board.Size - 1 {
                matrix[row][col] = 0
            }
        }
    }
}
