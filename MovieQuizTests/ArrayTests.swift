//
//  ArrayTests.swift
//  MovieQuizTests
//
//  Created by macOS on 28.10.2022.
//

import XCTest
@testable import MovieQuiz

class ArrayTests: XCTestCase {

    func testGetValueInRange() throws {
        let array = [1, 1, 2, 3, 5]
        
        let value = array[safe: 2]
        
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws {
        let array = [1, 1, 2, 3, 5]
        
        let value = array[safe: 20]
        
        XCTAssertNil(value)
    }

}
