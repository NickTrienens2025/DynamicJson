//
//  Untitled.swift
//  JSON
//
//  Created by Nick Trienens on 1/19/25.
//

import JSON
import XCTest

final class ResultBuilderJSONTests: XCTestCase {
    func testResultBuilder() throws {
 
        let json = JSON {
            "key1"
            1
            2
        }
        
        print(json)
        print(json[1])
        
    }
    
}
