//
//  HTTPRequest.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import Foundation

/// Represents an HTTP request.
public struct HTTPRequest: Sendable {
    /// A unique identifier for this request.
    public let id = UUID()
    
    /// The HTTP method (GET, POST, etc.).
    public let method: Method
    
    /// Custom headers to include.
    public var headers: [String: String]
    
    /// The body to send.
    public var body: HTTPBody
    
    private var options = [ObjectIdentifier: AnyHTTPRequestOption]()
    private var urlComponents = URLComponents()
    
    /// Creates a request.
    ///
    /// - Parameters:
    ///   - method: The HTTP method.
    ///   - scheme: URL scheme (e.g. "https").
    ///   - host: The host (e.g. "api.example.com").
    ///   - path: The URL path (e.g. "/v1/resource").
    ///   - headers: Initial headers.
    ///   - body: The request body.
    public init(
        method: Method,
        scheme: String = "https",
        host: String? = nil,
        path: String,
        headers: [String: String] = [:],
        body: HTTPBody = EmptyBody()
    ) {
        self.method = method
        self.headers = headers
        self.body = body
        
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.path = path
    }
    
    /// Common HTTP methods.
    public struct Method: Sendable {
        public static let get = Self(rawValue: "GET")
        public static let post = Self(rawValue: "POST")
        public static let put = Self(rawValue: "PUT")
        public static let delete = Self(rawValue: "DELETE")
        
        /// The raw string value (e.g. `"GET"`).
        public let rawValue: String
    }
    
    /// Per-request option access by type.
    ///
    /// Allows to pass custom options that can later be access from `HTTPHandler`.
    public subscript<Option: HTTPRequestOption>(option type: Option.Type) -> Option.Value {
        get {
            let id = ObjectIdentifier(type)

            guard let value = options[id]?.value as? Option.Value else {
                return type.defaultOptionValue
            }

            return value
        }
        set {
            let id = ObjectIdentifier(type)
            options[id] = AnyHTTPRequestOption(value: newValue)
        }
    }
}

extension HTTPRequest {
    /// The fully composed URL, if valid.
    public var url: URL? {
        urlComponents.url
    }
    
    /// The host component of the URL.
    public var host: String? {
        get { urlComponents.host }
        set { urlComponents.host = newValue }
    }
    
    /// The path component of the URL.
    public var path: String {
        get { urlComponents.path }
        set { urlComponents.path = newValue }
    }
}

fileprivate struct AnyHTTPRequestOption: @unchecked Sendable {
    let value: Any

    init<Value: Sendable>(value: Value) {
        self.value = value
    }
}
