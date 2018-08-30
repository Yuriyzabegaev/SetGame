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
        
        private(set) var cards:[Card] = []
        private(set) var uiCards:[UICard] = []
        var flyawayUICards:[UICard] = []
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
        
        
        func getCardsList() -> [UICard] { return uiCards }
        
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
        
        func giveNotUsedUICard() -> UICard? {
            if flyawayUICards.isEmpty { return nil }
            return flyawayUICards.popLast()!
        }
        
        func remove(at index:Int) {
            if index >= cards.endIndex {
                return
            }
            cards.remove(at: index)
            uiCards.remove(at: index)
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
            for card in uiCards {
                card.removeFromSuperview()
            }
            for card in flyawayUICards {
                card.removeFromSuperview()
            }
            for index in cards.indices.reversed() { remove(at: index) }
            flyawayUICards = []
        }
        
        func getCard(at location:CGPoint) -> UICard? {
            for card in uiCards {
                if card.frame.contains(location) { return card }
            }
            return nil
        }
        
        func getCardPosition(of card:UICard) -> Int {
            return uiCards.index(of: card)!
        }
        
        func shuffleCardsPositions() {
            let indeces = [Int](cards.indices).shuffled()
            var newUICards: [UICard] = []
            var newCards: [Card] = []
            for newIndex in indeces {
                newCards.append(cards[newIndex])
                newUICards.append(uiCards[newIndex])
            }
            cards = newCards
            uiCards = newUICards
        }
        
    }
}


class ViewController: UIViewController {

    //MARK: Properties
    private var queueToRemove: [UICard] = []
    private let game = SetGame()
    lazy private var cardsStorage: ControllerCardsStorage = {
        let storage = ControllerCardsStorage(cardsHolder: self.cardsHolder)
        return storage
    }()

