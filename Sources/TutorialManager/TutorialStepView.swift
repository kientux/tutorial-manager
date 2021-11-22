//
//  TutorialStepView.swift
//
//  Created by Kien Nguyen on 11/03/2021.
//  Copyright © 2021 Sapo Tech. All rights reserved.
//

import Foundation
import UIKit

public protocol TutorialStepView: UIView {
    init(step: TutorialStep)
    
    func updateTextPosition(_ pos: TutorialStep.TextPosition)
}

public class TutorialStepDescriptionView: UIView, TutorialStepView {
    private let step: TutorialStep
    
    private lazy var label = UILabel()
    
    public required init(step: TutorialStep) {
        self.step = step
        super.init(frame: .zero)
        setupViews()
    }
    
    public required init?(coder: NSCoder) {
        fatalError()
    }
    
    private func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        
        if step.icon == nil {
            [
                label.leadingAnchor.constraint(equalTo: leadingAnchor),
                label.trailingAnchor.constraint(equalTo: trailingAnchor),
                label.topAnchor.constraint(equalTo: topAnchor),
                label.bottomAnchor.constraint(equalTo: bottomAnchor)
            ].forEach({ $0.isActive = true })
        } else {
            let icon = UIImageView(image: step.icon)
            icon.contentMode = .center
            icon.translatesAutoresizingMaskIntoConstraints = false
            icon.setContentCompressionResistancePriority(.required, for: .horizontal)
            icon.setContentHuggingPriority(.required, for: .horizontal)
            
            switch step.descriptionIconPosition {
            case .left:
                addSubview(icon)
                [
                    icon.leadingAnchor.constraint(equalTo: leadingAnchor),
                    icon.centerYAnchor.constraint(equalTo: centerYAnchor, constant: step.iconOffset),
                    icon.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -8.0),
                    label.topAnchor.constraint(equalTo: topAnchor),
                    label.bottomAnchor.constraint(equalTo: bottomAnchor),
                    label.trailingAnchor.constraint(equalTo: trailingAnchor)
                ].forEach({ $0.isActive = true })
            case .right:
                addSubview(icon)
                [
                    icon.trailingAnchor.constraint(equalTo: trailingAnchor),
                    icon.centerYAnchor.constraint(equalTo: centerYAnchor, constant: step.iconOffset),
                    icon.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 8.0),
                    label.topAnchor.constraint(equalTo: topAnchor),
                    label.bottomAnchor.constraint(equalTo: bottomAnchor),
                    label.leadingAnchor.constraint(equalTo: leadingAnchor)
                ].forEach({ $0.isActive = true })
            case .up:
                addSubview(icon)
                [
                    icon.topAnchor.constraint(equalTo: topAnchor),
                    icon.centerXAnchor.constraint(equalTo: centerXAnchor, constant: step.iconOffset),
                    icon.bottomAnchor.constraint(equalTo: label.topAnchor, constant: -16.0),
                    label.leadingAnchor.constraint(equalTo: leadingAnchor),
                    label.trailingAnchor.constraint(equalTo: trailingAnchor),
                    label.bottomAnchor.constraint(equalTo: bottomAnchor)
                ].forEach({ $0.isActive = true })
            case .down:
                addSubview(icon)
                [
                    icon.bottomAnchor.constraint(equalTo: bottomAnchor),
                    icon.centerXAnchor.constraint(equalTo: centerXAnchor, constant: step.iconOffset),
                    icon.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16.0),
                    label.leadingAnchor.constraint(equalTo: leadingAnchor),
                    label.trailingAnchor.constraint(equalTo: trailingAnchor),
                    label.topAnchor.constraint(equalTo: topAnchor)
                ].forEach({ $0.isActive = true })
            }
        }
        
        label.numberOfLines = 0
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        
        if let string = step.attributedDescription {
            label.attributedText = string
        } else {
            label.text = step.description
        }
        
        if let arrowPos = step.arrowPosition {
            switch arrowPos {
            case .up(let textPos), .down(let textPos):
                label.textAlignment = textPos == .left ? .right : .left
            case .left, .right:
                label.textAlignment = .center
            }
        } else {
            updateTextPosition(step.descriptionTextPosition)
        }
    }
    
    public func updateTextPosition(_ pos: TutorialStep.TextPosition) {
        switch pos {
        case .up, .down:
            label.textAlignment = .center
        case .left:
            label.textAlignment = .right
        case .right:
            label.textAlignment = .left
        }
    }
}
