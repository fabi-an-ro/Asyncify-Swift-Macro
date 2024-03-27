//
//  AsyncifyTests.swift
//  Asyncify
//
//  Created by Fabian Rottensteiner on 26.03.2024.
//

//import SwiftSyntaxMacros
//import SwiftSyntaxMacrosTestSupport
//import XCTest
//import AsyncifyMacros
//
//let testMacros: [String: Macro.Type] = [
//    "Asyncify" : AsyncifyMacro.self
//]
//
//final class TestMacroTests: XCTestCase {
//    func test() {
//        assertMacroExpansion(
//        """
//        @Asyncify
//        func test(arg1: String, completion: (String?) -> Void) {
//
//        }
//        """,
//        expandedSource: """
//
//        func test(arg1: String, completion: (String?) -> Void) {
//
//        }
//
//        func test(arg1: String) async -> String? {
//          await withCheckedContinuation { continuation in
//            self.test(arg1: arg1) { object in
//              continuation.resume(returning: object)
//            }
//          }
//        }
//        """,
//        macros: testMacros
//        )
//    }
//}
