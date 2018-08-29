//
//  SymbolsEnumerations.swift
//  SetGame
//
//  Created by Юрий Забегаев on 18.08.2018.
//  Copyright © 2018 Юрий Забегаев. All rights reserved.
//

import Foundation

enum Symbol : Int {
    case symbolA = 0
    case symbolB = 1
    case symbolC = 2
    
    static func all() -> [Symbol] { return [.symbolA, .symbolB, .symbolC]}
}

enum SymbolsAmount : Int {
    case one = 0
    case two = 1
    case three = 2
    
    static func all() -> [SymbolsAmount] { return [.one, .two, .three] }
}

enum SymbolsTexture : Int {
    case textureA = 0
    case textureB = 1
    case textureC = 2
    
    static func all() -> [SymbolsTexture] { return [.textureA, .textureB, .textureC] }
}

enum SymbolsColor : Int {
    case colorA = 0
    case colorB = 1
    case colorC = 2
    
    static func all() -> [SymbolsColor] { return [.colorA, .colorB, .colorC] }
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
