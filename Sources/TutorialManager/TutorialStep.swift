//
//  TutorialStep.swift
//
//  Created by Kien Nguyen on 11/03/2021.
//  Copyright © 2021 Sapo Tech. All rights reserved.
//

import Foundation
import UIKit

public struct TutorialStep {
    public enum TextVerticalPosition {
        case up
        case down
    }
    
    public enum TextHorizontalPosition {
        case left
        case right
    }
    
    public enum TextPosition {
        case up
        case down
        case left
        case right
    }
    
    /// Position of arrow, always paired with text position
    /// Text position is relative to arrow position
    public enum ArrowPosition {
        case left(text: TextVerticalPosition)
        case right(text: TextVerticalPosition)
        case up(text: TextHorizontalPosition)
        case down(text: TextHorizontalPosition)
    }
    
    public enum ImagePosition {
        case up
        case down
        case left
        case right
    }
    
    public enum DescriptionWidth {
        case fixed(CGFloat)
        case flexible
    }
    
    public struct HighlightPadding {
        public var x: CGFloat = 0.0
        public var y: CGFloat = 0.0
        
        public static let zero = HighlightPadding(x: 0, y: 0)
        
        public init(x: CGFloat, y: CGFloat) {
            self.x = x
            self.y = y
        }
    }
    
    /// Set to nil to disable arrow
    public var arrowPosition: ArrowPosition?
    public var arrowOffset: CGFloat = 0.0
    
    /// `descriptionTextPosition` will be used only when `arrowPosition` is nil
    public var descriptionTextPosition: TextPosition = .left
    public var descriptionIconPosition: ImagePosition = .left
    
    public var description: String?
    public var attributedDescription: NSAttributedString?
    public var icon: UIImage?
    public var iconOffset: CGFloat = 0.0
    
    public var descriptionWidth: DescriptionWidth = .fixed(240)
    
    public var highlightCornerRadius: CGFloat = 6.0
    public var highlightPadding: HighlightPadding = .zero
    
    public var target: TutorialStepTargeting!
    
    public var skippable: Bool = true
    
    /// Order for showing steps.
    /// Steps with non-`nil` order will be priotized.
    /// Steps with same order (and non-`nil`) will be shown together.
    /// Steps with `nil` order will be shown by index.
    public var order: Int?
    
    public init(arrowPosition: TutorialStep.ArrowPosition? = nil,
                arrowOffset: CGFloat = 0.0,
                descriptionTextPosition: TutorialStep.TextPosition = .left,
                descriptionIconPosition: TutorialStep.ImagePosition = .left,
                description: String? = nil,
                attributedDescription: NSAttributedString? = nil,
                icon: UIImage? = nil,
                iconOffset: CGFloat = 0.0,
                descriptionWidth: TutorialStep.DescriptionWidth = .fixed(240),
                highlightCornerRadius: CGFloat = 6.0,
                highlightPadding: TutorialStep.HighlightPadding = .zero,
                target: TutorialStepTargeting? = nil,
                skippable: Bool = true,
                order: Int? = nil) {
        self.arrowPosition = arrowPosition
        self.arrowOffset = arrowOffset
        self.descriptionTextPosition = descriptionTextPosition
        self.descriptionIconPosition = descriptionIconPosition
        self.description = description
        self.attributedDescription = attributedDescription
        self.icon = icon
        self.iconOffset = iconOffset
        self.descriptionWidth = descriptionWidth
        self.highlightCornerRadius = highlightCornerRadius
        self.highlightPadding = highlightPadding
        self.target = target
        self.skippable = skippable
        self.order = order
    }
}
