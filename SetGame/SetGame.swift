//
//  SetGame.swift
//  SetGame
//
//  Created by Юрий Забегаев on 17.08.2018.
//  Copyright © 2018 Юрий Забегаев. All rights reserved.
//

import Foundation


class Card : Hashable {
    static func == (lhs: Card, rhs: Card) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
    
    var isCompleted = false
    var isChosen : Bool {
        return Card.checkIfChosen(self)
    }
    static var checkIfChosen : ((Card) -> Bool)!
    
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
    private var deck: [Card] = []
    var amountOfCardsInDeck: Int {
        return deck.count
    }
    private(set) var score = 0 {
        didSet {
            score = score < 0 ? 0 : score
        }
    }
    
    private(set) var cardsOnTable = Set<Card>()
    private(set) var chosenCardsOnTable: [Card] = []
    private var foundSet:[Card] = []
    var setIsFound:Bool {
        return foundSet.count > 0
    }
    private(set) var gameIsFinished = false

    init() {
        Card.checkIfChosen = { [unowned self] cardToCheck in
            return !self.chosenCardsOnTable.filter {$0 == cardToCheck}.isEmpty
        }
    }
    
    func startNewGame() {
        score = 0
        deck = []
        cardsOnTable = []
        chosenCardsOnTable = []
        for symbolIndex in 0..<3 {
            for amountIndex in 0..<3 {
                for textureIndex in 0..<3 {
                    for colorIndex in 0..<3 {
                        deck += [Card(symbol: Symbol.init(rawValue: symbolIndex)!,
                                     amount: SymbolsAmount.init(rawValue: amountIndex)!,
                                     texture: SymbolsTexture.init(rawValue: textureIndex)!,
                                     color: SymbolsColor.init(rawValue: colorIndex)!)]
                    }
                }
            }
        }
        deck.shuffle()
        openNewCards(amount: 12)
        gameIsFinished = false
    }
    
    func openThreeNewCards() {
        openNewCards(amount: 3)
    }
    
    func chooseCard(_ card: Card) {
        assert(cardsOnTable.contains {
            $0 == card
        })
        guard chosenCardsOnTable.count <= 3 else { return }
        if card.isChosen {
            if chosenCardsOnTable.count < 3 {
                chosenCardsOnTable.remove(at: chosenCardsOnTable.index(of: card)!)
                score -= 1
            }
            return
        }
        if chosenCardsOnTable.count == 3 {
            chosenCardsOnTable = []
        }
        
        chosenCardsOnTable += [card]
        if chosenCardsOnTable.count == 3 {
            handleThreeOpenCardsSituation()
        }
        
        findSet()
    }
    
    func giveAHintSet() -> [Card]? {
        score -= 10
        if setIsFound {
            return foundSet
        }
        return nil
    }
    
    private func openNewCards(amount : Int) {
        assert(amount > 0)
        
        for _ in 1...amount {
            if let newCard = deck.popLast() {
                cardsOnTable.insert(newCard)
            } else {
                // no cards left on deck
                gameIsFinished = true
            }
        }
        findSet()
    }
    
    private func handleThreeOpenCardsSituation() {
        assert(chosenCardsOnTable.count == 3)

        if eachOfThreeCardsOrNoneIsEqual(chosenCardsOnTable[0], chosenCardsOnTable[1], chosenCardsOnTable[2]) {
            for (_, card) in chosenCardsOnTable.enumerated() {
                card.isCompleted = true
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
        let shuffledCards = Array(cardsOnTable).shuffled()
        foundSet = []
        for indexA in shuffledCards.indices {
            for indexB in shuffledCards.indices {
                for indexC in shuffledCards.indices {
                    if indexA != indexB && indexB != indexC && indexC != indexA {
                        let (cardA, cardB, cardC) = (shuffledCards[indexA], shuffledCards[indexB], shuffledCards[indexC])
                        if cardA.isCompleted || cardB.isCompleted || cardC.isCompleted {
                            continue
                        }
                        if eachOfThreeCardsOrNoneIsEqual(cardA, cardB, cardC) {
                            foundSet = [cardA, cardB, cardC]
                            break
                        }
                    }
                }
            }
        }
    }
    
}
