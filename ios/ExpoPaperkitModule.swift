import ExpoModulesCore
import ExpoUI

public class ExpoPaperkitModule: Module {
  public func definition() -> ModuleDefinition {
    Name("ExpoPaperkit")

    Events("onChange")

    Constant("PI") {
      Double.pi
    }

    Function("hello") {
      return "Hello world! 👋"
    }

    AsyncFunction("setValueAsync") { (value: String) in
      self.sendEvent("onChange", [
        "value": value
      ])
    }

    View(ExpoPaperkitView.self) {
      Events("onTap")
    }

    Class(ExpoPaperkitModuleSharedObject.self) {
      Constructor { () -> ExpoPaperkitModuleSharedObject in
        return ExpoPaperkitModuleSharedObject()
      }

      Property("count") { (ref: ExpoPaperkitModuleSharedObject) -> Int in
        return ref.count
      }
      .set { (ref: ExpoPaperkitModuleSharedObject, count: Int) in
        ref.count = count
      }
    }

    ExpoUIView(ExpoPaperkitSwiftUIView.self)

    OnCreate {
      ViewModifierRegistry.register("expoPaperkitSwiftUIModifier") { params, appContext, _ in
        return try ExpoPaperkitSwiftUIModifier(from: params, appContext: appContext)
      }
    }

    OnDestroy {
      ViewModifierRegistry.unregister("expoPaperkitSwiftUIModifier")
    }
  }
}
