//
//  main.swift
//  Asyncify
//
//  Created by Fabian Rottensteiner on 26.03.2024.
//

import Asyncify
import Foundation

struct Main {
    @Asyncify
    private func testAdd(a: Int, b: Int, completion: @escaping (Int) -> Void) {
        completion(a + b)
    }

    @discardableResult
    init() {
        test()
    }

    func test() {
        testAdd(a: 10, b: 20) { c in
            print("Closure result: \(c)")
        }

        Task {
            let c = await testAdd(a: 10, b: 20)

            print("Async result: \(c)")
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            print("Finished")
        }
    }
}

Main()
