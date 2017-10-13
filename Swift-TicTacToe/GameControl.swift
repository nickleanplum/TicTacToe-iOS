//
//  GameControl.swift
//  Swift-TicTacToe
//
//  Created by Lahiru Lakmal on 2016-12-26.
//  Copyright © 2016 SoundofCode. All rights reserved.
//
import Leanplum

class ScoreManager {
    
    private var markedCount = 0 // counter to determine if the game is a draw
    private var currentMatrixValues = [Game.Player.O: Score(), Game.Player.X: Score()]
    
    // check if the current move is a winning move
    //
    func isWinningMove(player: Game.Player, position pos: (x: Int, y: Int), lastWin: Int, callback: (Int) -> Void) -> Game.Status {
        markedCount += 1

        if checkWins(in: currentMatrixValues[player] ?? Score(), pos: pos, lastWin: lastWin, callback: callback) {
            return Game.Status.Won
        }
        
        // check if the game is a draw
        if markedCount >= 9 {
            return Game.Status.Draw
        }
        
        return Game.Status.Active
    }
    
    // reset scores
    //
    func reset() {
        markedCount = 0
        currentMatrixValues[Game.Player.O]?.reset()
        currentMatrixValues[Game.Player.X]?.reset()
    }
    
    // check horizontal, vertical, and diagonal wins
    //
    private func checkWins(in score: Score, pos:(x: Int, y: Int), lastWin: Int, callback:(Int) -> Void) -> Bool {
        score.matrix[pos.x][pos.y] = 1
        var countWinsRow = 0
        var countWinsCol = 0
        var countWinsDigMaj = 0
        var countWinsDigMin = 0
        
        var countRow = 0
        var countCol = 0
        var countDiaMaj = 0
        var countDiaMin = 0
        
        for row in 0...Game.Board.Size - 1 {
            countRow = 0
            countCol = 0
            
            for col in 0...Game.Board.Size - 1 {
                if (score.matrix[col][row] == 1) {
                    countRow += 1
                }
                if (score.matrix[row][col] == 1) {
                    countCol += 1
                }
                if (row == col && score.matrix[row][col] == 1) {
                    countDiaMaj += 1
                }
            }
            if countRow == 3 { countWinsRow += 1 }
            if countCol == 3 { countWinsCol += 1 }
            
            if Game.Board.Size - 1 - row >= 0 {
                if(score.matrix[row][Game.Board.Size - 1 - row] == 1) {
                    countDiaMin += 1
                }
            }
        }
        
        if countDiaMaj == 3 { countWinsDigMaj += 1 }
        if countDiaMin == 3 { countWinsDigMin += 1 }
        let totalWinCount = countWinsRow + countWinsCol + countWinsDigMaj + countWinsDigMin
        print("countWinsRow", countWinsRow, "countWinsCol", countWinsCol, "countWinsDigMaj", countWinsDigMaj, "countWinsDigMin", countWinsDigMin)
        
        if totalWinCount - lastWin == 1 {
            callback(totalWinCount)
            return true;
        }
        
        return false
    }

}

class GameManager {

    private let gameBoard = GameBoard()
    private let scoreManager = ScoreManager()
    private var gameStatus = Game.Status.Active
    private var winList = [Game.Player.O:[0,0], Game.Player.X:[0,0]]
    private(set) public var currentPlayer = Game.Player.O
    private(set) public var session = GameSession()
    
    // callback function for game status updates
    //
    var onGameStatusUpdate: (Game.Status)->() = { status in
        print(status)
    }
    
    func startNewGame() {
        winList[Game.Player.O] = [0,0]
        winList[Game.Player.X] = [0,0]
        gameBoard.reset()
        scoreManager.reset()
        currentPlayer = currentPlayer.flip()
        gameStatus = Game.Status.Active
        onGameStatusUpdate(gameStatus)
    }
    
    // returns true if it is a valid move
    //
    func makeMove(at index: Int) -> Bool {
        
        guard gameStatus == .Active else {
            return false
        }
        
        if gameBoard.markGridItem(at: index, with: currentPlayer) {
            
            // convert linear index to 2D grid position
            let position = gameBoard.get2DPosition(from: index)
            
            func callback(_ count: Int) -> Void {
                print("COUNT IN CALLBACK", count)
                winList[currentPlayer]![1] = count
            }
            
            let lastWin = Int(winList[currentPlayer]![1])
            gameStatus = scoreManager.isWinningMove(player: currentPlayer, position: position, lastWin: lastWin, callback: callback)
            print("GAME STATUS: ", gameStatus)
            print("Game.Player.O...", winList[Game.Player.O]![0], ",", winList[Game.Player.O]![1])
            print("Game.Player.X...", winList[Game.Player.X]![0], ",", winList[Game.Player.X]![1])
            
            if gameStatus == Game.Status.Won {
                winList[currentPlayer]![0] = winList[currentPlayer]![1]
                Leanplum.track("win", withParameters:["player":currentPlayer.rawValue])
                
                session.wins[currentPlayer] = winList[currentPlayer]![1]
                onGameStatusUpdate(gameStatus)
                
                if winList[Game.Player.O]![1] == winList[Game.Player.X]![1] {
                    gameStatus = Game.Status.Won
                } else {
                    gameStatus = Game.Status.Active
                }
                
            }
            if gameStatus == Game.Status.Draw {
                session.draws += 1
            }
            if gameStatus == Game.Status.Active {
                currentPlayer = currentPlayer.flip()
                
            }
            
            onGameStatusUpdate(gameStatus)
            return true
        }
        
        return false
    }
}
