import Foundation

public typealias Parameters = [String: Any]

enum ParameterEncoding {
    // todo: move this somewhere else ?

    static func encode(
        urlRequest: inout URLRequest,
        bodyParameters: Encodable?,
        urlParameters: Parameters?) throws {

        if let urlParameters = urlParameters {
            guard let url = urlRequest.url else { throw NetworkError.encodingFailed }
            urlRequest.url = try ParameterEncoding.getEncodedURL(url: url, parameters: urlParameters)
        }

        if let bodyParameters = bodyParameters {
            urlRequest.httpBody = try ParameterEncoding.getEncoded(encodable: bodyParameters)
        }
    }

    ////
    
    // encoding functions // todo: make these more similar
    private static func getEncoded(encodable: Encodable) throws -> Data {
        guard let encoded = try? JSONEncoder().encode(AnyEncodable(encodable)) else {
            throw NetworkError.encodingFailed
        }
        return encoded
    }

    private static func getEncodedURL(url: URL, parameters: Parameters) throws -> URL {
        guard
            !parameters.isEmpty, // so what if they are? encode empty
            var urlComponents = URLComponents( // what does this do?
                url: url,
                resolvingAgainstBaseURL: false) else { throw NetworkError.encodingFailed }

        urlComponents.queryItems = parameters.map { key, value in
            let encodedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            return URLQueryItem(name: key, value: encodedValue)
        }

        guard let url = urlComponents.url else { throw NetworkError.encodingFailed }

        return url
    }
}
