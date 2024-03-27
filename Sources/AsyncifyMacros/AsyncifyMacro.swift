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

public struct AsyncifyMacro: PeerMacro {
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
                        guard let paraType = parameter.type.as(IdentifierTypeSyntax.self)?.name else { return "" }

                        return "\(parameter.firstName): \(paraType)"
                    }.joined(separator: ", ")

                    let calledArgs = remainPara.map { "\($0.firstName): \($0.firstName)" }.joined(separator: ", ")

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

@main
struct AsyncifyPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        AsyncifyMacro.self
    ]
}