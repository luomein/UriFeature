//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/4/17.
//

import Foundation


enum UriKey{
    case scheme
    case user
    case password
    case host
    case port
    case path
    
    func getKeyPathForOptionalSubstring()->WritableKeyPath<UriParserPrinter,Substring?>{
        switch self{
        case .scheme:
            return \.scheme
        case .host:
            return \.host
        case .port:
            return \.port
        case .user:
            return \.user
        case .password:
            return \.password
        default:
            fatalError()
        }
    }
    
    func setValue(into uri: inout UriParserPrinter, value: String){
        let nilOrValue : Substring? = (value != "") ? value[...] : nil
        switch self{
        case .scheme,.host,.port,.user,.password:
            uri[keyPath: getKeyPathForOptionalSubstring()] = nilOrValue
        case .path:
            uri.path = value[...]

        default:
            fatalError()
        }
    }
}
