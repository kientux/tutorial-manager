//
//  TutorialBackgroundView.swift
//
//  Created by Kien Nguyen on 11/03/2021.
//  Copyright © 2021 Sapo Tech. All rights reserved.
//

import Foundation
import UIKit

typealias TutorialHighlightPath = (frame: CGRect, cornerRadius: CGFloat)

class TutorialBackgroundView: UIView, CAAnimationDelegate {
    
    private var highlightPaths: [TutorialHighlightPath] = []
    private var completion: (() -> Void)?
    private var animated: Bool = true
    private var isAnimating: Bool = false
    
    var didTap: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let tgr = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture))
        addGestureRecognizer(tgr)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleTapGesture() {
        if isAnimating {
            return
        }
        
        didTap?()
    }
    
    override func removeFromSuperview() {
        super.removeFromSuperview()
        
        self.layer.mask = nil
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let path = CGMutablePath()
        
        highlightPaths.forEach { p in
            // check cornerRadius to prevent crash (when it's negative or larger than 1/2 frame size)
            var radius = p.cornerRadius
            
            if radius <= 0 {
                // set cornerRadius to 0 will treat it as "not rounded" rect
                // and cause weird animation when animate from rounded to not rounded
                // so we set it to a small value close to 0
                radius = 0.1
            } else if radius * 2.0 >= p.frame.width || radius * 2.0 >= p.frame.height {
                // set cornerRadius to frame size / 2.0 will also cause weird animation
                // so we set it to a value close to frame size / 2.0
                radius = min(p.frame.width, p.frame.height) / 2.0 - 0.1
            }
            
            path.addRoundedRect(in: p.frame,
                                cornerWidth: radius,
                                cornerHeight: radius)
        }
        
        path.addRect(bounds)
        
        if let mask = self.layer.mask as? CAShapeLayer {
            if !animated {
                mask.path = path
                dispatchCompletion()
                return
            }
            
            isAnimating = true
            
            let anim = CABasicAnimation(keyPath: "path")
            anim.fromValue = mask.path
            anim.toValue = path
            anim.duration = 0.3
            anim.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            anim.delegate = self
            anim.fillMode = .forwards
            anim.isRemovedOnCompletion = true
            mask.add(anim, forKey: nil)
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            mask.path = path
            CATransaction.commit()
        } else {
            let mask = CAShapeLayer()
            mask.fillRule = .evenOdd
            mask.path = path
            self.layer.mask = mask
            dispatchCompletion()
        }
    }
    
    /// Call before update highlight frames to keep only first frame
    /// to fix weird layer animation
    /// - Parameter completion:
    func prepareHighlightFrames(completion: @escaping () -> Void) {
        if highlightPaths.count <= 1 {
            completion()
            return
        }
        
        self.completion = completion
        highlightPaths = [highlightPaths[0]]
        animated = false
        setNeedsDisplay()
    }
    
    func updateHighlighFrames(_ paths: [TutorialHighlightPath], completion: (() -> Void)? = nil) {
        self.completion = completion
        highlightPaths = paths
        animated = true
        setNeedsDisplay()
    }
    
    private func dispatchCompletion() {
        isAnimating = false
        
        DispatchQueue.main.async {
            self.completion?()
        }
    }
    
    // MARK: CAAnimationDelegate
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        dispatchCompletion()
    }
}
