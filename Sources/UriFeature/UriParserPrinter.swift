//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/4/17.
//

import Foundation
import Parsing

public struct UriParserPrinter : Equatable{
    public var scheme : Substring?
    public var user : Substring?
    public var password : Substring?
    public var host : Substring?
    public var port : Substring?
    public var path : Substring = ""
    public var queryItems : [SubstringQueryItem]?
    
    public init(scheme: Substring? = nil ,
         authority : ( (Substring, Substring?)?,  Substring,  Substring? )? = nil ,
         path: Substring = "",
         queryItems: [SubstringQueryItem]? = nil
    )
    {
        self.scheme = scheme
        let userPassword = authority?.0
        self.user = userPassword?.0
        self.password = userPassword?.1
        self.host = authority?.1
        self.port = authority?.2
        self.path = path
        self.queryItems = queryItems
    }

    var url : URL?{
        do{
            let str = try UriParserPrinter.parsePrint.print(self)
            print(str)
            return URL(string: String.init(str)!)
        }
        catch{
            print(error)
            //fatalError()
            return nil
        }
    }
    var urlComponents : URLComponents?{
        if let url = url{
            return URLComponents(url: url, resolvingAgainstBaseURL: false)
        }
        return nil
    }

    private static let schemeParsePrint = ParsePrint(.substring) { Prefix { $0 != .init(ascii: ":") && $0 != .init(ascii: "/")} }
    private static let pathParsePrint = ParsePrint(.substring) { Prefix { $0 != .init(ascii: "?") } }
    private static let queryItemsParsePrint = ParsePrint(.substring) { Prefix { _ in true } }
    
    private static let userParsePrint = ParsePrint(.substring) { Prefix { $0 != .init(ascii: ":") && $0 != .init(ascii: "@") } }
    private static let passwordParsePrint = ParsePrint(.substring) { Prefix { $0 != .init(ascii: "@") } }

    private static let hostParsePrint = ParsePrint(.substring) { Prefix { $0 != .init(ascii: ":") && $0 != .init(ascii: "/")} }
    private static let portParsePrint = ParsePrint(.substring) { Prefix { $0 != .init(ascii: "/") } }
    
    private static let queryItemParsePrint = ParsePrint(.memberwise(SubstringQueryItem.init(name:value:))) {
        ParsePrint(.substring) { Prefix { $0 != .init(ascii: "=") } }
        Optionally {
            "=".utf8
            ParsePrint(.substring) { Prefix { $0 != .init(ascii: "&") } }
        }
    }
    public struct SubstringQueryItem: Equatable{
        public var name : Substring
        public var value : Substring?
    }
    
    /// If the NSURLComponents has an authority component (user, password, host or port) and a path component, then the path must either begin with "/" or be an empty string. If the NSURLComponents does not have an authority component (user, password, host or port) and has a path component, the path component must not start with "//". If those requirements are not met, nil is returned.
    static let parsePrint = Parse(.memberwise(UriParserPrinter.init(scheme:authority:path:queryItems:))) {
        Optionally {
            schemeParsePrint
            ":".utf8
        }
        Optionally{
            "//".utf8
            Optionally {
                userParsePrint
                Optionally {
                    ":".utf8
                    passwordParsePrint
                }
                "@".utf8
            }
            hostParsePrint
            Optionally {
                ":".utf8
                portParsePrint
            }
        }
        pathParsePrint
        Optionally {
            "?".utf8
            Many{
                queryItemParsePrint
            } separator: {
                "&".utf8
            }
//            terminator: {
//            End()
//            }
        }
    }
}
