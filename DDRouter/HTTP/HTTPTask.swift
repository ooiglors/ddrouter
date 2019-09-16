import Foundation

public typealias HTTPHeaders = [String: String]

/// todo: this is not necessary
public enum HTTPTask {
    case request

    case requestEncodableParameters(
        bodyParameters: Encodable?,
        urlParameters: Parameters?)

    // case download, upload...etc
}
