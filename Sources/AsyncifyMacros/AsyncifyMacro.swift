//
//  AsyncifyMacro.swift
//  Asyncify
//
//  Created by Fabian Rottensteiner on 26.03.2024.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

public struct AsyncifyCheckedMacro: PeerMacro {
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let functionDecl = declaration.as(FunctionDeclSyntax.self) else {
            throw AsyncifyError.onlyFunction
        }

        if let signature = functionDecl.signature.as(FunctionSignatureSyntax.self) {
            let parameters = signature.parameterClause.parameters

            if let completion = parameters.last {
                let completionTypeString = completion.type.description.replacingOccurrences(of: "@escaping ", with: "")

                if let completionType = TypeSyntax(stringLiteral: completionTypeString).as(FunctionTypeSyntax.self)?.parameters.first {
                    let remainPara = FunctionParameterListSyntax(parameters.dropLast())

                    let functionArgs = remainPara.map { parameter -> String in
                        guard let paraType = parameter.type.as(IdentifierTypeSyntax.self)?.name else {
                            return ""
                        }

                        return "\(parameter.firstName)\(parameter.secondName ?? ""): \(paraType)"
                    }.joined(separator: ", ")

                    let calledArgs = remainPara.map {
                        guard let name = $0.firstName.text == "_" ? $0.secondName : $0.firstName else {
                            return ""
                        }

                        return "\($0.firstName): \(name)"
                    }.joined(separator: ", ")

                    return [
                    """
                    func \(functionDecl.name)(\(raw: functionArgs)) async -> \(completionType) {
                        await withCheckedContinuation { continuation in
                            self.\(functionDecl.name)(\(raw: calledArgs)) { object in
                                continuation.resume(returning: object)
                            }
                        }
                    }
                    """
                    ]
                }
            }
        }

        throw AsyncifyError.wrongFunctionType
    }
}

public struct AsyncifyCheckedThrowingMacro: PeerMacro {
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let functionDecl = declaration.as(FunctionDeclSyntax.self) else {
            throw AsyncifyError.onlyFunction
        }

        if let signature = functionDecl.signature.as(FunctionSignatureSyntax.self) {
            let parameters = signature.parameterClause.parameters

            if let completion = parameters.last {
                let completionTypeString = completion.type.description.replacingOccurrences(of: "@escaping ", with: "")
                let pattern = "Result<([^,]+),\\s*([^>]+)>"
                let range = NSRange(completionTypeString.startIndex..<completionTypeString.endIndex, in: completionTypeString)

                guard
                    let regex = try? NSRegularExpression(pattern: pattern),
                    let match = regex.firstMatch(in: completionTypeString, range: range),
                    let aRange = Range(match.range(at: 1), in: completionTypeString),
                    let bRange = Range(match.range(at: 2), in: completionTypeString)
                else {
                    throw AsyncifyError.notThrowing
                }

                let a = String(completionTypeString[aRange])
                let b = String(completionTypeString[bRange])

                let completionType = TypeSyntax(stringLiteral: a)
                let remainPara = FunctionParameterListSyntax(parameters.dropLast())

                let functionArgs = remainPara.map { parameter -> String in
                    guard let paraType = parameter.type.as(IdentifierTypeSyntax.self)?.name else {
                        return ""
                    }

                    return "\(parameter.firstName)\(parameter.secondName ?? ""): \(paraType)"
                }.joined(separator: ", ")

                let calledArgs = remainPara.map {
                    guard let name = $0.firstName.text == "_" ? $0.secondName : $0.firstName else {
                        return ""
                    }

                    return "\($0.firstName): \(name)"
                }.joined(separator: ", ")

                return [
                    """
                    func \(functionDecl.name)(\(raw: functionArgs)) async throws -> \(completionType) {
                        try await withCheckedThrowingContinuation { continuation in
                            self.\(functionDecl.name)(\(raw: calledArgs)) { result in
                                switch result {
                                case .success(let value):
                                    continuation.resume(returning: value)
                                case .failure(let error):
                                    continuation.resume(throwing: error)
                                }
                            }
                        }
                    }
                    """
                ]
            }
        }

        throw AsyncifyError.wrongFunctionType
    }
}

