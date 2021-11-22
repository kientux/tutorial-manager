//
//  TutorialPresenter.swift
//
//  Created by Kien Nguyen on 11/03/2021.
//  Copyright © 2021 Sapo Tech. All rights reserved.
//

import Foundation
import UIKit

public protocol TutorialPresenting: AnyObject {
    var delegate: TutorialPresentingDelegate? { get set }
    
    func start(steps: [TutorialStep])
    func next()
    func end()
}

public protocol TutorialPresentingDelegate: AnyObject {
    func tutorialPresenterDidGoToIndexes(_ indexes: [Int])
    func tutorialPresenterDidStart()
    func tutorialPresenterDidEnd()
}

public class TutorialPresenter<StepViewType: TutorialStepView>: TutorialPresenting {
    
    private let TEXT_ADJUST_PADDING: CGFloat = 8.0
    
    private let container: UIView
    private let scrollView: UIScrollView?
    private var steps: [TutorialStep] = []
    private var currentIndex: Int = 0
    
    private lazy var background: TutorialBackgroundView = {
        let background = TutorialBackgroundView()
        background.backgroundColor = .init(white: 0, alpha: 0.75)
        background.didTap = { [weak self] in self?.next() }
        return background
    }()
    
    private var stepViews: [StepViewType] = []
    private var arrowViews: [UIView] = []
    
    private var skipView: UIView?
    private var nextView: UIView?
    
    public weak var delegate: TutorialPresentingDelegate?
    
    public var skipTitle: String = "Skip" {
        didSet {
            if let skipButton = skipView as? UIButton {
                skipButton.setTitle(skipTitle, for: .normal)
            }
        }
    }
    
    public var nextTitle: String = "Next" {
        didSet {
            if let nextButton = nextView as? UIButton {
                nextButton.setTitle(nextTitle, for: .normal)
            }
        }
    }
    
    public var lastStepTitle: String = "Understand"
    
    public init(container: UIView,
                scrollView: UIScrollView? = nil) {
        self.container = container
        self.scrollView = scrollView
    }
    
    private func sortSteps() {
        steps.sort(by: { (l, r) in
            if let o1 = l.order, let o2 = r.order {
                return o1 < o2
            }
            
            return l.order != nil
        })
    }
    
    public func start(steps: [TutorialStep]) {
        self.steps = steps
        sortSteps()
        
        if background.superview == nil {
            background.alpha = 0
            container.addSubview(background)
            background.frame = container.bounds
            
            UIView.animate(withDuration: 0.25) {
                self.background.alpha = 1.0
            }
        }
        
        addNextView()
        
        currentIndex = -1
        next()
        
        delegate?.tutorialPresenterDidStart()
    }
    
    public func next() {
        let indexes = getIndexes(for: currentIndex)
        if shouldEnd(indexes: indexes) {
            end()
            return
        }
        
        currentIndex += indexes.count
        
        let nextIndexes = getIndexes(for: currentIndex)
        let isLastStep = shouldEnd(indexes: nextIndexes)
        if isLastStep, let nextView = nextView {
            (nextView as? UIButton)?.setTitle(lastStepTitle, for: .normal)
            let prevRect = nextView.frame
            nextView.sizeToFit()
            nextView.frame = CGRect(x: prevRect.maxX - nextView.frame.width,
                                    y: prevRect.origin.y,
                                    width: nextView.frame.width,
                                    height: nextView.frame.height)
        }
        
        highlightTarget(at: indexes, isLastStep: isLastStep)
        
        delegate?.tutorialPresenterDidGoToIndexes(indexes)
    }
    
    public func end() {
        UIView.animate(withDuration: 0.25, animations: {
            self.background.alpha = 0.0
        }, completion: { [self] _ in
            background.removeFromSuperview()
        })
        
        skipView?.removeFromSuperview()
        nextView?.removeFromSuperview()
        removeCurrentStepViews()
        scrollView?.setContentOffset(.zero, animated: true)
        
        delegate?.tutorialPresenterDidEnd()
    }
    
