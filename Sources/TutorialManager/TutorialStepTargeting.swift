//
//  TutorialStepTargeting.swift
//
//  Created by Kien Nguyen on 11/03/2021.
//  Copyright © 2021 Sapo Tech. All rights reserved.
//

import Foundation
import UIKit

public protocol TutorialStepTargeting {
    var targetView: UIView { get }
    var arrowAnchorView: UIView? { get }
}

extension UIView: TutorialStepTargeting {
    public var targetView: UIView {
        self
    }
    
    public var arrowAnchorView: UIView? {
        nil
    }
}

extension UIBarButtonItem: TutorialStepTargeting {
    public var targetView: UIView {
        if let view = value(forKey: "view") as? UIView {
            return view
        }
        
        return UIView(frame: .zero)
    }
    
    public var arrowAnchorView: UIView? {
        nil
    }
}

public struct TutorialStepTarget: TutorialStepTargeting {
    public var targetView: UIView
    public var arrowAnchorView: UIView?

    public init(targetView: UIView, arrowAnchorView: UIView? = nil) {
        self.targetView = targetView
        self.arrowAnchorView = arrowAnchorView
    }
}
