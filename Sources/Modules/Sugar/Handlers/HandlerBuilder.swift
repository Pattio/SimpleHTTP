//
//  HandlerBuilder.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import SimpleHTTPCore

/// A result builder for composing multiple `HTTPHandler`s.
@resultBuilder
public enum HandlerBuilder {
    public typealias AnyHandler = HTTPHandler.AnyHandler
    
    public static func buildBlock(_ handlers: AnyHandler...) -> AnyHandler {
        handlers.chained() ?? IdentityHandler()
    }

    public static func buildOptional(_ component: AnyHandler?) -> AnyHandler {
        component ?? IdentityHandler()
    }

    public static func buildEither(first: AnyHandler) -> AnyHandler {
        first
    }
    
    public static func buildEither(second: AnyHandler) -> AnyHandler {
        second
    }
}
