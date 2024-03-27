//
//  Asyncify.swift
//  Asyncify
//
//  Created by Fabian Rottensteiner on 26.03.2024.
//

@attached(peer, names: overloaded)
public macro AsyncifyChecked() = #externalMacro(module: "AsyncifyMacros", type: "AsyncifyCheckedMacro")

@attached(peer, names: overloaded)
public macro AsyncifyCheckedThrowing() = #externalMacro(module: "AsyncifyMacros", type: "AsyncifyCheckedThrowingMacro")

@attached(peer, names: overloaded)
public macro AsyncifyUnsafe() = #externalMacro(module: "AsyncifyMacros", type: "AsyncifyUnsafeMacro")

@attached(peer, names: overloaded)
public macro AsyncifyUnsafeThrowing() = #externalMacro(module: "AsyncifyMacros", type: "AsyncifyUnsafeThrowingMacro")
