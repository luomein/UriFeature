//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/4/17.
//

import Foundation
import ComposableArchitecture

struct UriQueryItemFeature:ReducerProtocol{
    
    struct State: Equatable, Identifiable{
        var queryItem : URLQueryItem
        var id: UUID
    }
    enum Action: Equatable {
        case setName(String)
        case setValue(String?)
    }
    func reduce(into state: inout State, action: Action) ->EffectTask<Action> {
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
