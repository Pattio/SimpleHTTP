//
//  HTTPRequestOption.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

/// Defines a custom per-request option that can be stored in `HTTPRequest` using `HTTPRequestOption` subscript.
public protocol HTTPRequestOption: Sendable {
    /// The type of value this option carries.
    associatedtype Value: Sendable
    
    /// The default value when not explicitly set.
    static var defaultOptionValue: Value { get }
}
