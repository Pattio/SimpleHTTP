# SimpleHTTP

`SimpleHTTP` is a lightweight and composable HTTP client for Swift.

The goal of `SimpleHTTP` is to provide basic building blocks, a default implementation, and just enough syntactic sugar to make it actually fun to use.

The library consists of three modules:
1. [`SimpleHTTPCore`](#core) - The bare minimum core for building a custom underlying implementation.
2. [`SimpleHTTPSauce`](#sauce) - The basic implementation that provides default behavior.
3. [`SimpleHTTPSugar`](#sugar) - The syntactic sugar to simplify interaction with any implementation.

## Usage

```swift
import SimpleHTTP

let client = HTTPClient.start(with: .environment(.production))
    .then(add: .httpStatusValidator)
    .then(add: .throttler(maxRequests: 4))
    .then(add: .urlSession)

let result = try await client.send(
    request: .init(
        method: .get,
        path: "item-list"
    )
)
```

## Core 🍅

The core module provides only the primitives and basics. Import `SimpleHTTPCore` to build a fully custom stack with full control over request construction and execution. 

The three core building blocks are:
1. `HTTPRequest` - Defines how an HTTP request is constructed.
2. `HTTPResponse` - Defines how an HTTP response is represented.
3. `HTTPHandler` - Defines how requests and responses are processed in a chain.

The main abstraction is `HTTPHandler`, which enables modular and composable extensions to the request pipeline. A handler can intercept and modify outgoing requests, and inspect, transform, or validate incoming responses before passing them along the chain.

## Sauce 🥫

The sauce module offers a plug-and-play stack built on the core module, covering common needs. Even though it provides a default setup, it can be combined with custom handlers without any problem. For example, a custom logger can be dropped into the chain:

```swift
struct CustomLogger: HTTPHandler {
    var next: AnyHandler?
    
    func handle(request: Request) async throws(HTTPError) -> Response {
        print("About to execute a request. Feeling excited!")
        let result = try await nextHandler.handle(request: request)
        print("Finished executing the request. Excitement levels normalized.")
        return result
    }
}

let client = HTTPClient.start(with: .environment(.production))
    .then(add: CustomLogger())
    .then(add: .urlSession)
```

## Sugar 🍬

The sugar module provides syntactic enhancements to simplify usage. It can be used with any implementation, including fully custom stacks. 

Here’s an example using the DSL-style builder from `SimpleHTTPSugar`, compatible with any handler:

```swift
import SimpleHTTP

let client = HTTPClient {
    ServerEnvironmentHandler(environment: .production)
    
    #if DEBUG
    LoggingHandler()
    #endif
    
    URLSessionHandler(session: .shared)
}

let result = try await client.send(
    request: .init(
        method: .post,
        path: "item-list",
        body: JSONBody(value: Item(text: "Hello"))
    )
)
```

## Acknowledgements

`SimpleHTTP` is heavily based on ideas and code from the amazing [HTTP in Swift](https://davedelong.com/articles/http/) series by Dave DeLong.
