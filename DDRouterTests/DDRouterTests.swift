//
//  DDRouterTests.swift
//  DDRouterTests
//
//  Created by Rigney, Will (AU - Sydney) on 13/9/19.
//  Copyright © 2019 Rigney, Will (AU - Sydney). All rights reserved.
//

import XCTest
@testable import DDRouter

import RxTest
import RxBlocking

class DDRouterTests: XCTestCase {

    var router: Router<TestEndpoint>?

    override func setUp() {
        self.router = Router<TestEndpoint>()
    }

    override func tearDown() {
        self.router = nil
    }

    // todo: tests for all the failure cases
    func testSuccess() {
        guard let response: ResponseModel = try? self.router?.request(.random)
            .toBlocking()
            .first() else {
                XCTFail()
                return
        }

        XCTAssert(response.author.count > 0)
        XCTAssert(response.en.count > 0)
    }
}
