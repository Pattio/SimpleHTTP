//
//  HTTPResponse+mock.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import Foundation
import SimpleHTTP

extension HTTPResponse {
    /// Creates a mock `HTTPResponse` with the given parameters.
    /// - Parameters:
    ///   - status: The HTTP status code to use. `200` by default.
    ///   - body: Optional body data.
    ///   - request: The originating request. Defaults to `.mock`.
    /// - Returns: A ready‑to‑use `HTTPResponse` instance.
    static func mock(
        status: Int = 200,
        body: Data? = nil,
        request: HTTPRequest = .mock
    ) -> HTTPResponse {
        let url = URL(string: "https://example.com\(request.path)")!
        let urlResponse = HTTPURLResponse(
            url: url,
            statusCode: status,
            httpVersion: nil,
            headerFields: nil
        )!
        
        return HTTPResponse(
            request: request,
            response: urlResponse,
            body: body
        )
    }
}
