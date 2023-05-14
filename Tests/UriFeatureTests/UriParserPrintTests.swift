//
//  UriParserPrintTests.swift
//  
//
//  Created by MEI YIN LO on 2023/4/17.
//

import XCTest
@testable import UriFeature

final class UriParserPrintTests: XCTestCase {

    
    func testCornerCases()throws{
        //need to "manually" build the percent encoded query string when there is "+"
        //https://stackoverflow.com/questions/43052657/encode-using-urlcomponents-in-swift
        let str = "scheme://xx:yy@aaa:8080/abc?value=a+b, c"
        XCTAssertNil( URL(string: str) )
        XCTAssertNotNil( URLComponents(string: str) )
        
        let parserPrinter = try UriParserPrinter.parsePrint.parse(str)
        XCTAssertNotNil( parserPrinter.urlComponents )
        XCTAssertNotNil( parserPrinter.url )
        print(parserPrinter.url)//scheme://xx:yy@aaa:8080/abc?value=a+b,%20c
    }
    func testCornerCases_whitespace()throws{
        //need to "manually" build the percent encoded query string when there is "+"
        //https://stackoverflow.com/questions/43052657/encode-using-urlcomponents-in-swift
        let str = "scheme://xx:yy@aaa:8080/abc?value=a c"
        XCTAssertNil( URL(string: str) )
        XCTAssertNotNil( URLComponents(string: str) )
        print(URLComponents(string: str)?.url?.absoluteString) // "scheme://xx:yy@aaa:8080/abc?value=a%20c"
        
        let parserPrinter = try UriParserPrinter.parsePrint.parse(str)
        XCTAssertNotNil( parserPrinter.urlComponents )
        XCTAssertNotNil( parserPrinter.url )
        print(parserPrinter.url)
    }
    func testParse()throws{
        let str = "scheme://xx:yy@aaa:8080/abc?key=code"
        let parserPrinter = try UriParserPrinter.parsePrint.parse(str)
        assert(parserPrinter.urlComponents?.string == str)
    }
    
    func testPrint() throws{
        let scheme = "scheme"
        let host = "host"
        let user = "user"
        let pwd = "pwd"
        let path = "/path"
        let queryItems = [URLQueryItem(name: "key", value: "code"),URLQueryItem(name: "name", value: "test"),URLQueryItem(name: "ask", value: nil)]
        var urlcomponent = URLComponents()
        urlcomponent.scheme = scheme
        urlcomponent.host = host
        urlcomponent.path = path
        urlcomponent.user = user
        urlcomponent.password = pwd
        urlcomponent.queryItems = queryItems
        
        var parserPrinter = UriParserPrinter()
        parserPrinter.scheme = scheme[...]
        parserPrinter.host = host[...]
        parserPrinter.path = path[...]
        parserPrinter.user = user[...]
        parserPrinter.password = pwd[...]
        parserPrinter.queryItems = queryItems.map({
            UriParserPrinter.SubstringQueryItem(name: $0.name[...], value: $0.value?[...])
        })
        assert(parserPrinter.urlComponents! == urlcomponent)
        
    }
}
