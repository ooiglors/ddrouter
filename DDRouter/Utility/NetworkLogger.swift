import Foundation

class NetworkLogger {
    static func log(request: URLRequest) {

        let urlString = request.url?.absoluteString ?? ""
        let urlComponents = NSURLComponents(string: urlString)

        let method = request.httpMethod != nil
            ? "\(request.httpMethod!)"
            : ""
        let path = "\(urlComponents?.path ?? "")"
        let query = "\(urlComponents?.query ?? "")"
        let host = "\(urlComponents?.host ?? "")"

        var logOutput = """
                        \(urlString) \n\n
                        \(method) \(path)?\(query) HTTP/1.1 \n
                        HOST: \(host)\n
                        """
        for (key,value) in request.allHTTPHeaderFields ?? [:] {
            logOutput += "\(key): \(value) \n"
        }
        if let body = request.httpBody {
            logOutput += "\n \(NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "")"
        }

        print("\n - - - - - - - - - - OUTGOING - - - - - - - - - - \n")
        print(logOutput)
        print("\n - - - - - - - - - - - -  - - - - - - - - - - - - \n")
    }

    static func log(response: URLResponse) {
        guard let httpResponse = response as? HTTPURLResponse else {
            print("Not HTTP response.")
            print("MIME-TYPE: \(response.mimeType ?? "nil")")
            return
        }

        var logOutput = "\(httpResponse.statusCode)\n\n"
        httpResponse.allHeaderFields.forEach { logOutput += "\($0): \($1)\n" }

        print("\n - - - - - - - - - - INCOMING - - - - - - - - - - \n")
        print(logOutput)
        print("\n - - - - - - - - - - - -  - - - - - - - - - - - - \n")
    }
}