    private func getIndexes(for currentIndex: Int) -> [Int] {
        var indexes: [Int] = []
        var currentOrder: Int?
        
        for i in (currentIndex + 1)..<steps.count {
            guard let order = steps[i].order else {
                if indexes.isEmpty {
                    indexes = [i]
                }
                
                break
            }
            
            if currentOrder == nil {
                currentOrder = order
                indexes.append(i)
            } else if order == currentOrder {
                indexes.append(i)
            } else {
                break
            }
        }
        
        return indexes
    }
    
    private func shouldEnd(indexes: [Int]) -> Bool {
        currentIndex + indexes.count >= steps.count || indexes.isEmpty
    }
    
    private func removeCurrentStepViews() {
        stepViews.forEach({ $0.removeFromSuperview() })
        arrowViews.forEach({ $0.removeFromSuperview() })
        
        stepViews.removeAll()
        arrowViews.removeAll()
    }
    
    private func stepsAt(_ indexes: [Int]) -> [TutorialStep] {
        var results: [TutorialStep] = []
        for i in 0..<steps.count where indexes.contains(i) {
            results.append(steps[i])
        }
        
        return results
    }
    
    private func highlightTarget(at indexes: [Int], isLastStep: Bool) {
        let steps = stepsAt(indexes)
        guard steps.count > 0 else {
            return
        }
        
        if isLastStep || steps.contains(where: { !$0.skippable }) {
            skipView?.removeFromSuperview()
        } else if skipView?.superview == nil, !isLastStep {
            addSkipView()
        }
        
        let targets = steps.map({ $0.target.targetView })
        
        if let superview = targets[0].superview,
           let scrollView = scrollView, targets[0].isDescendant(of: scrollView) {
            var rect = superview.convert(targets[0].frame, to: scrollView)
            
            let bottomInsets: [CGFloat] = [196.0, 128.0, 96.0, 64.0, 32.0, 16.0]
            
            for inset in bottomInsets
            where rect.maxY < scrollView.contentInset.top
                + scrollView.contentSize.height + inset {
                rect.origin.y += inset
                break
            }
            
            scrollView.scrollRectToVisible(rect, animated: false)
        }
        
        removeCurrentStepViews()
        
        var targetRects: [CGRect] = []
        var highlightPaths: [TutorialHighlightPath] = []
        
        for step in steps {
            let rect = self.targetRect(of: step.target.targetView,
                                       padding: step.highlightPadding)
            targetRects.append(rect)
            highlightPaths.append((rect, step.highlightCornerRadius))
        }
        
        let arrowAnchorRects = steps.map({
            self.targetRect(of: $0.target.arrowAnchorView ?? $0.target.targetView)
        })
        
        background.prepareHighlightFrames { [weak self] in
            self?.background.updateHighlighFrames(highlightPaths) { [weak self] in
                for i in 0..<steps.count {
                    self?.addDescriptionView(step: steps[i],
                                             targetRect: targetRects[i],
                                             arrowAnchorRect: arrowAnchorRects[i])
                }
                
                DispatchQueue.main.async {
                    self?.positionNextView(targetRects: targetRects)
                }
            }
        }
    }
    
