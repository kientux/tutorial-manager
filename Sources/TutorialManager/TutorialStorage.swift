//
//  TutorialStorage.swift
//
//  Created by Kien Nguyen on 11/03/2021.
//  Copyright © 2021 Sapo Tech. All rights reserved.
//

import Foundation

public protocol TutorialSavingStorage {
    func isModuleShowed<Module: TutorialModularizable>(_ module: Module) -> Bool
    func moduleEnded<Module: TutorialModularizable>(_ module: Module)
}

public struct TutorialUserDefaultsStorage {
    private let userDefaults: UserDefaults
    private let showedPrefix: String = "app.tutorial.module.showed."
    
    private let isDisabled: Bool
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        self.isDisabled = userDefaults.bool(forKey: "app.tutorial.is_tutorial_disabled")
    }
    
    private func keyForName(_ name: String) -> String {
        showedPrefix + name
    }
    
    public func reset(module: String) {
        userDefaults.removeObject(forKey: keyForName(module))
    }
}

extension TutorialUserDefaultsStorage: TutorialSavingStorage {
    public func isModuleShowed<Module: TutorialModularizable>(_ module: Module) -> Bool {
        isDisabled || userDefaults.bool(forKey: keyForName(module.name))
    }
    
    public func moduleEnded<Module: TutorialModularizable>(_ module: Module) {
        userDefaults.set(true, forKey: keyForName(module.name))
    }
}
