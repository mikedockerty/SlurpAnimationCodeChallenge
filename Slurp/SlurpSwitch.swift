//
//  SlurpSwitch.swift
//  Slurp
//
//  Created by Mike Dockerty on 4/16/16.
//  Copyright © 2016 Mike Dockerty. All rights reserved.
//

import UIKit

enum TransitionDirection {
    case RightToLeft
    case LeftToRight
}

class SlurpSwitch: UIView {

    private let leftLargeCenterPoint = CGPoint(x: 42.5, y: 50.0)
    private let rightLargeCenterPoint = CGPoint(x: 127.5, y: 50.0)
    
    private let leftSmallCenterPoint = CGPoint(x: 80.0, y: 50.0)
    private let rightSmallCenterPoint = CGPoint(x: 93.0, y: 50.0)
    
    private let smallCircleSize = CGSize(width: 23.0, height: 23.0)
    private let largeCircleSize = CGSize(width: 104.0, height: 104.0)
    
    private let leftCircle: UIView = UIView(frame: CGRectZero)
    private let rightCircle: UIView = UIView(frame: CGRectZero)
    
    private let shapeLayer: CAShapeLayer = CAShapeLayer()
    
    private var displayLink: CADisplayLink!
    
    private var lastTransitionDirection = TransitionDirection.RightToLeft
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    func setup() {
        layer.cornerRadius = 50.0
        
        let shadowLayer = CALayer()
        shadowLayer.shadowColor = UIColor.blackColor().CGColor
        shadowLayer.shadowRadius = 2.0
        shadowLayer.shadowOffset = CGSize(width: 0.0, height:3.0)
        shadowLayer.shadowOpacity = 0.5
        
        shapeLayer.fillColor = UIColor.whiteColor().CGColor
        //shapeLayer.fillColor = UIColor.clearColor().CGColor
        //shapeLayer.strokeColor = UIColor.greenColor().CGColor
        
        shadowLayer.addSublayer(shapeLayer)
        layer.addSublayer(shadowLayer)
        
        // CADisplayLink is used to animate the shape layer
        displayLink = CADisplayLink(target: self, selector: #selector(updateShapeLayer))
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        displayLink.paused = true
        
        leftCircle.bounds = CGRect(origin: CGPointZero, size: largeCircleSize)
        rightCircle.bounds = CGRect(origin: CGPointZero, size: smallCircleSize)
        
        leftCircle.center = leftLargeCenterPoint
        rightCircle.center = leftSmallCenterPoint

        addSubview(leftCircle)
        addSubview(rightCircle)
        
        shapeLayer.path = currentPath(false)

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(executeSwitch))
        self.addGestureRecognizer(tapRecognizer)
    }
    
    
    func currentPath(usePresentationLayer: Bool) -> CGPath {
        
        var leftLayer = CALayer()
        var rightLayer = CALayer()
        
        if usePresentationLayer {
            guard
                let leftPresentationLayer = leftCircle.layer.presentationLayer(),
                let rightPresentationLayer = rightCircle.layer.presentationLayer() else {
                    return UIBezierPath().CGPath
            }
            
            leftLayer = leftPresentationLayer as! CALayer
            rightLayer = rightPresentationLayer as! CALayer
        } else {
            leftLayer = leftCircle.layer
            rightLayer = rightCircle.layer
        }
        
        let path = UIBezierPath()
        
        path.addArcWithCenter(leftLayer.position,
                                  radius: leftLayer.bounds.size.width / 2,
                                  startAngle: 0.0,
                                  endAngle: 2 * CGFloat(M_PI),
                                  clockwise: true)
        
        path.addArcWithCenter(rightLayer.position,
                                  radius: rightLayer.bounds.size.width / 2,
                                  startAngle: 0.0,
                                  endAngle: 2 * CGFloat(M_PI),
                                  clockwise: true)
        // Top connecting path
        path.moveToPoint(CGPoint(x: leftLayer.position.x,
            y:leftLayer.position.y - leftLayer.bounds.size.height / 2))
        path.addLineToPoint(CGPoint(x: rightLayer.position.x,
            y:rightLayer.position.y - rightLayer.bounds.size.height / 2))
        path.addLineToPoint(rightLayer.position)
        
        // Bottom connecting path
        path.addLineToPoint(CGPoint(x: rightLayer.position.x,
            y:rightLayer.position.y + rightLayer.bounds.size.height / 2))
        path.addLineToPoint(CGPoint(x: leftLayer.position.x,
            y:leftLayer.position.y + leftLayer.bounds.size.height / 2))
        
        path.closePath()
        
        return path.CGPath
    }
    
    func updateShapeLayer() {
        shapeLayer.path = currentPath(true)
    }
    
    private func animate(transitionDirection: TransitionDirection) {
        
        // Animate changes to the circles' size
        UIView.animateWithDuration(1.0,
                                   delay: 0.0,
                                   usingSpringWithDamping: 0.5,
                                   initialSpringVelocity: 0.0,
                                   options: [],
                                   animations: { () -> Void in
                                    if transitionDirection == .LeftToRight {
                                        self.leftCircle.bounds = CGRect(origin: CGPointZero, size: self.smallCircleSize)
                                        self.rightCircle.bounds = CGRect(origin: CGPointZero, size: self.largeCircleSize)
                                    } else {
                                        self.leftCircle.bounds = CGRect(origin: CGPointZero, size: self.largeCircleSize)
                                        self.rightCircle.bounds = CGRect(origin: CGPointZero, size: self.smallCircleSize)
                                    }
            },
                                   completion: { _ in
                                        self.displayLink.paused = true
                                    
        })
        
        // Animate changes to the circles' position
        UIView.animateWithDuration(0.7,
                                   delay: 0.1,
                                   usingSpringWithDamping: 0.5,
                                   initialSpringVelocity: 0.0,
                                   options: [],
                                   animations: { () -> Void in
                                    if transitionDirection == .LeftToRight {
                                        self.leftCircle.center = self.rightSmallCenterPoint
                                        self.rightCircle.center = self.rightLargeCenterPoint
                                    } else {
                                        self.leftCircle.center = self.leftLargeCenterPoint
                                        self.rightCircle.center = self.leftSmallCenterPoint
                                    }
            },
                                   completion: { _ in
                                    
        })
    }
    
    @objc func executeSwitch() {
        displayLink.paused = false
        
        if lastTransitionDirection == .LeftToRight {
            animate(.RightToLeft)
            lastTransitionDirection = .RightToLeft
        } else {
            animate(.LeftToRight)
            lastTransitionDirection = .LeftToRight
        }
    }
}
