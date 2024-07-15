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

// MARK: - Public

public struct AsyncifyCheckedMacro: PeerMacro {
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        try createSyntax(providingPeersOf: declaration, isChecked: true)
    }
}

public struct AsyncifyCheckedThrowingMacro: PeerMacro {
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        try createThrowingSyntax(providingPeersOf: declaration, isChecked: true)
    }
}

public struct AsyncifyUnsafeMacro: PeerMacro {
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        try createSyntax(providingPeersOf: declaration, isChecked: false)
    }
}

public struct AsyncifyUnsafeThrowingMacro: PeerMacro {
    public static func expansion(of node: AttributeSyntax, providingPeersOf declaration: some DeclSyntaxProtocol, in context: some MacroExpansionContext) throws -> [DeclSyntax] {
        try createThrowingSyntax(providingPeersOf: declaration, isChecked: false)
    }
}

// MARK: - Fileprivate

fileprivate func createRemainingParameters(parameters: FunctionParameterListSyntax) -> (function: String, called: String) {
    let remainPara = FunctionParameterListSyntax(parameters.dropLast())

    let functionArgs = remainPara.map { parameter -> String in
        if let paraType = parameter.type.as(IdentifierTypeSyntax.self)?.name {
            if let defaultValue = parameter.defaultValue {
                return "\(parameter.firstName)\(parameter.secondName ?? ""): \(paraType)\(defaultValue)"
            }

            return "\(parameter.firstName)\(parameter.secondName ?? ""): \(paraType)"
        }

        if let closure = parameter.as(FunctionParameterSyntax.self)?.type {
            return "\(parameter.firstName)\(parameter.secondName ?? ""): \(closure)"
        }

        return ""
    }.joined(separator: ", ")

    let calledArgs = remainPara.map {
        "\($0.firstName): \($0.secondName?.text ?? $0.firstName.text)"
    }.joined(separator: ", ")

    return (functionArgs, calledArgs)
}

fileprivate func createSyntax(providingPeersOf declaration: some DeclSyntaxProtocol, isChecked: Bool) throws -> [DeclSyntax] {
    guard let functionDecl = declaration.as(FunctionDeclSyntax.self) else {
        throw AsyncifyError.onlyFunction
    }

    if let signature = functionDecl.signature.as(FunctionSignatureSyntax.self) {
        let parameters = signature.parameterClause.parameters

        if let completion = parameters.last {
            let completionTypeString = completion.type.description.replacingOccurrences(of: "@escaping ", with: "")

            if let completionType = TypeSyntax(stringLiteral: completionTypeString).as(FunctionTypeSyntax.self)?.parameters.first {
                let args = createRemainingParameters(parameters: parameters)
                let continuationString = isChecked ? "withCheckedContinuation"
                                                   : "withUnsafeContinuation"

                return [
                    """
                    \(functionDecl.modifiers)func \(functionDecl.name)(\(raw: args.function)) async -> \(completionType) {
                        await \(raw: continuationString) { continuation in
                            self.\(functionDecl.name)(\(raw: args.called)) { object in
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

fileprivate func createThrowingSyntax(providingPeersOf declaration: some DeclSyntaxProtocol, isChecked: Bool) throws -> [DeclSyntax] {
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
            let args = createRemainingParameters(parameters: parameters)
            let continuationString = isChecked ? "withCheckedThrowingContinuation"
                                               : "withUnsafeThrowingContinuation"

            return [
                    """
                    \(functionDecl.modifiers)func \(functionDecl.name)(\(raw: args.function)) async throws -> \(completionType) {
                        try await \(raw: continuationString) { continuation in
                            self.\(functionDecl.name)(\(raw: args.called)) { result in
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

@main
struct AsyncifyPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AsyncifyCheckedMacro.self,
        AsyncifyCheckedThrowingMacro.self,
        AsyncifyUnsafeMacro.self,
        AsyncifyUnsafeThrowingMacro.self
    ]
}
