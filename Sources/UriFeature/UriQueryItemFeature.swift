//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/4/17.
//

import Foundation
import ComposableArchitecture

public struct UriQueryItemFeature:ReducerProtocol{
    
    public struct State: Equatable, Identifiable{
        public var queryItem : URLQueryItem
        public var id: UUID
    }
    public enum Action: Equatable {
        case setName(String)
        case setValue(String?)
    }
    public func reduce(into state: inout State, action: Action) ->EffectTask<Action> {
        switch action{
        case .setName(let value):
            state.queryItem.name = value
        case .setValue(let value):
            if let value = value, !value.isEmpty{
                state.queryItem.value = value
            }
            else{
                state.queryItem.value = nil
            }
        }
        return .none
    }
    static func getQueryItemsFromURLComponents(urlComponents: URLComponents?, uuid: UUIDGenerator? = nil)->IdentifiedArrayOf<UriQueryItemFeature.State>{
        if let queryItems = urlComponents?.queryItems{
            return IdentifiedArrayOf<UriQueryItemFeature.State>.init(uniqueElements:  queryItems.map({
                let id = (uuid != nil) ? uuid!() : UUID()
                return UriQueryItemFeature.State(queryItem: $0, id: id)
            })
            )
        }
        else{
            return []
        }
    }
}
