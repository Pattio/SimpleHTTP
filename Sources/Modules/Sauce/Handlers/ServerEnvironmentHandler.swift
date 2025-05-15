//
//  ServerEnvironmentHandler.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import SimpleHTTPCore

/// Injects a `ServerEnvironment` into requests if none is set.
public struct ServerEnvironmentHandler: HTTPHandler {
    /// The next handler in the chain.
    public var next: AnyHandler?
    
    private let defaultEnvironment: ServerEnvironment

    /// Creates an environment-injecting handler.
    ///
    /// - Parameters:
    ///   - environment: The default environment to apply.
    ///   - nextHandler: The next handler to invoke.
    public init(
        environment: ServerEnvironment,
        nextHandler: AnyHandler? = nil
    ) {
        self.defaultEnvironment = environment
        self.next = nextHandler
    }
    
    /// Applies the environment and then forwards request to the next handler.
    public func handle(request: Request) async throws(HTTPError) -> Response {
        var requestCopy = request
        
        let environment = request.serverEnvironment ?? defaultEnvironment
        
        if requestCopy.host == nil || requestCopy.host?.isEmpty == true {
            requestCopy.host = environment.host
        }
        
        if requestCopy.path.hasPrefix("/") == false {
            let pathSeparator = environment.pathPrefix.hasSuffix("/") ? "" : "/"
            requestCopy.path = environment.pathPrefix + pathSeparator + requestCopy.path
        }
        
        for (header, value) in environment.headers {
            requestCopy.headers[header] = value
        }
        
        return try await nextHandler.handle(request: requestCopy)
    }
}

extension HTTPHandler where Self == ServerEnvironmentHandler {
    /// Factory for `ServerEnvironmentHandler`
    ///
    /// - Parameter serverEnvironment: The default environment to apply.
    public static func environment(_ serverEnvironment: ServerEnvironment) -> Self {
        ServerEnvironmentHandler(environment: serverEnvironment)
    }
}