public struct AsyncifyUnsafeMacro: PeerMacro {
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let functionDecl = declaration.as(FunctionDeclSyntax.self) else {
            throw AsyncifyError.onlyFunction
        }

        if let signature = functionDecl.signature.as(FunctionSignatureSyntax.self) {
            let parameters = signature.parameterClause.parameters

            if let completion = parameters.last {
                let completionTypeString = completion.type.description.replacingOccurrences(of: "@escaping ", with: "")

                if let completionType = TypeSyntax(stringLiteral: completionTypeString).as(FunctionTypeSyntax.self)?.parameters.first {
                    let remainPara = FunctionParameterListSyntax(parameters.dropLast())

                    let functionArgs = remainPara.map { parameter -> String in
                        guard let paraType = parameter.type.as(IdentifierTypeSyntax.self)?.name else {
                            return ""
                        }

                        return "\(parameter.firstName)\(parameter.secondName ?? ""): \(paraType)"
                    }.joined(separator: ", ")

                    let calledArgs = remainPara.map {
                        guard let name = $0.firstName.text == "_" ? $0.secondName : $0.firstName else {
                            return ""
                        }

                        return "\($0.firstName): \(name)"
                    }.joined(separator: ", ")

                    return [
                    """
                    func \(functionDecl.name)(\(raw: functionArgs)) async -> \(completionType) {
                        await withUnsafeContinuation { continuation in
                            self.\(functionDecl.name)(\(raw: calledArgs)) { object in
                                continuation.resume(returning: object)
                            }
                        }
                    }
                    """
                    ]
                }
            }
        }

        throw AsyncifyError.wrongFunctionType
    }
}

public struct AsyncifyUnsafeThrowingMacro: PeerMacro {
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        guard let functionDecl = declaration.as(FunctionDeclSyntax.self) else {
            throw AsyncifyError.onlyFunction
        }

        if let signature = functionDecl.signature.as(FunctionSignatureSyntax.self) {
            let parameters = signature.parameterClause.parameters

            if let completion = parameters.last {
                let completionTypeString = completion.type.description.replacingOccurrences(of: "@escaping ", with: "")
                let pattern = "Result<([^,]+),\\s*([^>]+)>"
                let range = NSRange(completionTypeString.startIndex..<completionTypeString.endIndex, in: completionTypeString)

                guard
                    let regex = try? NSRegularExpression(pattern: pattern),
                    let match = regex.firstMatch(in: completionTypeString, range: range),
                    let aRange = Range(match.range(at: 1), in: completionTypeString),
                    let bRange = Range(match.range(at: 2), in: completionTypeString)
                else {
                    throw AsyncifyError.notThrowing
                }

                let a = String(completionTypeString[aRange])
                let b = String(completionTypeString[bRange])

                let completionType = TypeSyntax(stringLiteral: a)
                let remainPara = FunctionParameterListSyntax(parameters.dropLast())

                let functionArgs = remainPara.map { parameter -> String in
                    guard let paraType = parameter.type.as(IdentifierTypeSyntax.self)?.name else {
                        return ""
                    }

                    return "\(parameter.firstName)\(parameter.secondName ?? ""): \(paraType)"
                }.joined(separator: ", ")

                let calledArgs = remainPara.map {
                    guard let name = $0.firstName.text == "_" ? $0.secondName : $0.firstName else {
                        return ""
                    }

                    return "\($0.firstName): \(name)"
                }.joined(separator: ", ")

                return [
                    """
                    func \(functionDecl.name)(\(raw: functionArgs)) async throws -> \(completionType) {
                        try await withUnsafeThrowingContinuation { continuation in
                            self.\(functionDecl.name)(\(raw: calledArgs)) { result in
                                switch result {
                                case .success(let value):
                                    continuation.resume(returning: value)
                                case .failure(let error):
                                    continuation.resume(throwing: error)
                                }
                            }
                        }
                    }
                    """
                ]
            }
        }

        throw AsyncifyError.wrongFunctionType
    }
}

@main
struct AsyncifyPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AsyncifyCheckedMacro.self,
        AsyncifyCheckedThrowingMacro.self,
        AsyncifyUnsafeMacro.self,
        AsyncifyUnsafeThrowingMacro.self
    ]
}
