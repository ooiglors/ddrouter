import Foundation

public protocol NetworkEnvironment {
    var baseURL: String { get }
}

// example:
/*
enum MyNetworkEnvironment: NetworkEnvironment {
    case debug
    case uat
    case sit
    case prod

    var baseURL: String {
        get {
            switch self {
            case .debug:
                return ""
            default:
                return ""
            }
        }
    }
}
 */
