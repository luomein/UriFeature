//
//  UriKeyTests.swift
//  
//
//  Created by MEI YIN LO on 2023/4/17.
//
@testable import UriFeature
import XCTest

final class UriKeyTests: XCTestCase {

    
    func test(){
        let test = UriKey.path
        assert(test.rawValue == "path")
    }
}
