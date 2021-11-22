# TutorialManager

A tool for showing tutorial.

How to use:

- Create a tutorial module directly conforms `TutorialModularizable`, or using helper protocol `TutorialModuleStepMappable`. This will be used to map from target views to steps using keys.

```swift
struct DashboardTutorialModule: TutorialModuleStepMappable {
    enum Step: String {
        case revenue
    }
    
    typealias StepKey = Step
    
    var name: String {
        "dashboard"
    }
    
    var stepPairs: [StepPair] {
        [
            (.revenue, TutorialStep(descriptionTextPosition: .down,
                                    description: "Check your daily revenue here!"))
        ]
    }
}
```

- Add convenience init to `TutorialManager` to config common presenter options

```swift
extension TutorialManager {
    convenience init?(module: Module,
                      container: UIView?,
                      scrollView: UIScrollView? = nil) {
        guard let container = container else {
            print("Container view must not be nil")
            return nil
        }
        
        let presenter = TutorialPresenter<TutorialStepDescriptionView>(container: container,
                                                                       scrollView: scrollView)
        presenter.skipTitle = "Skip it!"
        presenter.nextTitle = "Next!"
        presenter.lastStepTitle = "I understand."
        
        let storage = TutorialUserDefaultsStorage()
        self.init(module: module, presenter: presenter, storage: storage)
    }
}
```

- Create instance of `TutorialManager` with above module, then start the tutorial with target views

```swift
// This instance should be retained somewhere
var tutorialManager: TutorialManager<DashboardTutorialModule>?

/// ...

tutorialManager = TutorialManager(module: .init(),
                                  container: self.view.window,
                                  scrollView: self.scrollView)

tutorialManager?.start(targets: [.revenue: self.revenueView])
```
