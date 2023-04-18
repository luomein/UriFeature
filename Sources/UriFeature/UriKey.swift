//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/4/17.
//

import Foundation


enum UriKey: String{
    case scheme
    case user
    case password
    case host
    case port
    case path
    
    enum URLComponentsKeyPathProperty{
        case OptionalString
        case OptionalInt
        case String
    }
    func getURLComponentsKeyPathProperty() -> URLComponentsKeyPathProperty{
        switch self{
        case .scheme, .host, .user, .password:
            return .OptionalString
        case .port:
            return .OptionalInt
        case .path:
            return .String
        }
    }
    func getKeyPathForStringUrlComponents()->WritableKeyPath<URLComponents,String>{
        switch self{
        case .path:
            return \.path
        default:
            fatalError()
        }
    }
    func getKeyPathForOptionalIntUrlComponents()->WritableKeyPath<URLComponents,Int?>{
        switch self{
        case .port:
            return \.port
        default:
            fatalError()
        }
    }
    func getKeyPathForOptionalStringUrlComponents()->WritableKeyPath<URLComponents,String?>{
        switch self{
        case .scheme:
            return \.scheme
        case .host:
            return \.host
        //case .port:
        //    return \.port
        case .user:
            return \.user
        case .password:
            return \.password
        default:
            fatalError()
        }
    }
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
    func getKeyPathForNonOptionalSubstring()->WritableKeyPath<UriParserPrinter,Substring>{
        switch self{
        case .path:
            return \.path
        default:
            fatalError()
        }
    }
    func isPropertyOptional()->Bool{
        switch self{
        case .scheme, .host, .port, .user, .password:
            return true
        case .path:
            return false
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
