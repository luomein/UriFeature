//
//  UriKeyTests.swift
//  
//
//  Created by MEI YIN LO on 2023/4/17.
//
@testable import UriFeature
import XCTest


final class UriKeyTests: XCTestCase {
    
    @available(iOS 16.0, *)
    func testRe()throws{
        let user = "{name: Shane, id: 12.3, employee_id: 456}"
        let regex = #/name: \w+/#
        let regex1 = #/id: \d+/#
        let regex2 = #/[0-9]+/#
        //let regex3 = try Regex("[0-9]+")
        let regex3 = try Regex(regex2)
        if let match = user.firstMatch(of: regex) {
            assert(match.output == "name: Shane")
            print(match.output)
        }
        if let match = user.firstMatch(of: regex1) {
            assert(match.output == "id: 12",String(match.output))
            print(match.output)
        }
        if let match = user.firstMatch(of: regex2) {
            assert(match.output == "12",String(match.output))
            print(match.output)
        }
        if let match = user.firstMatch(of: regex3) {
            //assert(match.output == "12",String(match.output))
            print(match.output.extractValues(as: Any.self))
            print(match.output.extractValues(as: String.self))
        }
    }
    func testNilArrayAppend(){
        var ary : [String]? = nil
        ary?.append("test")
        assert(ary?.count == 0)
    }
    
    func test(){
        let test = UriKey.path
        assert(test.rawValue == "path")
    }
}
