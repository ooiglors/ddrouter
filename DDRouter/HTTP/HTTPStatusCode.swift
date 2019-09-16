import Foundation

/** An enumeration of all HTTP status codes and their corresponding descriptions.
 */

// todo: should be all the status codes!
enum HTTPStatusCode: Int {
    // 2xx Success
    case ok = 200

    // 4xx Client error
    case badRequest = 400
    case unauthorized = 401
    case forbidden = 403
    case notFound = 404
    case tooManyRequests = 429

    // 5xx Server error
    case serverError = 500
}

//extension HTTPStatusCode {
//    static func isAuthorized(statusCode: Int) -> Bool {
//        return statusCode < HTTPStatusCode.unauthorized.rawValue
//            && statusCode >= HTTPStatusCode.ok.rawValue
//    }

//    static func is500Error(statusCode: Int) -> Bool {
//        return statusCode <= HTTPStatusCode.serverError.rawValue
//            && statusCode > HTTPStatusCode.unauthorized.rawValue
//    }
//}
