//
//  HTTPClientTests.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import Testing
import SimpleHTTP

@Suite("HTTPClientTests")
struct HandlerChainTests {
    @Test("HandlerBuilder DSL stitches handlers in order")
    func testHandlerBuilderDSL() async throws {
        let client = HTTPClient {
            makeHandler(identifier: "first")
            makeHandler(identifier: "second")
            makeHandler(identifier: "third")
        }
        
        let firstHandler = client.handler
        let secondHandler = try #require(firstHandler.next)
        let thirdHandler = try #require(secondHandler.next)
        let fourthHandler = thirdHandler.next
        
        #expect(fourthHandler == nil)
        
        try assert(
            handler: firstHandler,
            identifier: "first"
        )
        
        try assert(
            handler: secondHandler,
            identifier: "second"
        )
        
        try assert(
            handler: thirdHandler,
            identifier: "third"
        )
    }
    
    @Test("Chain builder stitches handlers in order")
    func testChainedBuilder() async throws {
        let client = HTTPClient
            .start(with: makeHandler(identifier: "root"))
            .then(add: makeHandler(identifier: "1"))
            .then(add: makeHandler(identifier: "2"))
            .then(add: makeHandler(identifier: "3"))
        
        let rootHandler = client.handler
        let firstHandler = try #require(rootHandler.next)
        let secondHandler = try #require(firstHandler.next)
        let thirdHandler = try #require(secondHandler.next)
        let lastHandler = thirdHandler.next
        
        #expect(lastHandler == nil)
        
        try assert(
            handler: rootHandler,
            identifier: "root"
        )
        
        try assert(
            handler: firstHandler,
            identifier: "1"
        )
        
        try assert(
            handler: secondHandler,
            identifier: "2"
        )
        
        try assert(
            handler: thirdHandler,
            identifier: "3"
        )
    }
    
    @Test("HTTPClient sends requests through its handler")
    func testSendingRequest() async throws {
        let response = HTTPResponse.mock()
        let client = HTTPClient(
            handler: MockHTTPHandler(response: response)
        )
        
        let result = try await client.send(request: .mock)
        #expect(result.status.rawValue == response.status.rawValue)
    }
    
    func assert(
        handler: HTTPHandler.AnyHandler,
        identifier: String
    ) throws {
        let mockHandler = try #require(handler as? MockHTTPHandler)
        #expect(mockHandler.identifier == identifier)
    }
    
    private func makeHandler(
        identifier: String,
        next: HTTPHandler.AnyHandler? = nil
    ) -> HTTPHandler.AnyHandler {
        MockHTTPHandler(
            identifier: identifier,
            response: .mock()
        )
    }
}
