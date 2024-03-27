//
//  Asyncify.swift
//  Asyncify
//
//  Created by Fabian Rottensteiner on 26.03.2024.
//

@attached(peer, names: overloaded)
public macro Asyncify() = #externalMacro(module: "AsyncifyMacros", type: "AsyncifyMacro")

@attached(peer, names: overloaded)
public macro AsyncifyThrowing() = #externalMacro(module: "AsyncifyMacros", type: "AsyncifyThrowingMacro")
