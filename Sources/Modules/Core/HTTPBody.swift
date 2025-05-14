//
//  HTTPBody.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import Foundation

/// A type that can serve as the body of an HTTP request.
public protocol HTTPBody: Sendable {
    /// Whether this body contains any data.
    var isEmpty: Bool { get }
    
    /// Any additional HTTP headers that should be added when this body is sent.
    var additionalHeaders: [String: String] { get }
    
    /// Encodes the body into `Data` for the given request.
    ///
    /// - Parameter request: The `HTTPRequest` that will carry this body.
    /// - Throws: An `HTTPError` if encoding fails.
    /// - Returns: The encoded body data.
    func encode(for request: HTTPRequest) throws -> Data
}

/// An empty request body. Useful for requests without a body.
public struct EmptyBody: HTTPBody {
    public let isEmpty = true
    public var additionalHeaders: [String: String] = [:]

    public init() {}

    /// Returns zero-length `Data`.
    public func encode(for request: HTTPRequest) throws -> Data {
        Data()
    }
}

/// A JSON-encoded request body.
public struct JSONBody: HTTPBody {
    public let isEmpty = false
    public var additionalHeaders = [
        "Content-Type": "application/json"
    ]
    
    private let dataFactory: @Sendable () throws -> Data

    /// Creates a JSON body from an `Encodable` value.
    ///
    /// - Parameters:
    ///   - value: The value to encode.
    ///   - encoder: The `JSONEncoder` to use for encoding.
    public init<Value: Encodable & Sendable>(
        value: Value,
        encoder: JSONEncoder = JSONEncoder()
    ) {
        self.dataFactory = {
            try encoder.encode(value)
        }
    }

    /// Encodes the wrapped value to JSON.
    public func encode(for request: HTTPRequest) throws -> Data {
        try dataFactory()
    }
}

/// A form-URL-encoded request body.
public struct FormBody: HTTPBody {
    public var isEmpty: Bool {
        queryItems.isEmpty
    }
    
    public let additionalHeaders = [
        "Content-Type": "application/x-www-form-urlencoded"
    ]
    
    private let queryItems: [URLQueryItem]

    /// Initializes with pre-built URL query items.
    public init(queryItems: [URLQueryItem]) {
        self.queryItems = queryItems
    }

    /// Initializes with a dictionary of string key–value pairs.
    public init(values: [String: String]) {
        self.queryItems = values.map { (key, value) in
            URLQueryItem(name: key, value: value)
        }
    }

    /// Percent-encodes the query items into `Data`.
    ///
    /// - Parameter request: The `HTTPRequest` being encoded.
    /// - Throws: `HTTPError.invalidRequest` if encoding fails.
    /// - Returns: The URL-encoded form data.
    public func encode(for request: HTTPRequest) throws -> Data {
        var components = URLComponents()
        components.queryItems = queryItems
        
        guard let percentEncodedQuery = components.percentEncodedQuery else {
            throw HTTPError(
                code: .invalidRequest,
                request: request
            )
        }
        return Data(percentEncodedQuery.utf8)
    }
}

/// A request body backed by raw `Data`.
public struct DataBody: HTTPBody {
    public var isEmpty: Bool {
        data.isEmpty
    }
    
    public var additionalHeaders: [String: String]
    
    private let data: Data
    
    /// Initializes with raw data and optional extra headers.
    ///
    /// - Parameters:
    ///   - data: The body data.
    ///   - additionalHeaders: Additional headers to attach.
    public init(
        data: Data,
        additionalHeaders: [String: String] = [:]
    ) {
        self.data = data
        self.additionalHeaders = additionalHeaders
    }
    
    /// Returns the raw data unmodified.
    public func encode(for request: HTTPRequest) throws -> Data {
        data
    }
}
