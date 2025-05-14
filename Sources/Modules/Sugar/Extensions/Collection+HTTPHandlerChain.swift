//
//  Collection+HTTPHandlerChain.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import SimpleHTTPCore

extension Collection where Element == HTTPHandler.AnyHandler {
    /// Chains an array of handlers into a linked list.
    ///
    /// - Returns: The head of the chain, or `nil` if empty.
    func chained() -> Element? {
        var head: Element? = nil
        for var handler in self.reversed() {
            handler.next = head
            head = handler
        }
        return head
    }
}
