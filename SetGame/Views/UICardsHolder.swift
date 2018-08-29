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

    var grid: Grid!
//    private var cards:[UICard] = [] {
//        didSet {
//            grid.cellCount = cards.count
//        }
//    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setProps()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setProps()
    }
    
    
//    func removeCard(_ card:UICard) {
//        UIViewPropertyAnimator.runningPropertyAnimator(
//            withDuration: 0.6,
//            delay: 0,
//            options: [.curveEaseInOut],
//            animations: {
//                card.frame = CGRect(
//                    origin: CGPoint(x: -card.bounds.width,
//                                    y: -card.bounds.height),
//                    size: card.bounds.size)
//                self.positionsOfCards[card.position!] = false
//                self.cards.remove(at: self.cards.index(of: card)!)
//        }) { position in
//            card.removeFromSuperview()
//        }
//    }
//
//    func chooseCard(_ card:UICard) {
//        card.state = .chosen
//    }
//
//    func unchooseCard(_ card:UICard) {
//        card.state = .notChosen
//    }
//
//    func completeCard(_ card:UICard) {
//        card.state = .succeeded
//    }
//
//    func hintCard(_ card:UICard) {
//        card.state = .hinted
//    }
    
//    func addCards(_ newCards:[UICard]) {
//        cards += newCards
//    }

//    func addCard(_ card: UICard) {
//        cards += [card]
//        self.addSubview(card)
//        setNeedsDisplay()
//    }

//    func shuffleCardsOnScreen() {
//        cards.shuffle()
//        setNeedsDisplay()
//    }
    
//    func getCard(at location:CGPoint) -> UICard? {
//        for card in cards {
//            if card.frame.contains(location) { return card }
//        }
//        return nil
//    }
    

//    override func draw(_ rect: CGRect) {
//        grid.frame = bounds
//        for card in self.cards {
//            let index = self.getCardPosition(of: card)
//            card.frame = self.grid[index]!
//        }
//    }
    
    
    private func setProps() {
        grid = Grid(layout: .aspectRatio(3/4), frame: bounds)
        isOpaque = false
        backgroundColor = .clear
    }
    
}
