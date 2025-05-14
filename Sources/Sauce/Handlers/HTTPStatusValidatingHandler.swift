//
//  HTTPStatusValidatingHandler.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import SimpleHTTPCore

/// Validates that the HTTP response status code falls within a given range.
public struct HTTPStatusValidatingHandler: HTTPHandler {
    /// The next handler in the chain.
    public var next: AnyHandler?
    
    /// The default acceptable status code range: 200–299.
    public static let defaultValidRange = 200..<300
    
    private let validStatusRange: Range<Int>

    /// Creates a status-validator handler.
    ///
    /// - Parameters:
    ///   - validStatusRange: The acceptable HTTP status codes.
    ///   - nextHandler: The next handler to invoke.
    public init(
        validStatusRange: Range<Int> = Self.defaultValidRange,
        nextHandler: AnyHandler? = nil
    ) {
        self.validStatusRange = validStatusRange
        self.next = nextHandler
    }
    
    /// Sends the request, then throws if the response status code is out of range.
    public func handle(request: Request) async throws(HTTPError) -> Response {
        let result = try await nextHandler.handle(request: request)
        
        guard validStatusRange.contains(result.response.statusCode) else {
            throw .init(
                code: .invalidStatus(result.status),
                request: result.request,
                response: result
            )
        }
        
        return result
    }
}

extension HTTPHandler where Self == HTTPStatusValidatingHandler {
    /// A default status-validator using 200–299.
    public static var httpStatusValidator: Self {
        HTTPStatusValidatingHandler()
    }
    
    /// Factory for a status-validating handler.
    ///
    /// - Parameter range: The acceptable status codes.
    public static func httpStatusValidator(in range: Range<Int> = Self.defaultValidRange) -> Self {
        HTTPStatusValidatingHandler(validStatusRange: range)
    }
}