    private func addSkipView() {
        let button = UIButton(type: .system)
        button.setTitle(skipTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18.0)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapSkip), for: .touchUpInside)
        button.contentEdgeInsets = .init(top: 4, left: 16, bottom: 4, right: 16)
        container.addSubview(button)
        
        skipView = button
        layoutSkipView()
    }
    
    @objc private func didTapSkip() {
        end()
    }
    
    private func addNextView() {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 4.0
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1.0
        button.setTitle(nextTitle, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18.0)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(didTapNext), for: .touchUpInside)
        button.contentEdgeInsets = .init(top: 8, left: 16, bottom: 8, right: 16)
        container.addSubview(button)
        
        nextView = button
    }
    
    private func layoutSkipView() {
        guard let skipView = skipView else {
            return
        }
        
        skipView.sizeToFit()
        var frame = CGRect(x: container.bounds.width - skipView.bounds.width - 12.0,
                           y: 12.0,
                           width: skipView.bounds.width,
                           height: skipView.bounds.height)
        
        if #available(iOS 11.0, *) {
            frame.origin.y += container.safeAreaInsets.top
        }
        
        skipView.frame = frame
    }
    
    private func positionNextView(targetRects: [CGRect]) {
        guard let nextView = nextView else {
            return
        }
        
        nextView.sizeToFit()
        
        var y: CGFloat = container.bounds.height - nextView.bounds.height - 96.0
        
        let updateFrame = {
            let frame = CGRect(x: self.container.bounds.width - nextView.bounds.width - 12.0,
                               y: y,
                               width: nextView.bounds.width,
                               height: nextView.bounds.height)
            
            if frame != nextView.frame {
                nextView.frame = frame
            }
        }
        
        updateFrame()
        
        defer {
            updateFrame()
        }
        
        guard let stepRect = stepViews.map({ $0.frame }).min(by: { $0.minY < $1.minY }),
           let targetRect = targetRects.min(by: { $0.minY < $1.minY }) else {
            return
        }
        
        let stepBoundRect = stepRect.union(targetRect)
        
        if nextView.frame.intersects(stepBoundRect) {
            y = stepBoundRect.minY - nextView.bounds.height - 24.0
        } else {
            var r = nextView.frame
            r.origin.y = y
            
            if r.intersects(stepBoundRect) {
                y = stepBoundRect.minY - nextView.bounds.height - 24.0
            }
        }
    }
    
    @objc private func didTapNext() {
        next()
    }
    
    private func addDescriptionView(step: TutorialStep, targetRect: CGRect, arrowAnchorRect: CGRect) {
        let stepView = StepViewType(step: step)
        stepView.alpha = 0
        
        self.container.addSubview(stepView)
        self.stepViews.append(stepView)
        
        if case .fixed(let width) = step.descriptionWidth {
            layoutStepView(stepView, width: width)
        }
        
        guard let arrowPos = step.arrowPosition else {
            if case .flexible = step.descriptionWidth {
                switch step.descriptionTextPosition {
                case .up, .down:
                    layoutStepView(stepView, width: container.bounds.width - 16.0)
                case .left:
                    layoutStepView(stepView, width: targetRect.minX - 16.0)
                case .right:
                    layoutStepView(stepView, width: container.bounds.width - targetRect.maxX - 16.0)
                }
            }
            
            positionStepView(stepView, step: step, targetRect: targetRect)
            UIView.animate(withDuration: 0.2) {
                stepView.alpha = 1.0
            }
            
            return
        }
        
        positionStepView(stepView,
                         arrowPos: arrowPos,
                         arrowOffset: step.arrowOffset,
                         descriptionWidth: step.descriptionWidth,
                         targetRect: targetRect,
                         arrowAnchorRect: arrowAnchorRect)
    }
    
    private func positionStepView(_ stepView: TutorialStepView,
                                  step: TutorialStep,
                                  targetRect: CGRect) {
        let origin: CGPoint = { (pos: TutorialStep.TextPosition) -> CGPoint in
            switch pos {
            case .up:
                return CGPoint(x: targetRect.midX - stepView.bounds.width / 2.0,
                               y: targetRect.minY - stepView.bounds.height - 16.0)
            case .down:
                return CGPoint(x: targetRect.midX - stepView.bounds.width / 2.0,
                               y: targetRect.maxY + 16.0)
            case .left:
                return CGPoint(x: targetRect.minX - stepView.bounds.width - 16.0,
                               y: targetRect.midY - stepView.bounds.height / 2.0)
            case .right:
                return CGPoint(x: targetRect.maxX + 16.0,
                               y: targetRect.midY - stepView.bounds.height / 2.0)
            }
        }(step.descriptionTextPosition)
        
        let frame = CGRect(origin: origin, size: stepView.bounds.size)
        stepView.constraintByFrame(frame)
        stepView.setNeedsLayout()
    }
    
    private func positionStepView(_ stepView: StepViewType,
                                  arrowPos: TutorialStep.ArrowPosition,
                                  arrowOffset: CGFloat,
                                  descriptionWidth: TutorialStep.DescriptionWidth,
                                  targetRect: CGRect,
                                  arrowAnchorRect: CGRect) {
        
        let arrow = positionArrow(pos: arrowPos,
                                  offset: arrowOffset,
                                  targetRect: targetRect,
                                  anchorRect: arrowAnchorRect)
        arrow.alpha = 0
        
        if case .flexible = descriptionWidth {
            switch arrowPos {
            case .left, .right:
                layoutStepView(stepView, width: container.bounds.width - 16.0)
            case .up(let textPos), .down(let textPos):
                if textPos == .left {
                    layoutStepView(stepView, width: arrow.frame.minX - 16.0)
                } else {
                    layoutStepView(stepView, width: container.bounds.width - arrow.frame.maxX - 16.0)
                }
            }
        }
        
        positionStepViewWithArrow(arrow: arrow,
                                  arrowPos: arrowPos,
                                  stepView: stepView,
                                  targetRect: targetRect)
        UIView.animate(withDuration: 0.2) {
            stepView.alpha = 1.0
            arrow.alpha = 1.0
        }
    }
    
    private func positionArrow(pos: TutorialStep.ArrowPosition,
                               offset: CGFloat,
                               targetRect: CGRect,
                               anchorRect: CGRect) -> UIImageView {
        let arrow: UIImageView
        defer {
            arrow.tintColor = .white
            arrow.translatesAutoresizingMaskIntoConstraints = false
            arrowViews.append(arrow)
        }
        
        var origin: CGPoint
        
        switch pos {
        case .up(let textPos):
            arrow = UIImageView(image: UIImage(named: textPos == .left
                                                ? "arrow.right.down"
                                                : "arrow.left.down",
                                               in: Bundle.module,
                                               compatibleWith: nil))
            origin = CGPoint(x: anchorRect.midX - arrow.bounds.width / 2.0
                                + (textPos == .left ? -8.0 : 8.0)
                                + offset,
                             y: targetRect.minY - arrow.bounds.height - 8.0)
        case .down(let textPos):
            arrow = UIImageView(image: UIImage(named: textPos == .left
                                                ? "arrow.right.up"
                                                : "arrow.left.up",
                                               in: Bundle.module,
                                               compatibleWith: nil))
            origin = CGPoint(x: anchorRect.midX - arrow.bounds.width / 2.0
                                + (textPos == .left ? -8.0 : 8.0)
                                + offset,
                             y: targetRect.maxY + 8.0)
        case .left(let textPos):
            arrow = UIImageView(image: UIImage(named: textPos == .up
                                                ? "arrow.down.right"
                                                : "arrow.up.right",
                                               in: Bundle.module,
                                               compatibleWith: nil))
            origin = CGPoint(x: targetRect.minX - arrow.bounds.width - 8.0,
                             y: anchorRect.midY - arrow.bounds.height / 2.0
                                + (textPos == .up ? -8.0 : 8.0)
                                + offset)
        case .right(let textPos):
            arrow = UIImageView(image: UIImage(named: textPos == .up
                                                ? "arrow.down.left"
                                                : "arrow.up.left",
                                               in: Bundle.module,
                                               compatibleWith: nil))
            origin = CGPoint(x: targetRect.maxX + 8.0,
                             y: anchorRect.midY - arrow.bounds.height / 2.0
                                + (textPos == .up ? -8.0 : 8.0)
                                + offset)
        }
        
        container.addSubview(arrow)
        
        let frame = CGRect(origin: origin, size: arrow.bounds.size)
        arrow.frame = frame
        arrow.constraintByFrame(frame)
        arrow.setNeedsLayout()
        
        return arrow
    }
    
    private func positionStepViewWithArrow(arrow: UIImageView,
                                           arrowPos: TutorialStep.ArrowPosition,
                                           stepView: StepViewType,
                                           targetRect: CGRect) {
        let origin: CGPoint
        
        switch arrowPos {
        case .up(let textPos):
            origin = CGPoint(x: textPos == .left
                                ? arrow.frame.minX - stepView.bounds.width - 8.0
                                : arrow.frame.maxX + 8.0,
                             y: arrow.frame.maxY - stepView.bounds.height - 16.0)
        case .down(let textPos):
            origin = CGPoint(x: textPos == .left
                                ? arrow.frame.minX - stepView.bounds.width - 8.0
                                : arrow.frame.maxX + 8.0,
                             y: arrow.frame.minY + 12.0)
        case .left(let textPos):
            let x = max(TEXT_ADJUST_PADDING, targetRect.minX - stepView.bounds.width)
            origin = CGPoint(x: x,
                             y: textPos == .up
                                ? arrow.frame.minY - stepView.frame.height - 16.0
                                : arrow.frame.maxY + 16.0)
        case .right(let textPos):
            let overX = targetRect.maxX + stepView.bounds.width - self.container.bounds.width
            let x = targetRect.maxX - max(overX + TEXT_ADJUST_PADDING, 0)
            origin = CGPoint(x: x,
                             y: textPos == .up
                                ? arrow.frame.minY - stepView.frame.height - 16.0
                                : arrow.frame.maxY + 16.0)
        }
        
        var frame = CGRect(origin: origin, size: stepView.bounds.size)
        if frame.minX < 0 {
            frame.origin.x = 4.0
            frame.size.width += origin.x - 4.0
        } else if frame.maxX > container.bounds.width {
            frame.size.width = container.bounds.width - frame.minX - 4.0
        }
        
        stepView.constraintByFrame(frame)
        stepView.setNeedsLayout()
    }
    
    private func targetRect(of target: UIView, padding: TutorialStep.HighlightPadding = .zero) -> CGRect {
        guard let superview = target.superview else {
            return .zero
        }
        
        return superview.convert(target.frame, to: container)
            .insetBy(dx: -padding.x, dy: -padding.y)
    }
    
    private func layoutStepView(_ stepView: UIView, width: CGFloat) {
        stepView.constraintSelf(.width, width)
        
        // layout immediately to get size
        stepView.layoutIfNeeded()
    }
}

private extension UIView {
    func constraintToSuperview(_ attr: NSLayoutConstraint.Attribute,
                               _ constant: CGFloat) {
        precondition(superview != nil, "superview must not be nil")
        
        superview!.addConstraint(
            NSLayoutConstraint(item: self,
                               attribute: attr,
                               relatedBy: .equal,
                               toItem: superview!,
                               attribute: attr,
                               multiplier: 1.0,
                               constant: constant)
        )
    }
    
    func constraintSelf(_ attr: NSLayoutConstraint.Attribute,
                        _ constant: CGFloat) {
        if let constraint = constraints.first(where: {
            $0.firstAttribute == attr || $0.secondAttribute == attr
        }) {
            constraint.constant = constant
            return
        }
        
        addConstraint(
            NSLayoutConstraint(item: self,
                               attribute: attr,
                               relatedBy: .equal,
                               toItem: nil,
                               attribute: .notAnAttribute,
                               multiplier: 1.0,
                               constant: constant)
        )
    }
    
    func constraintByFrame(_ frame: CGRect) {
        constraintToSuperview(.leading, frame.origin.x)
        constraintToSuperview(.top, frame.origin.y)
        constraintSelf(.width, frame.size.width)
    }
}
