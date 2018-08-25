//
//  ViewController.swift
//  SetGame
//
//  Created by Юрий Забегаев on 17.08.2018.
//  Copyright © 2018 Юрий Забегаев. All rights reserved.
//

import UIKit


extension ViewController {
    private class ControllerCardsStorage: Sequence, IteratorProtocol {
        
        var count: Int {
            return cards.count
        }
        var iterator = 0
        weak private var cardsHolder: UICardsHolder!
        private(set) var queueToRemove: [UICard] = []
        private(set) var cards:[Card] = []
        private(set) var uiCards:[UICard] = []
        typealias Element = (Card, UICard)
        
        init(cardsHolder: UICardsHolder) {
            self.cardsHolder = cardsHolder
        }
        
        subscript (card: Card) -> UICard? {
            if let index = cards.index(of: card) {
                return uiCards[index]
            }
            return nil
        }
        
        subscript (uiCard: UICard) -> Card? {
            if let index = uiCards.index(of: uiCard) {
                return cards[index]
            }
            return nil
        }
        
        
        func makeIterator() -> ViewController.ControllerCardsStorage {
            iterator = cards.startIndex
            return self
        }
        
        func next() -> (Card, UICard)? {
            if iterator != cards.endIndex {
                let result = (cards[iterator], uiCards[iterator])
                iterator = cards.index(after: iterator)
                return result
            }
            return nil
        }
        
        func add(card: Card, uiCard: UICard) {
            let endIndex = cards.endIndex
            assert(endIndex == uiCards.endIndex)
            
            cards.append(card)
            uiCards.append(uiCard)
        }
        
        func remove(at index:Int) {
            if index >= cards.endIndex {
                return
            }
            cards.remove(at: index)
            let uiCardToRemove = uiCards[index]
            uiCards.remove(at: index)
            cardsHolder.removeCard(uiCardToRemove)
        }
        
        func remove(card: Card) {
            if let index = cards.index(of: card) {
                remove(at: index)
            }
        }
        
        func remove(uiCard: UICard) {
            if let index = uiCards.index(of: uiCard) {
                remove(at: index)
            }
        }
        
        func removeAll() {
            for index in cards.indices.reversed() { remove(at: index) }
            queueToRemove = []
        }
        
        func addCardToRemoveQueue(_ card:UICard) {
            queueToRemove += [card]
        }
        
        func cleanCompletedCards() {
            for uiCard in queueToRemove {
                remove(uiCard: uiCard)
            }
            queueToRemove = []
        }
        
    }
}


class ViewController: UIViewController {

    //MARK: Properties
    private let game = SetGame()
    lazy private var cardsStorage = ControllerCardsStorage(cardsHolder: self.cardsHolder)
    private var lastTimeRotated: Date?
    
    
    //MARK: Outlets
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var cardsHolder: UICardsHolder! {
        didSet {
            let tapOnCard = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapOnCardGesture(_:)))
            cardsHolder.addGestureRecognizer(tapOnCard)
            
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownGesture))
            swipeDown.direction = .down
            cardsHolder.addGestureRecognizer(swipeDown)
        }
    }

    
    //MARK: Gesture handlers
    @IBAction func rotation(_ sender: UIRotationGestureRecognizer) {
        guard !game.isFinished else { return }
        let currentTime = Date()
        if let lastTimeRotated = lastTimeRotated {
            if currentTime.timeIntervalSince(lastTimeRotated) > 2 {
                cardsHolder.shuffleCardsOnScreen()
                self.lastTimeRotated = currentTime
            }
        } else {
            lastTimeRotated = currentTime
        }
    }
    
    @objc func swipeDownGesture() { openThreeMoreCards() }
    
    @objc func tapOnCardGesture(_ gesture: UITapGestureRecognizer) {
        if let uiCard = cardsHolder.getCard(at: gesture.location(in: cardsHolder)) {
            let card = cardsStorage[uiCard]!
            game.chooseCard(card)
            updateGameUI()
        }
    }
    
    
    //MARK: Actions
    @IBAction func giveHint() {
        cardsStorage.cleanCompletedCards()
        updateGameUI()
        if game.setIsFound {
            for card in game.giveAHintSet()! {
                if let uiCard = cardsStorage[card] {
                    cardsHolder.hintCard(uiCard)
                }
            }
        }
        updateScore()
    }
    
    @IBAction func startNewGame() {
        game.startNewGame()
        cardsStorage.removeAll()
        updateGameUI()
    }
    
    
    //MARK: Overrides
    override func viewDidLoad() {
        startNewGame()
    }
    
    
    //MARK: Private Methods
    private func updateGameUI() {
        
        /// if there are cards in a buffer to be hidden, open new cards in place of them
        if !cardsStorage.queueToRemove.isEmpty {
            cardsStorage.cleanCompletedCards()
            game.openThreeNewCards()
        }
        
        /// update cardsKeep by new cards, added to table
        for card in game.cardsOnTable {
            if !(card.state == .isCompleted) {
                updatePosition(ofCard: card)
            }
        }
        
        for (card, uiCard) in cardsStorage {
            switch card.state {
            case .isCompleted:
                /// hide it from UI and remove from cardsOnTable in a next touch
                cardsStorage.addCardToRemoveQueue(uiCard)
                cardsHolder.completeCard(uiCard)
            case .onTable:
                cardsHolder.unchooseCard(uiCard)
            case .isChosen:
                cardsHolder.chooseCard(uiCard)
            default:
                fatalError()
            }
        }
        
        updateScore()
//        view.setNeedsDisplay()
    }
    
    private func updatePosition(ofCard card: Card) {
        var uiCard = cardsStorage[card]
        if uiCard == nil {
            uiCard = UICard(getCardUIData(card))
            cardsStorage.add(card: card, uiCard: uiCard!)
            cardsHolder.addCard(uiCard!)
        }
    }
    
    private func updateScore() {
        score.text = "Score: \(game.score)"
    }
    
    private func openThreeMoreCards() {
        guard !game.isFinished else {
            return
        }
        cardsStorage.cleanCompletedCards()
        game.openThreeNewCards()
        updateGameUI()
    }
}

func getCardUIData(_ card: Card) -> (UICard.Amount, UICard.Symbol,  UICard.Texture, UICard.Color) {
    let color:UICard.Color, amount:UICard.Amount, texture:UICard.Texture, symbol:UICard.Symbol
    switch card.amount {
    case .one:
        amount = .one
    case .two:
        amount = .two
    case .three:
        amount = .three
    }
    switch card.color {
    case .colorA:
        color = .green
    case .colorB:
        color = .purple
    case .colorC:
        color = .red
    }
    switch card.texture {
    case .textureA:
        texture = .filled
    case .textureB:
        texture = .striped
    case .textureC:
        texture = .stroken
    }
    switch card.symbol {
    case .symbolA:
        symbol = .diamonds
    case .symbolB:
        symbol = .oval
    case .symbolC:
        symbol = .squiggles
    }
    
    return (amount, symbol, texture, color)
}
