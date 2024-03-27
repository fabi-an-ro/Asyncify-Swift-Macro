//
//  AsyncifyError.swift
//  Asyncify
//
//  Created by Fabian Rottensteiner on 26.03.2024.
//

import Foundation

enum AsyncifyError: Error, CustomStringConvertible {
    case onlyFunction
    case wrongFunctionType
    case custom(_ msg: String)

    var description: String {
        switch self {
        case .onlyFunction:       "@Asyncify can be attached only to functions."
        case .wrongFunctionType:  "@Asyncify can only be used on functions with trailing closures."
        case .custom(let string): string
        }
    }
}
