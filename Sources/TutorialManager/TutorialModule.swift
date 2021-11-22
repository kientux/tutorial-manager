//
//  TutorialModule.swift
//
//  Created by Kien Nguyen on 11/03/2021.
//  Copyright © 2021 Sapo Tech. All rights reserved.
//

import Foundation
import UIKit

public protocol TutorialModularizable {
    associatedtype StepKey: Hashable
    
    var name: String { get }
    
    func steps(targets: [StepKey: TutorialStepTargeting]) -> [TutorialStep]
}

public protocol TutorialModuleStepMappable: TutorialModularizable {
    typealias StepPair = (key: StepKey, value: TutorialStep)
    
    var stepPairs: [StepPair] { get }
}

extension TutorialModuleStepMappable {
    public func steps(targets: [StepKey: TutorialStepTargeting]) -> [TutorialStep] {
        var pairs = self.stepPairs
        mapTargets(targets, with: &pairs)
        return pairs.map({ $0.value })
    }
    
    private func mapTargets(_ targets: [StepKey: TutorialStepTargeting],
                            with steps: inout [StepPair]) {
        for i in 0..<steps.count {
            steps[i].value.target = targets.first(where: { $0.key == steps[i].key })?.value
        }

        steps = steps.filter({ $0.value.target != nil })
    }
}
