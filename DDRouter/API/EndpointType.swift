import Foundation

public protocol EndpointType {
    var baseURL: URL { get }
    var path: String { get }
    var query: [String: String] { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
}
