//
//  GameView.swift
//  Swift-TicTacToe
//
//  Created by Lahiru Lakmal on 2016-12-26.
//  Copyright © 2016 SoundofCode. All rights reserved.
//

import UIKit

// Visible grid item
//
class GridItemView: UIView {
    
    var index = 0
    var currentPlayer: Game.Player = Game.Player.E {
        didSet {
            imageView.image = UIImage(named: currentPlayer.rawValue)
        }
    }
    
    private let imageView: UIImageView = {
        let image = UIImageView(image: UIImage(named: Game.Player.E.rawValue))
        image.contentMode = .scaleAspectFit
        image.backgroundColor = .yellow
        image.isUserInteractionEnabled = true
        return image
    }()
    
    override init(frame : CGRect) {
        super.init(frame : frame)
        initializeView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeView()
    }
    
    private func initializeView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewDidTap))
        addGestureRecognizer(tapGestureRecognizer)
        
        layer.borderWidth = 1
        layer.borderColor = UIColor.black.cgColor
        backgroundColor = .white
        
        addSubview(imageView)
        
        addConstraintsWithFormat(format: "H:|[v0]|", views: imageView)
        addConstraintsWithFormat(format: "V:|[v0]|", views: imageView)
    }
    
    @objc private func viewDidTap(gesture: UITapGestureRecognizer) {
        onViewTap(gesture)
    }
    
    // callback for ontap (instead of a delegate method)
    //
    var onViewTap: (UITapGestureRecognizer)->() = { gesture in
        debugPrint("onViewTap")
    }
    
    func reset() {
        currentPlayer = Game.Player.E
    }
}

// extension to UIView addConstraints
// makes it easier to use visual format language on new views
//
extension UIView {
    
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for(index, view) in views.enumerated() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}
