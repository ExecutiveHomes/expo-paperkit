import SwiftUI
import ExpoModulesCore
import ExpoUI

final class ExpoPaperkitSwiftUIViewProps: UIBaseViewProps {
  @Field var title: String = ""
}

struct ExpoPaperkitSwiftUIView: ExpoSwiftUI.View {
  @ObservedObject public var props: ExpoPaperkitSwiftUIViewProps

  var body: some View {
    VStack {
      Text(props.title)
        .font(.headline)
      Children()
    }
  }
}
