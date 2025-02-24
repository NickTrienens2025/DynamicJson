//
//  Untitled.swift
//  JSON
//
//  Created by Nick Trienens on 1/19/25.
//

import JSON
import XCTest

final class JSONRepairTests: XCTestCase {
    func testRepair() throws {
        let string = """
        kjashdfjlkhasdjkf
        ```json
        
        [ 
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 
        ]
        
        ```
        """
        let test = JSONStringRepair.removeComments(from: string)
        print(test)
        let json = try JSONStringRepair.createJson(from: test)
        print( json)
    }
    
    func testRepairTicks() throws {
        let string = """
        ```json
        [ 
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 
        ]
        ```
        """
        let test = JSONStringRepair.removeComments(from: string)
        print(test)
        let json = try JSONStringRepair.createJson(from: test)
        print( json)
    }
    
    func testRepairTicks2() throws {
        let string = """
        ```json
        [ 
        1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17 ]
        ```
        """
        let test = JSONStringRepair.removeComments(from: string)
        print(test)
        let json = try JSONStringRepair.createJson(from: test)
        print( json)
    }
}
