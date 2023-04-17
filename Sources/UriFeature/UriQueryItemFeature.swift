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
            state.queryItem.value = value
        }
        return .none
    }
    static func getQueryItemsFromURLComponents(urlComponents: URLComponents?, uuid: UUIDGenerator)->IdentifiedArrayOf<UriQueryItemFeature.State>{
        if let queryItems = urlComponents?.queryItems{
            return IdentifiedArrayOf<UriQueryItemFeature.State>.init(uniqueElements:  queryItems.map({
                UriQueryItemFeature.State(queryItem: $0, id: uuid())
            })
            )
        }
        else{
            return []
        }
    }
}