    lazy private var animator = UIDynamicAnimator(referenceView: self.view)
    lazy private var cardBehavior = CardBehavior(in: animator)
    lazy private var dynamicAnimationCards: [UICard] = {
        var cards: [UICard] = []
        for _ in 1...3 {
            let card = UICard((UICard.Amount.one,
                               UICard.Symbol.diamonds,
                               UICard.Texture.filled,
                               UICard.Color.green),
                              frame: CGRect(x: 0, y: 0, width: 1, height: 1))
            card.alpha = 0
            
            cardsHolder.addSubview(card)
            cardBehavior.addItem(card)
            cards.append(card)
        }
        return cards
    }()

    
    //MARK: Outlets
    @IBOutlet weak var waste: UIDeck!
    @IBOutlet weak var deck: UIDeck!
    @IBOutlet weak var score: UILabel!
    @IBOutlet weak var cardsHolder: UICardsHolder! {
        didSet {
            let tapOnCard = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapOnCardGesture(_:)))
            cardsHolder.addGestureRecognizer(tapOnCard)
            
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(swipeDownGesture))
            swipeDown.direction = .down
            cardsHolder.addGestureRecognizer(swipeDown)
            
            cardsHolder.getCardsList = cardsStorage.getCardsList
            cardsHolder.getCardPosition = cardsStorage.getCardPosition
        }
    }

    
    //MARK: Gesture handlers
    @IBAction func rotation(_ sender: UIRotationGestureRecognizer) {
        guard !game.isFinished else { return }

        switch sender.state {
        case .ended:
            cardsStorage.shuffleCardsPositions()
            updateGameUI()
        default: break
        }
        
    }
    
    @IBAction func tapOnDeck(_ sender: UITapGestureRecognizer) {
        openThreeMoreCards()
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
        cleanCompletedCards()
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
        cleanup()
        game.startNewGame()
        updateGameUI()
    }
    
    
    //MARK: Overrides
    override func viewDidLoad() {
        super.viewDidLoad()
        startNewGame()
    }
    
    
    //MARK: Private Methods
    private func updateGameUI() {
        
        /// if there are cards in a buffer to be hidden, open new cards in place of them
        if !queueToRemove.isEmpty {
            cleanCompletedCards()
            game.openThreeNewCards()
        }
        
        /// change the grid if needed
        let notCompletedCardsOnTable = game.cardsOnTable.filter { $0.state != .isCompleted }
        let countOfNotCompletedCardsOnTable = notCompletedCardsOnTable.count
        if !game.haveSetChosen, countOfNotCompletedCardsOnTable != cardsHolder.grid.cellCount {
            cardsHolder.grid.cellCount = countOfNotCompletedCardsOnTable
        }
        
        updatePositions()
        
        /// switch state of cards
        for (card, uiCard) in cardsStorage {
            switch card.state {
            case .isCompleted:
                /// hide it from UI and remove from cardsOnTable in a next touch
                queueToRemove += [uiCard]
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
        
        if game.haveSetChosen {
            Timer.scheduledTimer(withTimeInterval: 1.2, repeats: false, block: { [unowned self] timer in
                if !self.queueToRemove.isEmpty {
                    self.game.chooseCard(self.cardsStorage[self.queueToRemove[0]]!)
                    self.updateGameUI()
                }
            })
        }
    }
    
    private func updatePositions() {
        
        /// filters all not completed cards on deck to two arrays to perform animations to update positions
        var cardsToMaybeRearrange: [UICard] = []
        var newCardsFromDeck: [UICard] = []
        for card in game.cardsOnTable.filter({ $0.state != .isCompleted }) {
            
            var uiCard = cardsStorage[card]

            if uiCard == nil {
                uiCard = cardsStorage.giveNotUsedUICard()
                if uiCard == nil {
                    uiCard = UICard(getCardUIData(card), frame: deck.frame)
                    cardsHolder.addSubview(uiCard!)
                } else {
                    uiCard!.changeFigure(to: getCardUIData(card))
                }
                cardsStorage.add(card: card, uiCard: uiCard!)
                uiCard?.frame = deck.frame
                
                newCardsFromDeck += [uiCard!]
            } else {
                cardsToMaybeRearrange += [uiCard!]
            }
            
        }
        
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.6,
            delay: 0,
            options: [.curveEaseInOut],
            animations: { [unowned self] in
                for uiCard in cardsToMaybeRearrange {
                    uiCard.frame = self.cardsHolder.grid[self.cardsStorage.getCardPosition(of: uiCard)]!
                }
            },
            completion: { [unowned self] position in
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.6,
                    delay: 0,
                    options: [.curveEaseInOut],
                    animations: { [unowned self] in
                        for uiCard in newCardsFromDeck {
                            uiCard.alpha = 1
                            uiCard.frame = self.cardsHolder.grid[self.cardsStorage.getCardPosition(of: uiCard)]!
                        }
                })
        })
    }
    
    private func updateScore() {
        deck.updateCardsInDeckLabel(with: game.cardsInDeckCount)
        score.text = "Score: \(game.score)"
    }
    
    private func openThreeMoreCards() {
        guard !game.isFinished else {
            return
        }
        cleanCompletedCards()
        game.openThreeNewCards()
        updateGameUI()
    }
    
    private func cleanCompletedCards() {
        
        if queueToRemove.isEmpty {
            return
        }
        for (index, animationCard) in dynamicAnimationCards.enumerated() {
            animationCard.changeFigure(like: queueToRemove[index])
            animationCard.frame = queueToRemove[index].frame
            animationCard.bounds = queueToRemove[index].bounds
            animationCard.center = queueToRemove[index].center
            animationCard.alpha = 1
            queueToRemove[index].alpha = 0
            cardsStorage.remove(uiCard: queueToRemove[index])
            animator.updateItem(usingCurrentState: animationCard)
            cardBehavior.push([animationCard], direction: waste.frame)
        }
        cardsStorage.flyawayUICards += queueToRemove
        queueToRemove = []
    }
    
    private func hideUICards(_ cards: [UICard]) {
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.6,
            delay: 0,
            options: [.curveEaseIn],
            animations: {
                for uiCard in cards {
                    uiCard.alpha = 0
                }
        })
    }
    
    private func cleanup() {
        cleanCompletedCards()
        hideUICards(cardsStorage.uiCards)
        cardsStorage.removeAll()
    }
}
