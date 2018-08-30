//
//  Extensions.swift
//  SetGame
//
//  Created by Юрий Забегаев on 17.08.2018.
//  Copyright © 2018 Юрий Забегаев. All rights reserved.
//

import Foundation
import UIKit


extension MutableCollection {
    mutating func shuffle() {
        let maxIndex = self.count
        for index in self.indices {
            let randomIndex = self.index(self.startIndex, offsetBy: Int(arc4random_uniform(UInt32(maxIndex))))
            self.swapAt(index, randomIndex)
        }
    }
    
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}

extension Equatable {
    static func eachOfThreeIsEqual(_ a:Self, _ b:Self, _ c:Self) -> Bool {
        return (a == b) && (a == c)
    }
    
    static func noneOfThreeIsEqual(_ a:Self, _ b:Self, _ c:Self) -> Bool {
        return a != b && a != c && b != c
    }
    
    static func eachOfThreeOrNoneIsEqual(_ a:Self, _ b:Self, _ c:Self) -> Bool {
        return eachOfThreeIsEqual(a, b, c) || noneOfThreeIsEqual(a, b, c)
    }
}

extension UICard {
    enum State {
        case chosen
        case notChosen
        case hinted
        case succeeded
    }
    
    enum Symbol {
        case squiggles
        case oval
        case diamonds
    }
    
    enum Amount: Int {
        case one = 1
        case two = 2
        case three = 3
    }
    enum Texture {
        case filled
        case striped
        case stroken
    }
    enum Color {
        case green
        case red
        case purple
    }
}


extension Double {
    var arc4random: Double {
        let random = arc4random_uniform(UInt32.max)
        let res = Double(random) / Double(UInt32.max)
        return res*self
    }
}
