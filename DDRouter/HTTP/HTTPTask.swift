import Foundation

public typealias HTTPHeaders = [String: String]

/// todo: this is probably not necessary - can replace with something less intrusive
public enum HTTPTask {
    case request

    case requestEncodableParameters(
        bodyParameters: Encodable?,
        urlParameters: Parameters?)

    // case download, upload...etc

    // this is where multipart requests will be in future
}
