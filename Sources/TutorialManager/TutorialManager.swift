//
//  TutorialManager.swift
//
//  Created by Kien Nguyen on 11/03/2021.
//  Copyright © 2021 Sapo Tech. All rights reserved.
//

import Foundation
import UIKit

public class TutorialManager<Module: TutorialModularizable> {
    private let module: Module
    private let presenter: TutorialPresenting
    private let storage: TutorialSavingStorage
    
    public init(module: Module, presenter: TutorialPresenting, storage: TutorialSavingStorage) {
        self.module = module
        self.presenter = presenter
        self.storage = storage
        
        self.presenter.delegate = self
    }
    
    public func start(targets: [Module.StepKey: TutorialStepTargeting]) {
        if storage.isModuleShowed(module) {
            return
        }
        
        let steps = module.steps(targets: targets).filter({ !$0.target.targetView.isHidden })
        if steps.isEmpty {
            return
        }
        
        presenter.start(steps: steps)
    }
}

extension TutorialManager: TutorialPresentingDelegate {
    public func tutorialPresenterDidStart() {
        
    }
    
    public func tutorialPresenterDidEnd() {
        storage.moduleEnded(module)
    }
    
    public func tutorialPresenterDidGoToIndexes(_ indexes: [Int]) {
        
    }
}
