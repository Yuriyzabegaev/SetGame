//
//  UIDeck.swift
//  SetGame
//
//  Created by Юрий Забегаев on 26.08.2018.
//  Copyright © 2018 Юрий Забегаев. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable
class UIDeck: UIView {
    
    var cardsInDeck: Int = 0 {
        didSet {
            if cardInDeckLabel != nil {
                cardInDeckLabel.text = String(cardsInDeck)
            }
        }
    }
    
    private var cardInDeckLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupProps()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupProps()
    }
    
    private func setupProps() {
        isOpaque = false
        backgroundColor = .clear
        contentMode = .redraw
        cardInDeckLabel = UILabel()
        cardInDeckLabel.textAlignment = .center
        self.addSubview(cardInDeckLabel)
    }
    
    override func draw(_ rect: CGRect) {
        let cornerRadius = self.cornerRadius
        let roundedRect = UIBezierPath(roundedRect: bounds,
                                       byRoundingCorners: [.topLeft, .topRight],
                                       cornerRadii: CGSize(width: cornerRadius,
                                                           height: cornerRadius))
        UIColor.white.setFill()
        roundedRect.fill()
        
        cardInDeckLabel.frame = self.bounds
    }
    
    private var cornerRadius: CGFloat {
        return bounds.width * AspectRatio.cornerRadiusToWidth
    }
    
    private struct AspectRatio {
        static var cornerRadiusToWidth:CGFloat = 0.1
    }
    
}
