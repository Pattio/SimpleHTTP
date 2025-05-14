//
//  HTTPBodyTests.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import Foundation
import SimpleHTTPCore
import Testing

@Suite("HTTPBody")
struct HTTPBodyTests {
    @Test("EmptyBody behaves as truly empty")
    func testEmptyBody() throws {
        let body = EmptyBody()
        #expect(body.isEmpty)
        #expect(body.additionalHeaders.isEmpty)

        let data = try body.encode(for: .mock)
        #expect(data.isEmpty)
    }
    
    @Test("JSONBody encodes value and sets header")
    func testJSONBody() throws {
        struct User: Codable, Sendable, Equatable {
            let id: Int
            let name: String
        }

        let user = User(
            id: 1,
            name: "Simple"
        )
        
        let encoder = JSONEncoder()
        let body = JSONBody(
            value: user,
            encoder: encoder
        )

        #expect(!body.isEmpty)
        #expect(body.additionalHeaders["Content-Type"] == "application/json")
        
        let bodyData = try body.encode(for: .mock)
        let encoderData = try encoder.encode(user)
        #expect(bodyData == encoderData)
    }
    
    @Test("FormBody percent-encodes correctly")
    func testFormBody() throws {
        let values = [
            "key1": "value1",
            "key2": "👍",
            "key3": "with space",
        ]
        let body = FormBody(values: values)
        let payload = String(
            decoding: try body.encode(for: .mock),
            as: UTF8.self
        )
        
        let parts = Set(payload.split(separator: "&").map(String.init))
        let expectedParts: Set<String> = [
            "key1=value1",
            "key2=%F0%9F%91%8D",
            "key3=with%20space",
        ]

        #expect(parts == expectedParts)
        #expect(body.additionalHeaders["Content-Type"] == "application/x-www-form-urlencoded")
    }
    
    @Test("DataBody mirrors the supplied Data and headers")
    func testDataBody() throws {
        let data = Data("raw".utf8)
        let headers = ["X-Foo": "bar"]
        let body = DataBody(
            data: data,
            additionalHeaders: headers
        )

        #expect(!body.isEmpty)
        #expect(body.additionalHeaders == headers)
        #expect(try body.encode(for: .mock) == data)
    }
}
