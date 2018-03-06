//
//  DownloaderTests.swift
//  DownloaderTests - Design Patterns in Swift: Structural
//
//  Created by Károly Nyisztor on 2017. 03. 05.
//

import XCTest
@testable import Downloader

class DownloaderTests: XCTestCase {
    var localURL: URL?
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        guard let documentsDirPath = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) else {
            XCTFail("Could not find Documents dir path")
            return
        }
        localURL = documentsDirPath.appendingPathComponent("image.png")
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        if let localURL = self.localURL {
            do {
                try FileManager.default.removeItem(at: localURL)
            } catch let deleteError {
                print("Failed to delete file \(localURL), reason \(deleteError)")
            }
        }        
        super.tearDown()
    }
    
    func testDownloadToFile() {
        let expect = expectation(description: "Download should succeed")
        
        if let url = URL(string: "https://devimages.apple.com.edgekey.net/assets/elements/icons/swift/swift-64x64.png"), let localURL = self.localURL {
            Downloader.download(from: url, to: localURL, completionHandler: { (response, error) in
                XCTAssertNil(error, "Unexpected error occured: \(error?.localizedDescription)")
                expect.fulfill()
            })
        }
        
        waitForExpectations(timeout: 10) { (error) in
            XCTAssertNil(error, "Test timed out. \(error?.localizedDescription)")
        }
    }
}
