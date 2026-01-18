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
    
    @Test("Maps underlying error for invalid status codes")
    func testMapsUnderlyingErrorOnInvalidStatus() async {
        let failingStatusCode = 500
        let failingHandler = MockHTTPHandler(
            response: .mock(status: failingStatusCode)
        )

        let validator = HTTPStatusValidatingHandler(
            mapError: { _ in MappedError() },
            nextHandler: failingHandler
        )

        let error = await #expect(throws: HTTPError.self) {
            _ = try await validator.handle(request: .mock)
        }

        guard let underlyingError = error?.underlyingError else {
            Issue.record("Expected underlyingError to be set.")
            return
        }

        #expect((underlyingError as? MappedError) == MappedError())
    }
    
    @Test("Does not map underlying error for acceptable status codes")
    func testDoesNotMapUnderlyingErrorOnValidStatus() async throws {
        let okHandler = MockHTTPHandler(response: .mock(status: 204))

        let validator = HTTPStatusValidatingHandler(
            validStatusRange: 200..<300,
            mapError: { _ in
                Issue.record("mapError must not be invoked for acceptable status codes.")
                return MappedError()
            },
            nextHandler: okHandler
        )

        _ = try await validator.handle(request: .mock)
    }
}

fileprivate struct MappedError: Error, Equatable {}
