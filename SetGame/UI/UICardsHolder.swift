//
//  CardsHolder.swift
//  SetGame
//
//  Created by Юрий Забегаев on 20.08.2018.
//  Copyright © 2018 Юрий Забегаев. All rights reserved.
//

import UIKit


@IBDesignable
class UICardsHolder: UIView {

    private var grid: Grid!
    private var cards:[UICard] = [] {
        didSet {
            grid.cellCount = cards.count
        }
    }
    private var positionsOfCards = [Bool].init(repeating: false, count: 24)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setProps()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setProps()
    }
    
    
    func removeCard(_ card:UICard) {
        if let index = cards.index(of: card) {
            positionsOfCards[card.position!] = false
            cards.remove(at: index)
            card.removeFromSuperview()
            setNeedsDisplay()
        }
    }
    
    func chooseCard(_ card:UICard) {
        card.state = .chosen
    }
    
    func unchooseCard(_ card:UICard) {
        card.state = .notChosen
    }
    
    func completeCard(_ card:UICard) {
        card.state = .succeeded
    }
    
    func hintCard(_ card:UICard) {
        card.state = .hinted
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
    
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.6,
            delay: 0, options: [.curveEaseInOut],
            animations: { [unowned self] in
                for card in self.cards {
                    let index = self.getCardPosition(of: card)
                    card.frame = self.grid[index]!
                }
        })
    }
    
    
    private func setProps() {
        grid = Grid(layout: .aspectRatio(3/4), frame: bounds)
        isOpaque = false
        backgroundColor = .clear
    }
    
    private func getCardPosition(of card:UICard) -> Int {
        
        // Card has position
        if let position = card.position {
            return position
        }
        
        // There is an empty position in array of positions
        if let firstEmptyIndex = positionsOfCards.index(of: false) {
            positionsOfCards[firstEmptyIndex] = true
            card.position = firstEmptyIndex
            return firstEmptyIndex
        }
        
        // No empty positions => allocate new space in array
        positionsOfCards.append(false)
        card.position = positionsOfCards.endIndex - 1
        return card.position!
    }
    
}
