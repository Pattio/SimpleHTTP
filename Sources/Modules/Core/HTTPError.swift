//
//  HTTPError.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import Foundation

/// An error representing failure in the HTTP layer.
public struct HTTPError: Error {
    /// The high-level error code.
    public let code: Code
    
    /// The request that triggered the error.
    public let request: HTTPRequest
    
    /// The optional response, if one was received.
    public let response: HTTPResponse?
    
    /// An underlying error, if any.
    public let underlyingError: Error?
    
    /// Creates a new HTTP error.
    ///
    /// - Parameters:
    ///   - code: The error code.
    ///   - request: The original request.
    ///   - response: The response received, if any.
    ///   - underlyingError: Any lower-level error.
    public init(
        code: Code,
        request: HTTPRequest,
        response: HTTPResponse? = nil,
        underlyingError: Error? = nil
    ) {
        self.code = code
        self.request = request
        self.response = response
        self.underlyingError = underlyingError
    }

    /// The high-level error categories.
    public enum Code: Sendable {
        /// The request was invalid.
        case invalidRequest
        /// The response was invalid.
        case invalidResponse
        /// The status code was not acceptable.
        case invalidStatus(HTTPStatus)
        
        /// Configuration problem.
        case invalidConfiguration(reason: String)
        /// A URL‐level error.
        case urlError(code: URLError.Code)
        
        /// The request was cancelled.
        case cancelled
        /// An unknown error.
        case unknown
    }
}
