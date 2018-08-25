//
//  SetGame.swift
//  SetGame
//
//  Created by Юрий Забегаев on 20.08.2018.
//  Copyright © 2018 Юрий Забегаев. All rights reserved.
//

import Foundation


class Card : Hashable {
    
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    enum CardState {
        case inDeck
        case onTable
        case isChosen
        case isCompleted
    }
    
    var state: CardState = .inDeck {
        willSet {
            switch newValue {
            case .onTable:
                Card.cardWillAppearOnTable(self)
            case .isChosen:
                Card.cardWillBecomeChosen(self)
            case .isCompleted:
                Card.cardWillBecomeCompleten(self)
            default:
                fatalError()
            }
        }
    }
    
    static var cardWillAppearOnTable: ((Card) -> ())!
    static var cardWillBecomeChosen: ((Card) -> ())!
    static var cardWillBecomeCompleten: ((Card) -> ())!
    
    let symbol:Symbol
    let amount:SymbolsAmount
    let texture:SymbolsTexture
    let color:SymbolsColor
    
    let hashValue: Int
    
    init(symbol: Symbol,
         amount : SymbolsAmount,
         texture:SymbolsTexture,
         color: SymbolsColor) {
        self.symbol = symbol
        self.amount = amount
        self.texture = texture
        self.color = color
        hashValue = self.symbol.rawValue + self.amount.rawValue*3 + self.texture.rawValue*9 + self.color.rawValue*27
    }
}


class SetGame {
    
    private class CardKeep {
        
        private(set) var deck: [Card] = []
        private(set) var table = Set<Card>()
        private(set) var chosenCards: [Card] = []
        private(set) var competeCards: [Card] = []
        var game :SetGame!
        
        init() {
            Card.cardWillBecomeChosen = { [unowned self] card in
                guard card.state == .onTable else {
                    fatalError()
                }
                self.chosenCards += [card]
            }
            
            Card.cardWillAppearOnTable = { [unowned self] card in
                guard card.state == .inDeck || card.state == .isChosen else {
                    fatalError()
                }
                
                if let index = self.chosenCards.index(of: card) {
                    self.chosenCards.remove(at: index)
                }
                self.table.insert(card)
            }
            
            Card.cardWillBecomeCompleten = { [unowned self] card in
                guard card.state == .isChosen || card.state == .onTable else {
                    fatalError()
                }
                if let index = self.chosenCards.index(of: card) {
                    self.chosenCards.remove(at: index)
                }
            }
        }
        
        func reset() {
            deck = []
            table = []
            chosenCards = []
            competeCards = []
            for symbol in Symbol.all() {
                for amount in SymbolsAmount.all() {
                    for texture in SymbolsTexture.all() {
                        for color in SymbolsColor.all() {
                            deck += [Card(symbol: symbol, amount: amount, texture: texture, color: color)]
                        }
                    }
                }
            }
            deck.shuffle()
        }
        
        func openNewCards(amount: Int) {
            var cardsToOpen = amount
            assert(amount > 0)
            if deck.count < amount {
                cardsToOpen = deck.count
            }
            for _ in 0..<cardsToOpen {
                if let newCard = deck.popLast() {
                    newCard.state = .onTable
                }
            }
            if deck.count == 0 {
                game.isFinished = true
            }
        }
        
        func emptyChosenCards() {
            for card in chosenCards {
                card.state = .onTable
            }
        }
    }

    init() {
        cardKeep = CardKeep()
        cardKeep.game = self
    }
    
    private let cardKeep: CardKeep
    private var foundSet: [Card] = []
    var cardsOnTable: Set<Card> {
        return cardKeep.table
    }
    var score: Int = 0 {
        didSet {
            score = score < 0 ? 0 : score
        }
    }
    var isFinished = false
    var setIsFound:Bool {
        return foundSet.count > 0
    }
    
    func startNewGame() {
        score = 0
        cardKeep.reset()
        cardKeep.openNewCards(amount: 12)
        isFinished = false
        findSet()
    }
    
    func chooseCard(_ card: Card) {
        assert(card.state != .inDeck)
        guard cardKeep.chosenCards.count <= 3 else { return }
        
        if cardKeep.chosenCards.count == 3 {
            cardKeep.emptyChosenCards()
        }
        
        switch card.state {
        case .onTable:
            card.state = .isChosen
        case .isChosen:
            card.state = .onTable
            score -= 1
        case .isCompleted:
            ()
        default:
            fatalError()
        }
        
        if cardKeep.chosenCards.count == 3 {
            handleThreeOpenCardsSituation()
        }
        
        findSet()
    }
    
    func openThreeNewCards() {
        cardKeep.openNewCards(amount: 3)
        
        findSet()
    }
    
    func giveAHintSet() -> [Card]? {
        score -= 10
        if setIsFound {
            return foundSet
        }
        return nil
    }
    
    private func handleThreeOpenCardsSituation() {
        assert(cardKeep.chosenCards.count == 3)
        
        if eachOfThreeCardsOrNoneIsEqual(cardKeep.chosenCards[0], cardKeep.chosenCards[1], cardKeep.chosenCards[2]) {
            for card in cardKeep.chosenCards {
                card.state = .isCompleted
            }
            score += 3
        } else {
            score -= 5
        }
    }
    
    private var eachOfThreeCardsOrNoneIsEqual: (Card, Card, Card) -> Bool = {
        Int.eachOfThreeOrNoneIsEqual($0.amount.rawValue, $1.amount.rawValue, $2.amount.rawValue) &&
            Int.eachOfThreeOrNoneIsEqual($0.symbol.rawValue, $1.symbol.rawValue, $2.symbol.rawValue) &&
            Int.eachOfThreeOrNoneIsEqual($0.texture.rawValue, $1.texture.rawValue, $2.texture.rawValue) &&
            Int.eachOfThreeOrNoneIsEqual($0.color.rawValue, $1.color.rawValue, $2.color.rawValue)
    }
    
    private func findSet() {
        let shuffledCards = cardKeep.table.filter {$0.state != .isCompleted}.shuffled()
        foundSet = []
        for indexA in shuffledCards.indices {
            for indexB in shuffledCards.indices {
                for indexC in shuffledCards.indices {
                    if indexA != indexB && indexB != indexC && indexC != indexA {
                        let (cardA, cardB, cardC) = (shuffledCards[indexA], shuffledCards[indexB], shuffledCards[indexC])
                        if eachOfThreeCardsOrNoneIsEqual(cardA, cardB, cardC) {
                            foundSet = [cardA, cardB, cardC]
                            return
                        }
                    }
                }
            }
        }
        if foundSet.isEmpty && cardKeep.deck.isEmpty {
            isFinished = true
        }
    }
    
}
