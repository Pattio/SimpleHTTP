//
//  ServerEnvironmentHandlerTests.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import Testing
import SimpleHTTP

@Suite("ServerEnvironmentHandler")
struct ServerEnvironmentHandlerTests {
    @Test("Injects ServerEnvironment values")
    func testEnvironmentInjection() async throws {
        let environment = ServerEnvironment(
            host: "api.example.com",
            pathPrefix: "/v1",
            headers: ["Accept": "application/json"]
        )
        
        let responseHandler = MockHTTPHandler { request in
            .mock(request: request)
        }

        let environmentHandler = ServerEnvironmentHandler(
            environment: environment,
            nextHandler: responseHandler
        )

        let request = HTTPRequest(
            method: .get,
            path: "users"
        )
        
        let result = try await environmentHandler.handle(request: request)
        let sentRequest = result.request

        #expect(sentRequest.host == environment.host)
        #expect(sentRequest.path == "/v1/users")
        #expect(sentRequest.headers["Accept"] == "application/json")
        
        let url = try #require(sentRequest.url)
        #expect(url.absoluteString == "https://api.example.com/v1/users")
    }
}
