//
//  ServerEnvironment.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import Foundation
import SimpleHTTPCore

/// Configuration for the target server.
public struct ServerEnvironment: Sendable {
    /// The server host (e.g. `"api.example.com"`).
    public var host: String
    
    /// A prefix to prepend to all request paths.
    public var pathPrefix: String
    
    /// Default headers to include on every request.
    public var headers: [String: String]

    /// Initializes a new environment.
    ///
    /// - Parameters:
    ///   - host: The server host.
    ///   - pathPrefix: A path segment to prepend.
    ///   - headers: Default headers.
    public init(
        host: String,
        pathPrefix: String = "/",
        headers: [String: String] = [:]
    ) {
        let prefix = pathPrefix.hasPrefix("/") ? "" : "/"

        self.host = host
        self.pathPrefix = prefix + pathPrefix
        self.headers = headers
    }
}

extension ServerEnvironment: HTTPRequestOption {
    /// By default, no environment is applied to a request.
    public static let defaultOptionValue: ServerEnvironment? = nil
}

extension HTTPRequest {
    /// An optional `ServerEnvironment` to apply when sending this request.
    public var serverEnvironment: ServerEnvironment? {
        get { self[option: ServerEnvironment.self] }
        set { self[option: ServerEnvironment.self] = newValue }
    }
}
