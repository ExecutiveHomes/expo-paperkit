package expo.modules.paperkit

import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition
import expo.modules.ui.ExpoUIView
import expo.modules.kotlin.records.recordFromMap
import expo.modules.ui.ModifierRegistry

class ExpoPaperkitModule : Module() {
  override fun definition() = ModuleDefinition {
    Name("ExpoPaperkit")

    Events("onChange")

    Constant("PI") {
      Math.PI
    }

    Function("hello") {
      "Hello world! 👋"
    }

    AsyncFunction("setValueAsync") { value: String ->
      sendEvent("onChange", mapOf(
        "value" to value
      ))
    }

    View(ExpoPaperkitView::class) {
      // Defines an event that the view can send to JavaScript.
      Events("onTap")
    }

    Class(ExpoPaperkitModuleSharedObject::class) {
      Constructor {
        val instance = ExpoPaperkitModuleSharedObject(appContext)
        return@Constructor instance
      }

      Property("count")
        .get { ref: ExpoPaperkitModuleSharedObject ->
          ref.count
        }
        .set { ref: ExpoPaperkitModuleSharedObject, count: Int ->
          ref.count = count
        }
    }

    ExpoUIView<ExpoPaperkitComposeViewProps>("ExpoPaperkitComposeView") {
      Content { props ->
        ExpoPaperkitComposeViewContent(props)
      }
    }

    OnCreate {
      ModifierRegistry.register("expoPaperkitComposeModifier") { params, _, _, _ ->
        recordFromMap<ExpoPaperkitComposeModifierParams>(params).toModifier()
      }
    }
  }
}
