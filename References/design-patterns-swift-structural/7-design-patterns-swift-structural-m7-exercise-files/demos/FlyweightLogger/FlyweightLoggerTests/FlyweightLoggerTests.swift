//
//  FlyweightLoggerTests.swift
//  FlyweightLoggerTests
//  Design Patterns in Swift: Structural
//
//  Created by Károly Nyisztor on 2017. 03. 05.
//

import XCTest
import os.log
@testable import FlyweightLogger

class FlyweightLoggerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testIsFlyweightUnique() {
        let subsystem = "com.pluralsight.test"
        let category = "UnitTest"
        if let logger = FlyweightLoggerFactory.shared.logger(subsystem: subsystem, category: category) {
            let logger2 = FlyweightLoggerFactory.shared.logger(subsystem: subsystem, category: category)
            XCTAssertTrue(logger === logger2, "Should be the same logger instance")
        } else {
            XCTFail("Could not instantiate logger")
        }
    }
    
}











