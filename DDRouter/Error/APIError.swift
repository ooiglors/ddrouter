import Foundation

// todo: figure out always usable APIErrorModel

// API Error Model for all non-auth and auth APIs.
public struct APIErrorResponseModel: Decodable {
    let errorResponse: APIErrorModel
}

public struct APIErrorModel: Decodable {
    let message: String
}

// todo: change this to correspond to normal status codes

/// An error type used by 'APIResponse' for the usual types of errors.
public enum APIError: Error {
    case
    // General (internal) errors
    serializeError,
    internalError,
    nullData,

    // 4xx Client errors
    badRequest(APIErrorModel?),
    unauthorized(APIErrorModel?),
    forbidden(APIErrorModel?),
    notFound,
    tooManyRequests,

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

