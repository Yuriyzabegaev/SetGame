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
