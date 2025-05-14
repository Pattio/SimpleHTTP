//
//  MockHTTPHandler.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import Foundation
import SimpleHTTPCore

struct MockHTTPHandler: HTTPHandler {
    var next: AnyHandler? = nil
    let identifier: String
    let handler: @Sendable (Request) async throws(HTTPError) -> Response

    init(
        next: AnyHandler? = nil,
        identifier: String = UUID().uuidString,
        handler: @escaping @Sendable (Request) async throws(HTTPError) -> Response
    ) {
        self.next = next
        self.identifier = identifier
        self.handler = handler
    }
    
    init(
        identifier: String = UUID().uuidString,
        response: Response
    ) {
        self.init(identifier: identifier) { _ in
            response
        }
    }

    func handle(request: Request) async throws(HTTPError) -> Response {
        try await handler(request)
    }
}
