//
//  ThrottleHandlerTests.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import Testing
import SimpleHTTP

@Suite("ThrottleHandler")
struct ThrottleHandlerTests {
    @Test("Doesn't exceed maximum request limit")
    func testMaximumRequestLimit() async throws {
        let requestLimit = 2
        let numberOfConcurrentRequests = 10
        
        let counter = Counter()
        let handler = MockHTTPHandler { _ in
            await counter.enter()
            try? await Task.sleep(for: .milliseconds(1))
            await counter.leave()
            return .mock()
        }

        let throttled = ThrottleHandler(
            maxRequests: requestLimit,
            nextHandler: handler
        )

        try await withThrowingTaskGroup(of: Void.self) { group in
            for _ in 0..<numberOfConcurrentRequests {
                group.addTask {
                    _ = try await throttled.handle(request: .mock)
                }
            }
            try await group.waitForAll()
        }

        let observedPeak = await counter.peak
        #expect(observedPeak <= requestLimit)
    }
}

fileprivate actor Counter {
    private(set) var current = 0
    private(set) var peak = 0

    func enter() {
        current += 1
        peak = max(peak, current)
    }
    
    func leave() {
        current -= 1
    }
}
