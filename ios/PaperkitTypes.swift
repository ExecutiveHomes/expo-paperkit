import ExpoModulesCore

struct CanvasSizeConfig: Record {
  @Field var width: Double = 0
  @Field var height: Double = 0
}

struct FeatureSetConfig: Record {
  @Field var shapes: Bool = true
  @Field var textBoxes: Bool = true
  @Field var arrows: Bool = true
  @Field var signatures: Bool = true
  @Field var hdr: Bool = false
}

enum PaperkitError: Error, LocalizedError {
  case unsupportedPlatform
  case noMarkupData
  case exportFailed(String)
  case exportUnavailable

  var errorDescription: String? {
    switch self {
    case .unsupportedPlatform:
      return "PaperKit requires iOS 26.0 or macOS 26.0"
    case .noMarkupData:
      return "No markup data available"
    case .exportFailed(let message):
      return message
    case .exportUnavailable:
      return "Image export is not available on this platform"
    }
  }
}
