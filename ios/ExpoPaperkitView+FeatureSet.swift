#if canImport(PaperKit)
import PaperKit
import PencilKit

@available(iOS 26.0, macOS 26.0, *)
extension ExpoPaperkitView {

  func buildFeatureSet() -> FeatureSet {
    let config = featureSetConfig
    var featureSet: FeatureSet = .latest

    if !enableShapes {
      featureSet.remove(.shapeStrokes)
      featureSet.remove(.shapeFills)
    }

    if !enableTextBoxes {
      featureSet.remove(.text)
    }

    if !enableArrows {
      featureSet.shapes.remove(.arrowShape)
      featureSet.shapes.remove(.line)
      featureSet.lineMarkerPositions = []
    }

    if !enableHDR {
      featureSet.colorMaximumLinearExposure = 1.0
    }

    if let features = config.features {
      featureSet.features = Set(features.compactMap(Self.feature(named:)))
    }

    if let shapeTypes = config.shapeTypes {
      featureSet.shapes = Set(shapeTypes.compactMap(Self.shape(named:)))
    }

    if let inks = config.inks {
      featureSet.inks = Set(inks.compactMap(Self.ink(named:)))
    }

    if let positions = config.lineMarkerPositions {
      featureSet.lineMarkerPositions = Self.lineMarkerPositions(named: positions)
    }

    if let exposure = config.colorMaximumLinearExposure {
      featureSet.colorMaximumLinearExposure = CGFloat(exposure)
    }

    return featureSet
  }

  private static func feature(named name: String) -> FeatureSet.Feature? {
    switch name {
    case "images": return .images
    case "stickers": return .stickers
    case "loupes": return .loupes
    case "links": return .links
    case "shapeFills": return .shapeFills
    case "shapeStrokes": return .shapeStrokes
    case "shapeOpacity": return .shapeOpacity
    case "text": return .text
    case "drawing": return .drawing
    default: return nil
    }
  }

  private static func shape(named name: String) -> ShapeConfiguration.Shape? {
    switch name {
    case "rectangle": return .rectangle
    case "ellipse": return .ellipse
    case "line": return .line
    case "chatBubble": return .chatBubble
    case "roundedRectangle": return .roundedRectangle
    case "regularPolygon": return .regularPolygon
    case "star": return .star
    case "arrowShape": return .arrowShape
    default: return nil
    }
  }

  private static func ink(named name: String) -> PKInkingTool.InkType? {
    switch name {
    case "pen": return .pen
    case "pencil": return .pencil
    case "marker": return .marker
    case "monoline": return .monoline
    case "fountainPen": return .fountainPen
    case "watercolor": return .watercolor
    case "crayon": return .crayon
    case "reed": return .reed
    default: return nil
    }
  }

  private static func lineMarkerPositions(named names: [String]) -> FeatureSet.LineMarkerPositions {
    var positions: FeatureSet.LineMarkerPositions = []

    for name in names {
      switch name {
      case "plain": positions.insert(.plain)
      case "single": positions.insert(.single)
      case "double": positions.insert(.double)
      case "all": positions.insert(.all)
      default: break
      }
    }

    return positions
  }
}

#endif
