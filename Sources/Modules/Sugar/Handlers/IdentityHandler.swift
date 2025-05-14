//
//  IdentityHandler.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import SimpleHTTPCore

/// A no-op handler that simply forwards to the next handler.
struct IdentityHandler: HTTPHandler {
    var next: AnyHandler? = nil

    init() {}
    
    func handle(request: Request) async throws(HTTPError) -> Response {
        try await nextHandler.handle(request: request)
    }
}
