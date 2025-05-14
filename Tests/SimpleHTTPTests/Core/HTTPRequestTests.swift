//
//  HTTPRequestTests.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import Testing
import SimpleHTTP

@Suite("HTTPRequest")
struct HTTPRequestTests {
    @Test("URL composition reflects given data")
    func testURLComposition() throws {
        let request = HTTPRequest(
            method: .get,
            scheme: "http",
            host: "example.com",
            path: "/foo"
        )

        let url = try #require(request.url)
        #expect(url.absoluteString == "http://example.com/foo")
    }

    @Test("Request mutators reflect in composed URL")
    func testRequestMutation() {
        var request = HTTPRequest(
            method: .get,
            path: "/bar"
        )
        
        #expect(request.url?.host == nil)

        request.host = "my.api"
        #expect(request.url?.host == "my.api")

        request.path = "/v2/bar"
        #expect(request.url?.path == "/v2/bar")
    }

    @Test("Request persists option values")
    func testRequestOption() {
        var request = HTTPRequest(method: .get, path: "/")
        #expect(request[option: ToggleOption.self] == false)

        request[option: ToggleOption.self] = true
        #expect(request[option: ToggleOption.self] == true)
    }
}

fileprivate enum ToggleOption: HTTPRequestOption {
    static let defaultOptionValue = false
    
    typealias Value = Bool
}
