import Foundation

// implement this protocol and pass implementation type as generic
// parameter to the router and APIError types
public protocol APIErrorModelProtocol: Decodable {}

// todo: change this to correspond to normal status codes

/// An error type usedor http
public enum APIError<APIErrorModel: APIErrorModelProtocol>: Error {
    case
    // General (internal) errors
    serializeError(Error?),
    internalError,
    nullData,

    // 4xx Client errors
    badRequest(APIErrorModel?),
    unauthorized(APIErrorModel?),
    forbidden(APIErrorModel?),
    notFound,
    other4xx(APIErrorModel?),
    tooManyRequests(APIErrorModel?),

    // 5xx Server errors
    serverError(APIErrorModel?),    // 500

    // Network/connection errors
    networkError,                   // Low level network problems, e.g. can't connect, timeouts
    insecureConnection,             // Thrown when NSURLSession detects security related network problems

    // Other errors
    logoutError,                    // Relogin failed, will be logged out directly

    // Unknown error
    unknownError                    // Catch all
}

