//
//  HTTPHandler.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

/// A handler in a chain of HTTP handlers.
///
/// Conformers can modify or observe requests/responses and pass them along.
public protocol HTTPHandler: Sendable {
    typealias Request = HTTPRequest
    typealias Response = HTTPResponse
    typealias Handler = HTTPHandler
    typealias AnyHandler = any HTTPHandler
    
    /// The next handler in the chain.
    var next: Handler? { get set }
    
    /// Processes an HTTP request and returns a response.
    ///
    /// - Parameter request: The request to handle.
    /// - Throws: `HTTPError` on failure.
    /// - Returns: The HTTP response.
    func handle(request: Request) async throws(HTTPError) -> Response
}

extension HTTPHandler {
    /// Retrieves the next handler or throws if missing.
    ///
    /// - Throws: `HTTPError.invalidConfiguration` if `next` is `nil`.
    public var nextHandler: Handler {
        get throws(HTTPError) {
            guard let next else {
                throw .init(
                    code: .invalidConfiguration(reason: "Missing handler"),
                    request: .init(method: .get, path: "")
                )
            }
            
            return next
        }
    }
    
    /// Wraps a throwing async block to convert any error into an `HTTPError`.
    ///
    /// - Parameters:
    ///   - code: The error code to report.
    ///   - request: The request in flight.
    ///   - response: Optional response so far.
    ///   - body: The async block to execute.
    /// - Throws: `HTTPError` if `body` throws.
    /// - Returns: The block’s return value.
    public func withHTTPError<ReturnType: Sendable>(
        code: HTTPError.Code,
        request: Request,
        response: Response? = nil,
        body: @Sendable () async throws -> ReturnType
    ) async throws(HTTPError) -> ReturnType {
        do {
            return try await body()
        } catch {
            throw HTTPError(
                code: code,
                request: request,
                response: response,
                underlyingError: error
            )
        }
    }
}
