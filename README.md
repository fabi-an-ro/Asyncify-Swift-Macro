# Asyncify Swift Macro

**Asyncify** provides Swift macros for converting functions with trailing closures to async functions.

## Usage

With checked continuation:

```swift
@AsyncifyChecked
private func test1(a: Int, completion: @escaping (Int) -> Void) {
    // Your code here
}
```

```swift
@AsyncifyCheckedThrowing
private func test2(_ a: Int, b: Int, completion: (Result<Int, Error>) -> Void) {
    // Your code here
}
```

With unsafe continuation:

```swift
@AsyncifyUnsafe
private func test3(a: Int, completion: @escaping (Int) -> Void) {
    // Your code here
}
```

```swift
@AsyncifyUnsafeThrowing
private func test4(_ a: Int, b: Int, completion: (Result<Int, Error>) -> Void) {
    // Your code here
}
```

Calling the functions:

```swift
Task {
    let res1 = await test1(a: 10)
    let res2 = try? await test2(10)
...
}
```

## Installation

Using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/fabi-an-ro/Asyncify-Swift-Macro.git", from: "1.0.0")
]
```
