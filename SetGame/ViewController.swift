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
        private var positionsOfCards = [Bool].init(repeating: false, count: 24)
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
            uiCardToRemove.removeFromSuperview()
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
                if let position = uiCard.position {
                    positionsOfCards[position] = false
                }
            }
            queueToRemove = []
        }
        
        func getCard(at location:CGPoint) -> UICard? {
            for card in uiCards {
                if card.frame.contains(location) { return card }
            }
            return nil
        }
        
        func getCardPosition(of card:UICard) -> Int {
            
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
        
        func shuffleCardsPositions() {
            fatalError("Not implemented")
        }
        
    }
}


class ViewController: UIViewController {

    //MARK: Properties
    private let game = SetGame()
    lazy private var cardsStorage = ControllerCardsStorage(cardsHolder: self.cardsHolder)
    private var lastTimeRotated: Date?
    
    
    //MARK: Outlets
    @IBOutlet weak var deck: UIDeck!
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
                cardsStorage.shuffleCardsPositions()
                self.lastTimeRotated = currentTime
            }
        } else {
            lastTimeRotated = currentTime
        }
    }
    
    @objc func swipeDownGesture() { openThreeMoreCards() }
    
    @objc func tapOnCardGesture(_ gesture: UITapGestureRecognizer) {
        if let uiCard = cardsStorage.getCard(at: gesture.location(in: cardsHolder)) {
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
                    uiCard.state = .hinted
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
        
        /// change the grid if needed
        let notCompletedCardsOnTable = game.cardsOnTable.filter { $0.state != .isCompleted }
        let countOfNotCompletedCardsOnTable = notCompletedCardsOnTable.count
        if !game.haveSetChosen, countOfNotCompletedCardsOnTable != cardsHolder.grid.cellCount {
            cardsHolder.grid.cellCount = countOfNotCompletedCardsOnTable
        }
        
        /// update cardsKeep by new cards, added to table
        for card in notCompletedCardsOnTable {
            updatePosition(ofCard: card)
        }
        
        /// switch state of cards
        for (card, uiCard) in cardsStorage {
            switch card.state {
            case .isCompleted:
                /// hide it from UI and remove from cardsOnTable in a next touch
                cardsStorage.addCardToRemoveQueue(uiCard)
                uiCard.state = .succeeded
            case .onTable:
                uiCard.state = .notChosen
            case .isChosen:
                uiCard.state = .chosen
            default:
                fatalError()
            }
        }
        
        updateScore()
    }
    
    private func updatePosition(ofCard card: Card) {
        var uiCard = cardsStorage[card]
        if uiCard == nil {
            uiCard = UICard(getCardUIData(card), frame: deck.frame)
            cardsStorage.add(card: card, uiCard: uiCard!)
            cardsHolder.addSubview(uiCard!)
        }
        uiCard!.frame = cardsHolder.grid[cardsStorage.getCardPosition(of: uiCard!)]!
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
