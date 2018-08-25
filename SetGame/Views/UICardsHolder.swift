//
//  CardsHolder.swift
//  SetGame
//
//  Created by Юрий Забегаев on 20.08.2018.
//  Copyright © 2018 Юрий Забегаев. All rights reserved.
//

import UIKit


class UICardsHolder: UIView {

    private var grid: Grid!
    private var cards:[UICard] = [] {
        didSet {
            grid.cellCount = cards.count
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        grid = Grid(layout: .aspectRatio(3/4), frame: bounds)
        isOpaque = false
        backgroundColor = .clear
    }
    
    
    func removeCard(_ card:UICard) {
        if let index = cards.index(of: card) {  
            cards.remove(at: index)
            card.removeFromSuperview()
            setNeedsDisplay()
        }
    }
    
    func chooseCard(_ card:UICard) {
        card.state = .chosen
        card.setNeedsDisplay()
    }
    
    func unchooseCard(_ card:UICard) {
        card.state = .notChosen
        card.setNeedsDisplay()
    }
    
    func completeCard(_ card:UICard) {
        card.state = .succeeded
        card.setNeedsDisplay()
    }
    
    func hintCard(_ card:UICard) {
        card.state = .hinted
        card.setNeedsDisplay()
    }

    func addCard(_ card: UICard) {
        cards += [card]
        self.addSubview(card)
        setNeedsDisplay()
    }

    func shuffleCardsOnScreen() {
        cards.shuffle()
        setNeedsDisplay()
    }
    
    func getCard(at location:CGPoint) -> UICard? {
        for card in cards {
            if card.frame.contains(location) { return card }
        }
        return nil
    }
    

    override func draw(_ rect: CGRect) {
        grid.frame = bounds
    
        for (index, card) in cards.enumerated() {
            card.frame = grid[index]!
        }
    }
    
}
