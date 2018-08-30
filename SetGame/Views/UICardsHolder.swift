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
    var getCardPosition: ((UICard)->(Int))?
    var getCardsList: (()->[UICard])?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setProps()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setProps()
    }
    
    
    override func draw(_ rect: CGRect) {
        grid.frame = bounds
        if getCardsList != nil && getCardPosition != nil {
            for card in getCardsList!() {
                UIViewPropertyAnimator.runningPropertyAnimator(
                    withDuration: 0.6,
                    delay: 0,
                    options: [.curveEaseInOut],
                    animations: { [unowned self] in
                        card.frame = self.grid[self.getCardPosition!(card)]!
                })
            }
        }
    }
    
    
    private func setProps() {
        grid = Grid(layout: .aspectRatio(3/4), frame: bounds)
        isOpaque = false
        backgroundColor = .clear
    }
    
}
