//
//  URLSessionHandler.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import Foundation
import SimpleHTTPCore

/// Performs requests using `URLSession`.
///
/// This is a terminal handler. Place it last in your chain, as it does not forward to any subsequent handler.
/// Its `handle(request:)` method sends the request and returns a fully formed `HTTPResponse`.
public struct URLSessionHandler: HTTPHandler {
    /// Next handler that **will be ignored**. `URLSessionHandler` is the final handler in the chain.
    public var next: AnyHandler? = nil
    
    private let session: URLSession
    
    /// Creates a URLSession-driven handler.
    ///
    /// - Parameters:
    ///   - session: The `URLSession` to use.
    public init(session: URLSession) {
        self.session = session
    }
    
    /// Sends the request with `URLSession` and returns the resulting `HTTPResponse`.
    ///
    /// - Parameter request: The `HTTPRequest` to execute.
    /// - Throws: `HTTPError` if the request fails, is cancelled, or receives an invalid response.
    /// - Returns: An `HTTPResponse`.
    public func handle(request: Request) async throws(HTTPError) -> Response {
        try await withHTTPError(
            code: .cancelled,
            request: request
        ) {
            try Task.checkCancellation()
        }
        
        let urlRequest = try makeURLRequest(using: request)
        
        do {
            let (data, urlResponse) = try await session.data(for: urlRequest)
            guard let httpURLResponse = urlResponse as? HTTPURLResponse else {
                throw HTTPError(
                    code: .invalidResponse,
                    request: request,
                    response: nil,
                    underlyingError: nil
                )
            }
            
            return Response(
                request: request,
                response: httpURLResponse,
                body: data
            )
        } catch let urlError as URLError {
            throw HTTPError(
                code: .urlError(code: urlError.code),
                request: request,
                response: nil,
                underlyingError: urlError
            )
        } catch {
            throw HTTPError(
                code: .unknown,
                request: request,
                response: nil,
                underlyingError: error
            )
        }
    }
    
    private func makeURLRequest(using request: Request) throws(HTTPError) -> URLRequest {
        guard let url = request.url else {
            throw HTTPError(
                code: .invalidRequest,
                request: request
            )
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        
        if !request.body.isEmpty {
            for (header, value) in request.body.additionalHeaders {
                urlRequest.addValue(value, forHTTPHeaderField: header)
            }
            
            do {
                urlRequest.httpBody = try request.body.encode(for: request)
            } catch {
                throw .init(
                    code: .invalidRequest,
                    request: request,
                    response: nil,
                    underlyingError: error
                )
            }
        }
        
        return urlRequest
    }
}

extension HTTPHandler where Self == URLSessionHandler {
    /// A default handler using `URLSession.shared`.
    public static var urlSession: Self {
        Self(session: .shared)
    }
    
    /// Creates a handler with a custom session.
    ///
    /// - Parameter session: The `URLSession` to use.
    public static func urlSession(_ session: URLSession) -> Self {
        URLSessionHandler(session: session)
    }
}
