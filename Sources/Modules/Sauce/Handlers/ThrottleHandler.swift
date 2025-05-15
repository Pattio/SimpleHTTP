//
//  ThrottleHandler.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import SimpleHTTPCore

/// Limits the number of maximum in-flight requests.
public struct ThrottleHandler: HTTPHandler {
    /// The next handler in the chain.
    public var next: Handler?

    private let tokenBucket: TokenBucket
    
    /// Creates a throttler that allows up to `maxRequests` concurrently.
    ///
    /// - Parameters:
    ///   - maxRequests: The maximum in-flight requests permitted.
    ///   - nextHandler: The next handler to invoke.
    public init(
        maxRequests: Int,
        nextHandler: AnyHandler? = nil
    ) {
        assert(maxRequests > 0)
        self.tokenBucket = TokenBucket(tokens: maxRequests)
        self.next = nextHandler
    }

    /// Waits until a request slot is free, then forwards to the next handler.
    public func handle(request: Request) async throws(HTTPError) -> Response {
        try await tokenBucket.withToken { @Sendable () async throws(HTTPError) -> Response in
            try await nextHandler.handle(request: request)
        }
    }
}

extension HTTPHandler where Self == ThrottleHandler {
    /// Factory to create a `ThrottleHandler`.
    ///
    /// - Parameter maxRequests: The maximum in-flight requests permitted.
    public static func throttler(maxRequests: Int) -> Self {
        ThrottleHandler(maxRequests: maxRequests)
    }
}

// Adapted from: https://github.com/swiftlang/swift-package-manager/blob/main/Sources/Basics/Concurrency/TokenBucket.swift
fileprivate actor TokenBucket {
    private var tokens: Int
    private var waiters: [CheckedContinuation<Void, Never>]

    public init(tokens: Int) {
        self.tokens = tokens
        self.waiters = []
    }

    public func withToken<ReturnType: Sendable, ErrorType: Error>(
        body: @Sendable () async throws(ErrorType) -> ReturnType
    ) async throws(ErrorType) -> ReturnType {
        await getToken()
        
        defer {
            returnToken()
        }

        return try await body()
    }

    private func getToken() async {
        if tokens > 0 {
            return tokens -= 1
        }

        await withCheckedContinuation {
            waiters.append($0)
        }
    }

    private func returnToken() {
        guard waiters.count > 0 else {
            return
        }

        if waiters.count > 0 {
            waiters
                .removeFirst()
                .resume()
        } else {
            tokens += 1
        }
    }
}
