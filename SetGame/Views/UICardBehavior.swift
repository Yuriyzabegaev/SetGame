//
//  UICardBehavior.swift
//  SetGame
//
//  Created by Юрий Забегаев on 30.08.2018.
//  Copyright © 2018 Юрий Забегаев. All rights reserved.
//

import UIKit


class CardBehavior: UIDynamicBehavior {
    
    lazy var collisionBehavior: UICollisionBehavior = {
        let behavior = UICollisionBehavior()
        behavior.translatesReferenceBoundsIntoBoundary = true
        return behavior
    }()
    lazy var itemBehavior: UIDynamicItemBehavior = {
        let behavior = UIDynamicItemBehavior()
        behavior.allowsRotation = true
        behavior.elasticity = 0.5
        behavior.resistance = 0.5
        behavior.density = 2000
        return behavior
    }()
    
    
    override init() {
        super.init()
        addChildBehavior(collisionBehavior)
        addChildBehavior(itemBehavior)
    }
    
    convenience init(in animator: UIDynamicAnimator) {
        self.init()
        animator.addBehavior(self)
    }
    
    
    func addItem(_ item: UIDynamicItem) {
        collisionBehavior.addItem(item)
        itemBehavior.addItem(item)
    }
    
    func removeItem(_ item: UIDynamicItem) {
        collisionBehavior.removeItem(item)
        itemBehavior.removeItem(item)
    }

    
    func push(_ items: [UIDynamicItem], direction: CGRect) {
        guard !items.isEmpty else { return }
        
        let push = UIPushBehavior(items: items, mode: .instantaneous)
        push.angle = CGFloat((2*Double.pi).arc4random)
        push.magnitude = 1 + CGFloat(2.0.arc4random)
        push.action = { [weak push, weak self] in
            self?.removeChildBehavior(push!)
            let strongPush = push!
            _ = Timer.scheduledTimer(withTimeInterval: 0.6, repeats: false) { [weak self] timer in
                self?.getToWaste(strongPush.items, direction: direction)
                for item in items {
                    let linearV = self!.itemBehavior.linearVelocity(for: item)
                    self!.itemBehavior.addLinearVelocity(CGPoint.init(x: -linearV.x, y: -linearV.y), for: item)
                    self!.itemBehavior.addAngularVelocity(-self!.itemBehavior.angularVelocity(for: item), for: item)
                }
            }
        }
        addChildBehavior(push)
    }
    
    private func getToWaste(_ items: [UIDynamicItem], direction: CGRect) {

        for item in items {
            let view = item as! UIView
            let push = UIPushBehavior(items: [item], mode: .continuous)
            push.pushDirection = CGVector(dx:direction.midX - view.frame.midX , dy: direction.midY - view.frame.midY)
            push.magnitude = 1 + CGFloat(0.5.arc4random)
            push.action = { [unowned push, weak self] in
                if direction.intersects(view.frame) {
                    self?.removeChildBehavior(push)
                    UIViewPropertyAnimator.runningPropertyAnimator(
                        withDuration: 0.2,
                        delay: 0,
                        options: [],
                        animations: { [unowned view] in
                            view.alpha = 0
                    })
                }
            }
            addChildBehavior(push)
        }
    }
    
}
