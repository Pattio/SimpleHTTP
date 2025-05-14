//
//  HTTPStatusValidatingHandlerTests.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import Testing
import SimpleHTTP

@Suite("HTTPStatusValidatingHandler")
struct StatusValidatorTests {
    @Test("Allows acceptable status codes")
    func testAllowsValidStatus() async throws {
        let okHandler = MockHTTPHandler(response: .mock(status: 204))
        let validator = HTTPStatusValidatingHandler(
            validStatusRange: 200..<300,
            nextHandler: okHandler
        )

        let response = try await validator.handle(request: .mock)
        #expect(response.status.rawValue == 204)
    }

    @Test("Rejects unacceptable status codes")
    func testRejectsInvalidStatus() async {
        let failingStatusCode = 500
        let failingHandler = MockHTTPHandler(
            response: .mock(status: failingStatusCode)
        )

        let validator = HTTPStatusValidatingHandler(nextHandler: failingHandler)

        let error = await #expect(throws: HTTPError.self) {
            _ = try await validator.handle(request: .mock)
        }
        
        guard case .invalidStatus(let status) = error?.code else {
            Issue.record("Expected .invalidStatus error code.")
            return
        }
        
        #expect(status == HTTPStatus(rawValue: failingStatusCode))
    }
}
