//
//  HTTPResponse.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import Foundation

/// Represents a received HTTP response.
public struct HTTPResponse: Sendable {
    /// The originating request.
    public let request: HTTPRequest
    
    /// The raw URL response.
    public let response: HTTPURLResponse
    
    /// The optional response body.
    public let body: Data?
    
    /// The HTTP status code.
    public var status: HTTPStatus {
        HTTPStatus(rawValue: response.statusCode)
    }
    
    /// Initializes an HTTP response.
    ///
    /// - Parameters:
    ///   - request: The request that generated this response.
    ///   - response: The `HTTPURLResponse`.
    ///   - body: Optional body data.
    public init(
        request: HTTPRequest,
        response: HTTPURLResponse,
        body: Data? = nil
    ) {
        self.request = request
        self.response = response
        self.body = body
    }
}

public struct HTTPStatus: Sendable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

extension HTTPStatus: Equatable {}
