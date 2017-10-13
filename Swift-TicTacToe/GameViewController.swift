//
//  GameViewController.swift
//  Swift-TicTacToe
//
//  Created by Lahiru Lakmal on 2016-12-20.
//  Copyright © 2016 SoundofCode. All rights reserved.
//

import UIKit
import Leanplum

class GameViewController: UIViewController {
    
    @IBOutlet weak var gridItemView_0: GridItemView!
    @IBOutlet weak var gridItemView_1: GridItemView!
    @IBOutlet weak var gridItemView_2: GridItemView!
    @IBOutlet weak var gridItemView_3: GridItemView!
    @IBOutlet weak var gridItemView_4: GridItemView!
    @IBOutlet weak var gridItemView_5: GridItemView!
    @IBOutlet weak var gridItemView_6: GridItemView!
    @IBOutlet weak var gridItemView_7: GridItemView!
    @IBOutlet weak var gridItemView_8: GridItemView!
    
    @IBOutlet weak var gameTitleLabel: UILabel!
    @IBOutlet weak var gameStatusLabel: UILabel!
    @IBOutlet weak var gameScoreLabel: UILabel!
    
    var gameTitleLabelValue = LPVar.define("gameTitleLabelValue", with: "Sonic The Hedgehog")
    var backgroundValue = LPVar.define("backgroundValue", with: "sonic.png")
    var backgroundFileValue = LPVar.define("backgroundFileValue", withFile: "sonic.png")
    var sessionDetails = LPVar.define("SessionDetails", with: [
        "PlayerOne": [
            "Name": "user1",
            "Wins": 256,
            "LastWin": ""
        ],
        "PlayerTwo": [
            "Name": "user2",
            "Wins": 512,
            "LastWin": ""
        ]
    ])
    var PlayerOneName = "", PlayerOneWins = 0, PlayerOneLastWin = ""
    var PlayerTwoName = "", PlayerTwoWins = 0, PlayerTwoLastWin = ""
    
    private let statusPlayerText = "Player"
    private let statusActiveText = "Turn"
    private let statusDrawText = "Game Is A Draw!"
    private let statusWonText = "Won!"
    private let gameManager = GameManager()
    private var gridItemsViews = [GridItemView]()
    
    private func setupViews() {
        view.backgroundColor = .white
        
        gridItemsViews = [gridItemView_0, gridItemView_1, gridItemView_2,
                          gridItemView_3, gridItemView_4, gridItemView_5,
                          gridItemView_6, gridItemView_7, gridItemView_8]
        
        for (index, gridItemView) in gridItemsViews.enumerated() {
            gridItemView.index = index
            gridItemView.onViewTap = handleDidTapGridItem
        }
        
        gameManager.onGameStatusUpdate = gameStatusUpdated
        updateGameScoreLabel()
        gameManager.startNewGame()
    }
    
    private func handleDidTapGridItem(gesture: UITapGestureRecognizer) {
        if let itemView = gesture.view as? GridItemView {
            // store the player who made the move
            let currentPlayer = gameManager.currentPlayer
            if gameManager.makeMove(at: itemView.index) {
                itemView.currentPlayer = currentPlayer
            }
        }
    }
    
    private func gameStatusUpdated(_ status: Game.Status) {
        switch status {
        case .Active:
            gameStatusLabel.text = "\(statusPlayerText) \(gameManager.currentPlayer.rawValue) \(statusActiveText)"
        case .Draw:
            gameStatusLabel.text = "\(statusDrawText)"
            updateGameScoreLabel()
        case .Won:
            gameStatusLabel.text = "\(statusPlayerText) \(gameManager.currentPlayer.rawValue) \(statusWonText)"
            updateGameScoreLabel()
        }
    }
    
    func updateGameScoreLabel() {
        let gameSession = gameManager.session
        let playerXScore = gameSession.wins[Game.Player.X] ?? 0
        let playerOScore = gameSession.wins[Game.Player.O] ?? 0
        let ties = gameSession.draws
        
        Leanplum.track("Games", withValue: Double(playerXScore + playerOScore + ties))
        
        gameScoreLabel.text = "\(Game.Player.X): \(playerXScore)    \(Game.Player.O): \(playerOScore)   \("TIES"): \(ties)"
        
        //let stringFromDate = Date().iso8601
        
        Leanplum.onVariablesChanged {
            self.PlayerOneName = (self.sessionDetails?.object(forKey: "PlayerOne") as AnyObject).object(forKey: "Name") as! String
            self.PlayerOneWins = ((self.sessionDetails?.object(forKey: "PlayerOne") as AnyObject).object(forKey: "Wins") as! NSNumber).intValue
            self.PlayerOneLastWin = (self.sessionDetails?.object(forKey: "PlayerOne") as AnyObject).object(forKey: "LastWin") as! String
            self.PlayerTwoName = (self.sessionDetails?.object(forKey: "PlayerTwo") as AnyObject).object(forKey: "Name") as! String
            self.PlayerTwoWins = ((self.sessionDetails?.object(forKey: "PlayerTwo") as AnyObject).object(forKey: "Wins") as! NSNumber).intValue
            self.PlayerTwoLastWin = (self.sessionDetails?.object(forKey: "PlayerTwo") as AnyObject).object(forKey: "LastWin") as! String
        }
        
        print("Here are the values PART 1", PlayerOneName, PlayerOneWins, PlayerOneLastWin)
        print("Here are the values PART 2", PlayerTwoName, PlayerTwoWins, PlayerTwoLastWin)
    }
    
    @IBAction func newGameButtonPressed(_ sender: Any) {
        gameManager.startNewGame()
        _ = gridItemsViews.map { $0.reset() }
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        Leanplum.setUserId("MarkI");
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        gameManager.startNewGame()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
        
        
        Leanplum.onVariablesChanged {
            self.gameTitleLabel.text = self.gameTitleLabelValue?.stringValue()
            
            if (self.backgroundValue?.stringValue() != "sonic.png") {
                backgroundImage.image = UIImage(named: (self.backgroundValue?.stringValue())!)
            } else {
                backgroundImage.image = self.backgroundFileValue?.imageValue()
            }
        }
        
        backgroundImage.contentMode = UIViewContentMode.scaleAspectFill
        self.view.insertSubview(backgroundImage, at: 0)
        
        setupViews()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
}

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}

extension Date {
    var iso8601: String {
        return Formatter.iso8601.string(from: self)
    }
}
