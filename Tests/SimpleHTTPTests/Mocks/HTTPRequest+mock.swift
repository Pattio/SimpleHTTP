//
//  HTTPRequest+mock.swift
//  SimpleHTTP
//
//  Created by Edvinas Byla on 14/05/2025.
//

import SimpleHTTP

extension HTTPRequest {
    static let mock = HTTPRequest(method: .get, path: "/mock")
}
