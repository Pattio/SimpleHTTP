//
//  LoggingHandler.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import os
import Foundation
import SimpleHTTPCore

/// Logs each request start, completion, or error with timing information.
public struct LoggingHandler: HTTPHandler {
    /// The next handler in the chain.
    public var next: AnyHandler?
    
    private let logger: Logger
    private let durationFormatter = Duration.UnitsFormatStyle.units(
        allowed: [.seconds, .milliseconds],
        width: .narrow
    )
    
    /// Creates a logging handler.
    ///
    /// - Parameters:
    ///   - logger: The logger to use.
    ///   - nextHandler: The next handler to invoke.
    public init(
        logger: Logger = .init(
            subsystem: "SimpleHTTP",
            category: String(describing: Self.self)
        ),
        nextHandler: AnyHandler? = nil
    ) {
        self.logger = logger
        self.next = nextHandler
    }
    
    /// Logs request start, end, or error around the next handler.
    public func handle(request: Request) async throws(HTTPError) -> Response {
        logStart(request: request)
        
        let start = ContinuousClock.now
        do {
            let result = try await nextHandler.handle(request: request)
            let duration = ContinuousClock.now - start
            
            logEnd(
                request: result.request,
                response: result,
                duration: duration
            )
            
            return result
        } catch {
            let duration = ContinuousClock.now - start
            
            logError(
                error: error,
                duration: duration
            )
            
            throw error
        }
    }
    
    private func logStart(request: Request) {
        logger.info(
            """
            ➡️  [\(request.method.rawValue)]
            \(request.prettyURL)
            ID: \(request.id.uuidString)
            """
        )
    }
    
    private func logEnd(
        request: Request,
        response: Response,
        duration: Duration
    ) {
        logger.info(
            """
            ⬅️  [\(request.method.rawValue)] \(response.status.rawValue)
            \(request.prettyURL)
            ID: \(request.id.uuidString)
            Duration: \(duration.formatted(durationFormatter))
            """
        )
    }
    
    private func logError(
        error: HTTPError,
        duration: Duration
    ) {
        logger.error(
            """
            ❌  [\(error.request.method.rawValue)]
            \(error.request.prettyURL)
            ID: \(error.request.id.uuidString)
            Duration: \(duration.formatted(durationFormatter))
            Error: \(error.localizedDescription)
            """
        )
    }
}

extension HTTPHandler where Self == LoggingHandler {
    /// A default logging handler.
    public static var logger: Self {
        LoggingHandler()
    }
    
    /// Factory to create a `LoggingHandler`.
    ///
    /// - Parameter logger: The logger to use.
    public static func logger(with logger: Logger) -> Self {
        LoggingHandler(logger: logger)
    }
}

extension HTTPHandler.Request {
    fileprivate var prettyURL: String {
        url?.absoluteString ?? "Invalid URL"
    }
}
