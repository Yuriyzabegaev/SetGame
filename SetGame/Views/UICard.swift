//
//  Card.swift
//  SetGame
//
//  Created by Юрий Забегаев on 24.08.2018.
//  Copyright © 2018 Юрий Забегаев. All rights reserved.
//

import Foundation
import UIKit

extension UICard {
    private class Figure: UIView {
        
        private(set) var symbol: Symbol = .squiggles
        private(set) var texture: Texture = .stroken
        
        init(symbol: Symbol, texture: Texture) {
            (self.symbol, self.texture) = (symbol, texture)
            super.init(frame: .zero)
            setProperties()
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("not implemented")
        }
        
        private func setProperties() {
            contentMode = .redraw
            isOpaque = false
            backgroundColor = .clear
        }
        
        override func draw(_ rect: CGRect) {
            let figure: UIBezierPath
            
            switch symbol {
            case .diamonds:
                figure = UIBezierPath()
                figure.move(to: CGPoint(x: bounds.midX,
                                        y: bounds.minY + yOffsetBetweenFigures))
                figure.addLine(to: CGPoint(x: bounds.maxX,
                                           y: bounds.midY))
                figure.addLine(to: CGPoint(x: bounds.midX,
                                           y: bounds.maxY - yOffsetBetweenFigures))
                figure.addLine(to: CGPoint(x: bounds.minX,
                                           y: bounds.midY))
                figure.close()
            case .oval:
                figure = UIBezierPath(ovalIn: CGRect(x: bounds.minX,
                                                     y: bounds.minY + yOffsetBetweenFigures,
                                                     width: bounds.maxX,
                                                     height: bounds.maxY - yOffsetBetweenFigures))
            case .squiggles:
                figure = UIBezierPath()
                
                let center = CGPoint(x: bounds.midX , y: bounds.midY)
                figure.move(to: center)
                figure.addCurve(to: center,
                                controlPoint1: CGPoint(x: bounds.minX,
                                                       y: bounds.midY - bounds.maxY),
                                controlPoint2: CGPoint(x: bounds.minX,
                                                       y: bounds.midY + bounds.maxY))
                figure.addCurve(to: center,
                                controlPoint1: CGPoint(x: bounds.maxX,
                                                       y: bounds.midY - bounds.maxY),
                                controlPoint2: CGPoint(x: bounds.maxX,
                                                       y: bounds.midY + bounds.maxY))
            }
            
            figure.addClip()
            switch texture {
            case .filled:
                UIColor.white.setFill()
                figure.fill()
            case .stroken:
                figure.lineWidth = 5.0
                UIColor.white.setStroke()
                figure.stroke()
            case .striped:
                let stripes = UIBezierPath()
                let sequanceOfDots = stride(from: figure.bounds.minX, to: figure.bounds.maxX * 2, by: 10)
                for xPoint in sequanceOfDots {
                    stripes.move(to: CGPoint(x:xPoint - figure.bounds.maxX, y: figure.bounds.minY))
                    stripes.addLine(to: CGPoint(x: xPoint, y: figure.bounds.maxY))
                }
                stripes.lineWidth = 2
                UIColor.white.setStroke()
                stripes.stroke()
            }
        }
        
        private var yOffsetBetweenFigures: CGFloat {
            return bounds.size.height * 0.1
        }
        
    }
}


class UICard: UIView {
    
    var state: State = .notChosen
    private(set) var amount: Amount = .one
    private(set) var color: Color = .purple
    private(set) var symbol: Symbol = .squiggles
    private(set) var texture: Texture = .stroken
    private var figures: [Figure] = []
    private var grid: Grid!
    
    init(_ cardData: (Amount, Symbol, Texture, Color)) {
        (amount, symbol, texture, color) = cardData
        super.init(frame: .zero)
        setProperties()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setProperties()
    }
    
    private func setProperties() {
        contentMode = .redraw
        isOpaque = false
        backgroundColor = .clear
        
        for _ in 0...amount.hashValue {
            let figure = Figure(symbol: symbol, texture: texture)
            figure.contentMode = .redraw
            figures += [figure]
            self.addSubview(figure)
        }
    }
    
    override func draw(_ rect: CGRect) {
        grid = Grid(layout: .aspectRatio(figureFrame.size.height/figureFrame.size.width),
                    frame: figuresFrame)
        grid.cellCount = figures.count
        
        let frameRect = UIBezierPath(roundedRect: innerCardFrame,
                                     cornerRadius: cornerRadius)
        
        switch state {
        case .chosen:
            setChosenColor()
        case .hinted:
            setHintedColor()
        case .notChosen:
            setNotChosenColor()
        case .succeeded:
            setSucceededColor()
        }

        frameRect.fill()
        frameRect.lineWidth = 2.0
        #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).setStroke()
        frameRect.stroke()
        
        switch amount {
        case .one:
            figures[0].frame = grid[0]!
        case .two:
            figures[0].frame = grid[0]!
            figures[1].frame = grid[1]!
        case .three:
            figures[0].frame = grid[0]!
            figures[1].frame = grid[1]!
            figures[2].frame = grid[2]!
        }
    }
    
    private func setChosenColor() {
        switch color {
        case .green:
            #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1).setFill()
        case .purple:
            #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1).setFill()
        case .red:
            #colorLiteral(red: 0.5725490451, green: 0, blue: 0.2313725501, alpha: 1).setFill()
        }
    }
    
    private func setHintedColor() {
        switch color {
        case .green:
            #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).setFill()
        case .purple:
            #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).setFill()
        case .red:
            #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1).setFill()
        }
    }
    
    private func setNotChosenColor() {
        switch color {
        case .green:
            #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1).setFill()
        case .purple:
            #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1).setFill()
        case .red:
            #colorLiteral(red: 0.9098039269, green: 0.4784313738, blue: 0.6431372762, alpha: 1).setFill()
        }
    }
    
    private func setSucceededColor() {
        switch color {
        case .green:
            #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1).setFill()
        case .purple:
            #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1).setFill()
        case .red:
            #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1).setFill()
        }
    }
    
    private var figuresFrame: CGRect {
        let innerCardFrame = self.innerCardFrame
        let figureFrame = self.figureFrame
        return CGRect(x: innerCardFrame.midX - figureFrame.size.width/2,
                      y: innerCardFrame.midY - figureFrame.size.height*1.5,
                      width: figureFrame.size.width,
                      height: figureFrame.size.height*3)
    }
    
    private var figureFrame: CGRect {
        let innerCardFrame = self.innerCardFrame
        let ySize  = innerCardFrame.size.height * 0.5
        let xSize = innerCardFrame.size.width * 0.5
        return CGRect(x: innerCardFrame.midX - xSize/2,
                      y: innerCardFrame.midY - ySize/2,
                      width: xSize,
                      height: ySize)
    }
    
    private var innerCardFrame: CGRect {
        let offset:CGFloat = 1.5
        return CGRect(x: bounds.minX + offset,
                      y: bounds.minY + offset,
                      width: bounds.size.width - offset*2,
                      height: bounds.size.height - offset*2)
    }
    
    private var cornerRadius: CGFloat {
        let coefToWidth:CGFloat = 0.1
        return bounds.width * coefToWidth
    }
    
}

