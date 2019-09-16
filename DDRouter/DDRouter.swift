//
//  DDRouter.swift
//  DDRouter
//
//  Created by Rigney, Will (AU - Sydney) on 16/9/19.
//  Copyright © 2019 Will Rigney. All rights reserved.
//

import Foundation
import RxSwift

// todo: what is this doing
private class LocalURLSession {
    // private shared url session
    private let sharedInstance: URLSession

    // "LocalURLSession" singleton - todo: no singletons in library
    static let shared = LocalURLSession().sharedInstance

    private init() {
        let configuration = URLSessionConfiguration.default
        #if MOCK
//        DDMockProtocol.initialise(config: configuration)
        #endif
        sharedInstance = URLSession(configuration: configuration)
    }
}

// todo: move me
struct Empty: Decodable {}

public class Router<Endpoint: EndpointType> {

    public init() {}

    // https://medium.com/@danielt1263/retrying-a-network-request-despite-having-an-invalid-token-b8b89340d29

    // remove the isRelogin param
    // this returns a single that will always subscribe on a background thread
    // and observe on the main thread
    public func request<T: Decodable>(_ route: Endpoint, isRelogin: Bool = false) -> Single<T> {

        return Single.create { single in

            var task: URLSessionTask?

            // CASE: Serialization error.
            guard let request = try? self.buildRequest(from: route) else {
                single(.error(APIError.serializeError))
                return Disposables.create { task?.cancel() }
            }

            NetworkLogger.log(request: request)

            task = LocalURLSession.shared.dataTask(with: request) { data, response, error in

                // CASE: General internal error.
                if let error = error {
                    single(.error(error))
                    return
                }

                guard
                    let response = response as? HTTPURLResponse,
                    let responseData = data else {
                    single(.error(APIError.nullData))
                    return
                }

                // print response data
                #if DEBUG
                Router.printResponse(responseData: responseData)
                #endif

                // response switch
                switch response.statusCode {

                // CASE: 2xx Success.
                case 200...299:
                    // todo: this should be more clear
                    if responseData.isEmpty {
                        let empty = Empty() as! T
                        single(.success(empty))
                    }
                    else {
                        if let decodedResponse = try? JSONDecoder().decode(T.self, from: responseData) {
                            single(.success(decodedResponse))
                        }
                        else {
                            single(.error(APIError.serializeError))
                        }
                    }

                // CASE: 4xx Client errors.
                case 400...499:

                    // match the actual status code (or unknown error)
                    guard let statusCode = HTTPStatusCode(rawValue: response.statusCode) else {
                        single(.error(APIError.unknownError))
                        return
                    }

                    switch statusCode {

                    // Bad request.
                    case .badRequest:
                        let errorResponse = try? JSONDecoder().decode(
                            APIErrorResponseModel.self,
                            from: responseData)
                        single(.error(APIError.badRequest(errorResponse?.errorResponse)))

                    // Unauthorized.
                    case .unauthorized:
                        single(.error(APIError.unauthorized(nil)))
                        return
                        // todo: add back in autoretry, outside this function

                    // Resource not found.
                    case .notFound:
                        single(.error(APIError.notFound))

                    // Too many requests.
                    case .tooManyRequests:
                        single(.error(APIError.tooManyRequests))

                    // Forbidden
                    case .forbidden:
                        let errorResponse = try? JSONDecoder().decode(
                            APIErrorResponseModel.self,
                            from: responseData)
                        single(.error(APIError.forbidden(errorResponse?.errorResponse)))

                    default:
                        single(.error(APIError.unknownError))
                    }

                // CASE: 5xx Server error.
                case 500...599:
                    let errorResponse = try? JSONDecoder().decode(
                        APIErrorResponseModel.self,
                        from: responseData)
                    single(.error(APIError.serverError(errorResponse?.errorResponse)))

                // CASE: General network/connection error.
                default:
                    single(.error(APIError.unknownError))
                }
            }
            task?.resume()

            return Disposables.create {
                task?.cancel()
            }
        }
        .subscribeOn(SerialDispatchQueueScheduler(qos: .background))
        .observeOn(MainScheduler.instance)
    }

    private func buildRequest(from route: EndpointType) throws -> URLRequest {

        guard var urlComponents = URLComponents(
            url: route.baseURL.appendingPathComponent(route.path),
            resolvingAgainstBaseURL: true) else {
                throw APIError.internalError
        }

        // Build query
        if !route.query.isEmpty {
            let items = route.query.map { URLQueryItem(name: $0, value: $1) }
            urlComponents.queryItems = items
        }

        // get the url
        guard let url = urlComponents.url else {
            throw APIError.internalError
        }

        // create a request
        var request = URLRequest(
            url: url,
            cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
            timeoutInterval: 30.0)

        // method
        request.httpMethod = route.method.rawValue

        // headers
        if let additionalHeaders = route.headers {
            Router.addAdditionalHeaders(additionalHeaders, request: &request)
        }

        // content type
        if request.value(forHTTPHeaderField: "Content-Type") == nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        // encode parameters
        switch route.task {
        case .request:
            break

        case .requestEncodableParameters(
            let bodyParameters,
            let urlParameters):

            do {
                try ParameterEncoding.encode(
                    urlRequest: &request,
                    bodyParameters: bodyParameters,
                    urlParameters: urlParameters)
            }
            catch {
                // todo: consistent error logging!
                debugPrint("build request: \(error.localizedDescription)")
                throw error
            }
        }
        return request
    }

    private static func addAdditionalHeaders(
        _ additionalHeaders: HTTPHeaders?,
        request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }

    private static func printResponse(responseData: Data) {
        let jsonData = try? JSONSerialization.jsonObject(
            with: responseData,
            options: .mutableContainers)

        // todo: consistent error logging!
        print(jsonData ?? "----- Error in Json Response")
    }
}
