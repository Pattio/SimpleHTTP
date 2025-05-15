//
//  HTTPClient.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import SimpleHTTPCore

/// A high-level HTTP client that wraps a chain of `HTTPHandler`s.
public struct HTTPClient: Sendable {
    public typealias Handler = HTTPHandler
    public typealias AnyHandler = any HTTPHandler
    
    /// The head of the handler chain.
    public let handler: Handler
    
    /// Creates a client with a single handler.
    ///
    /// - Parameter handler: The first handler in the chain.
    public init(handler: Handler) {
        self.handler = handler
    }
    
    /// Creates a client by building a handler chain with a result builder.
    ///
    /// - Parameter handlerBuilder: A closure that returns a composed handler via
    ///   the `HandlerBuilder` DSL.
    public init(@HandlerBuilder using handlerBuilder: () -> Handler) {
        self.init(handler: handlerBuilder())
    }
    
    /// Convenience to start building a client.
    ///
    /// - Parameter handler: The first handler in the chain.
    /// - Returns: A new `HTTPClient`.
    public static func start(with handler: Handler) -> Self {
        HTTPClient(handler: handler)
    }
    
    /// Appends another handler to the end of the chain.
    ///
    /// - Parameter nextHandler: The handler to add.
    /// - Returns: A new `HTTPClient` whose chain includes `nextHandler`.
    @discardableResult
    public func then(add nextHandler: AnyHandler) -> HTTPClient {
        var handlers: [AnyHandler] = []
        
        var head: AnyHandler? = handler
        while let handler = head {
            handlers.append(handler)
            head = handler.next
        }
        
        handlers.append(nextHandler)
        
        return HTTPClient(
            handler: handlers.chained() ?? handler
        )
    }
    
    /// Sends a request through the handler chain.
    ///
    /// - Parameter request: The `HTTPRequest` to send.
    /// - Throws: An `HTTPError` if any handler fails.
    /// - Returns: The resulting `HTTPResponse`.
    @discardableResult
    public func send(request: HTTPHandler.Request) async throws(HTTPError) -> HTTPHandler.Response {
        try await handler.handle(request: request)
    }
    
    /// Sends a request through the handler chain.
    ///
    /// - Parameters:
    ///   - method: The HTTP method.
    ///   - scheme: URL scheme (e.g. "https").
    ///   - host: The host (e.g. "api.example.com").
    ///   - path: The URL path (e.g. "/v1/resource").
    ///   - headers: Initial headers.
    ///   - body: The request body.
    /// - Throws: An `HTTPError` if any handler fails.
    /// - Returns: The resulting `HTTPResponse`.
    @discardableResult
    public func send(
        method: HTTPRequest.Method,
        scheme: String = "https",
        host: String? = nil,
        path: String,
        headers: [String: String] = [:],
        body: HTTPBody = EmptyBody()
    ) async throws(HTTPError) -> HTTPHandler.Response {
        try await handler.handle(
            request: .init(
                method: method,
                scheme: scheme,
                host: host,
                path: path,
                headers: headers,
                body: body
            )
        )
    }
}
