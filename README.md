# Asyncify Swift Macro

**Asyncify** provides Swift macros for converting functions with trailing closures to async functions.

## Usage

With checked continuation:

```swift
@AsyncifyChecked
private func test(a: Int, completion: @escaping (Int) -> Void) {
    // Your code here
}
```

```swift
@AsyncifyCheckedThrowing
func test(_ a: Int, b: Int, completion: (Result<Int, Error>) -> Void) {
    // Your code here
}
```

With unsafe continuation:

```swift
@AsyncifyUnsafe
private func test(a: Int, completion: @escaping (Int) -> Void) {
    // Your code here
}
```

```swift
@AsyncifyUnsafeThrowing
func test(_ a: Int, b: Int, completion: (Result<Int, Error>) -> Void) {
    // Your code here
}
```

## Installation

Using Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/fabi-an-ro/Asyncify-Swift-Macro.git", from: "1.0.0")
]
```
