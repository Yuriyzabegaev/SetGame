//
//  ViewController.swift
//  SetGame
//
//  Created by Юрий Забегаев on 17.08.2018.
//  Copyright © 2018 Юрий Забегаев. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let game = SetGame()
    let maxCardsOnTable = 24
//    var positionsOfCardsOnTable: [Card:Int] = [:]
    lazy var cardsOnTable = [Card?](repeating: nil, count: maxCardsOnTable)
    var uiCardsToBeHiddenInANextTouch : [Int:UIButton] = [:]
    
    var __tagFactory: Int = 0
    var tagFactory: Int {
        get {
            let result = __tagFactory
            __tagFactory += 1
            return result
        }
        set {
            __tagFactory = newValue
        }
    }
    
    @IBAction func startNewGame() {
        game.startNewGame()
        cardsOnTable = [Card?](repeating: nil, count: maxCardsOnTable)
        uiCardsToBeHiddenInANextTouch = [:]
        tagFactory = 0
        applyToEachCard { uiCard in
            uiCard.isHidden = true
            uiCard.tag = tagFactory
            uiCard.layer.cornerRadius = 8.0
            uiCard.layer.borderWidth = 2.0
            uiCard.layer.borderColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
            uiCard.setTitle("", for: .normal)
        }
        updateGameUI()
    }
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var cardsHolder: UIStackView!
    @IBAction func cardTouched(_ sender: UIButton) {
        game.chooseCard(cardsOnTable[sender.tag]!)
        updateGameUI()
    }
    
    @IBAction func giveHint() {
        cleanCompletedCards()
        updateGameUI()
        if game.setIsFound {
            for card in game.giveAHintSet()! {
                applyToOneCard(card) { uiCard in
                    uiCard.backgroundColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
                }
            }
        }
        updateScore()
    }
    
    @IBOutlet weak var openCardsButton: UIButton!
    @IBAction func openThreeMoreCards(_ sender: UIButton) {
        assert(cardsOnTable.compactMap { $0 }.count <= maxCardsOnTable - 3, "ViewController.openThreeMoreCards(_ sender: UIButton) --- more then \(maxCardsOnTable - 3) is already open")
        if !uiCardsToBeHiddenInANextTouch.isEmpty {
            cleanCompletedCards()
        }
        game.openThreeNewCards()
        updateGameUI()
    }
    
    override func viewDidLoad() {
        startNewGame()
    }
    
    private func updateGameUI() {
        let shouldOpenNewCards = !uiCardsToBeHiddenInANextTouch.isEmpty
        cleanCompletedCards()
        if shouldOpenNewCards {
            game.openThreeNewCards()
        }
        
        for card in game.cardsOnTable {
            if !card.isCompleted {
                cardsOnTable[getPosition(ofCard: card)] = card
            }
        }
        for index in cardsOnTable.indices {
            if let card = cardsOnTable[index] {
                if card.isCompleted {
                    /// hide it from UI and remove from cardsOnTable in a next touch
                    applyToOneCard(card) { uiCard in
                        uiCardsToBeHiddenInANextTouch.updateValue(uiCard, forKey: index)
                    }
                }
                /// redraw
                applyToOneCard(card) { uiCard in
                    uiCard.isHidden = false
                    uiCard.setAttributedTitle(UISymbol.getSymbol(fromCard: card), for: .normal)
                    if card.isChosen {
                        if card.isCompleted {
                            uiCard.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
                        } else {
                            uiCard.backgroundColor = #colorLiteral(red: 0.9568627477, green: 0.6588235497, blue: 0.5450980663, alpha: 1)
                        }
                    } else {
                        uiCard.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
                    }
                }
            }
        }
        updateScore()
        openCardsButton.isHidden = cardsOnTable.compactMap { $0 }.count > maxCardsOnTable - 3 ||
            game.amountOfCardsInDeck < 3
    }
    
    private func getPosition(ofCard card: Card) -> Int {
        var position = cardsOnTable.index(of: card)
        if position == nil {
            position = cardsOnTable.index(of: nil)
            guard position != nil else {
                fatalError("ViewController.updateGameUI() --- no empty position found")
            }
            cardsOnTable[position!] = card
        }
        return position!
    }
    
    private func applyToEachCard(_ toApply :(UIButton)->()) {
        for cardsRow in cardsHolder.arrangedSubviews as! [UIStackView] {
            for card in cardsRow.arrangedSubviews as! [UIButton] {
                toApply(card)
            }
        }
    }
    
    private func applyToOneCard(_ card:Card, action:(UIButton)->()) {
        let position = getPosition(ofCard: card)
        let row = cardsHolder.arrangedSubviews[position/4] as! UIStackView
        let card = row.arrangedSubviews[position%4] as! UIButton
        action(card)
    }
    
    private func cleanCompletedCards() {
        for (index, uiCard) in uiCardsToBeHiddenInANextTouch {
            uiCard.isHidden = true
            cardsOnTable[index] = nil
            uiCardsToBeHiddenInANextTouch.removeValue(forKey: index)
        }
    }
    
    private func updateScore() {
        score.text = "Score: \(game.score)"
    }
}


enum UISymbol: String {
    case a = "▲"
    case b = "●"
    case c = "■"
    
    static func getSymbol(fromCard card:Card) -> NSAttributedString {
        var string:String
        var attributes : [NSAttributedStringKey : Any] = [:]
        switch card.symbol {
        case .symbolA:
            string = UISymbol.a.rawValue
        case .symbolB:
            string = UISymbol.b.rawValue
        case .symbolC:
            string = UISymbol.c.rawValue
        }
        switch card.amount {
        case .one:
            ()
        case .two:
            string+=string
        case .three:
            string+=string+string
        }
        switch card.color {
        case .colorA:
            attributes[.foregroundColor] = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        case .colorB:
            attributes[.foregroundColor] = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
            attributes[.strokeColor] = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case .colorC:
            attributes[.foregroundColor] = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
            attributes[.strokeColor] = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
        switch card.texture {
        case .textureA:
            attributes[.strokeWidth] = -7
            attributes[.strokeColor] = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        case .textureB:
            attributes[.strokeWidth] = 0
        case .textureC:
            attributes[.strokeWidth] = -8
            attributes[.strokeColor] = #colorLiteral(red: 0.7254902124, green: 0.4784313738, blue: 0.09803921729, alpha: 1)
        }
        return NSAttributedString(string: string, attributes: attributes)
    }
}

