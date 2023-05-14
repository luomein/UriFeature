//
//  File.swift
//  
//
//  Created by MEI YIN LO on 2023/4/18.
//
import Parsing
import ComposableArchitecture
import Foundation

public struct UriMetadataQueryItemValueFeature: ReducerProtocol{
    public struct State: Equatable, Identifiable{
        public var id: UUID
        public var value : String = ""
        public var selected : Bool = false
    }
    public enum Action: Equatable {
        case switchSelected(Bool)
        case setValue(String)
    }
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action{
            case .setValue(let value):
                state.value = value
            case .switchSelected(let value):
                state.selected = value
            }
            return .none
        }
    }
}
public struct UriMetadataQueryItemFeature: ReducerProtocol{
    @Dependency(\.uuid) var uuid
    public struct State: Equatable, Identifiable{
        public var id: UUID
        public var name : String = ""
        public var required : Bool = false
        public var defaultValue : String = ""
        public var fieldDataType : UriMetadataFeature.FieldDataType = .string
        public var valueList : IdentifiedArrayOf<UriMetadataQueryItemValueFeature.State> = []
    }
    public enum Action: Equatable {
        case switchRequired(Bool)
        case setName(String)
        case setDefaultValue(String)
        case setFieldDataType(UriMetadataFeature.FieldDataType)
        case deleteValueList(IndexSet)
        case addValueList
        case joinValueListAction(id:UriMetadataQueryItemValueFeature.State.ID,action:UriMetadataQueryItemValueFeature.Action)
    }
    public var body: some ReducerProtocol<State, Action> {
        
        Reduce { state, action in
            switch action{
            case .switchRequired(let value):
                state.required = value
            case .setName(let value):
                state.name = value
            case .setDefaultValue(let value):
                state.defaultValue = state.fieldDataType.getRegexMatched(value: value)
                state.valueList = IdentifiedArray(uniqueElements:  state.valueList.map({
                    var item = $0
                    item.selected = false
                    return item
                }) )
                let filtered = state.valueList.filter({
                    $0.value == state.defaultValue
                })
                if !filtered.isEmpty{
                    state.valueList[id: filtered.first!.id]?.selected = true
                }
                
            case .setFieldDataType(let value):
                state.fieldDataType = value
                state.defaultValue = state.fieldDataType.getRegexMatched(value: state.defaultValue)
                state.valueList = IdentifiedArray(uniqueElements:  state.valueList.map({
                    var item = $0
                    item.value = state.fieldDataType.getRegexMatched(value: $0.value)
                    return item
                }) )
            case .deleteValueList(let indexSet):
                for index in indexSet {
                    state.valueList.remove(id: state.valueList[index].id)
                }
            case .addValueList:
                state.valueList.append(.init(id: self.uuid()))
            case .joinValueListAction(let id, let subAction):
                switch subAction{
                case .setValue(let value):
                    state.valueList[id: id]!.value = state.fieldDataType.getRegexMatched(value: value)
                    if state.valueList[id: id]!.selected{
                        state.defaultValue = state.valueList[id: id]!.value
                    }
                case .switchSelected(let value):
                    if value{
                        state.defaultValue = state.valueList[id: id]!.value
                    }
                    else{
                        state.defaultValue = ""
                    }
                default:
                    break
                }
            }
            return .none
        }
        .forEach(\.valueList, action: /Action.joinValueListAction(id:action:)) {
            UriMetadataQueryItemValueFeature()
        }
    }
}
public struct UriMetadataComponentFeature: ReducerProtocol{
    public struct State: Equatable, Identifiable{
        public var id: UUID
        public var uriKey : UriKey?
        public var required : Bool = false
        public var defaultValue : String = ""
        public var fieldDataType : UriMetadataFeature.FieldDataType = .string
    }
    public enum Action: Equatable {
        case switchRequired(Bool)
        case setDefaultValue(String)
        case setUriKey(UriKey)
        case setFieldDataType(UriMetadataFeature.FieldDataType)
    }
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action{
            case .setUriKey(let value):
                state.uriKey = value
                if state.uriKey == .port{
                    state.fieldDataType = .digit
                }
            case .switchRequired(let value):
                state.required = value
            case .setDefaultValue(let value):
                state.defaultValue = state.fieldDataType.getRegexMatched(value: value)
            case .setFieldDataType(let value):
                state.fieldDataType = value
            }
            return .none
        }
    }
}

public struct UriMetadataFeature: ReducerProtocol{
    @Dependency(\.uuid) var uuid
    
    public enum FieldDataType : Int{
        case digit = 0
        case string = 1
        
        func getRegexMatched(value: String)->String{
            switch self{
            case .string:
                return value
            case .digit:
                let regex = #/[0-9]+/#
                if let match = value.firstMatch(of: regex) {
                    return String(match.output)
                }
                return ""
            }
        }
    }
    public struct State: Equatable{
        var componentItems : IdentifiedArrayOf<UriMetadataComponentFeature.State> = []
        var queryItems : IdentifiedArrayOf<UriMetadataQueryItemFeature.State> = []
        
        var defaultUrlComponents : URLComponents{
            var urlcomponent = URLComponents()
            for component in componentItems{
                if component.uriKey != nil{
                    switch component.uriKey!.getURLComponentsKeyPathProperty(){
                    case .OptionalInt:
                        urlcomponent[keyPath: component.uriKey!.getKeyPathForOptionalIntUrlComponents()] = Int(component.defaultValue)
                    case .OptionalString:
                        urlcomponent[keyPath: component.uriKey!.getKeyPathForOptionalStringUrlComponents()] = component.defaultValue
                    case .String:
                        urlcomponent[keyPath: component.uriKey!.getKeyPathForStringUrlComponents()] = component.defaultValue
                    }
                    
                }
            }
            for item in queryItems{
                if item.name != ""{
                    urlcomponent.queryItems = urlcomponent.queryItems ?? []
                    urlcomponent.queryItems?.append(URLQueryItem(name: item.name, value: (item.defaultValue=="") ? nil : item.defaultValue ))
                }
            }
            return urlcomponent
        }
    }
    public enum Action: Equatable {
        case joinComponentItemAction(id:UriMetadataComponentFeature.State.ID,action:UriMetadataComponentFeature.Action)
        case joinQueryItemAction(id:UriMetadataQueryItemFeature.State.ID,action:UriMetadataQueryItemFeature.Action)
        case addComponentItem
        case addQueryItem
        case deleteComponentItem(IndexSet)
        case deleteQueryItem(IndexSet)
    }
    public var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action{
            case .addQueryItem:
                state.queryItems.append(.init(id: self.uuid()))
            case .addComponentItem:
                state.componentItems.append(.init(id: self.uuid()))
            case .deleteComponentItem(let indexSet):
                for index in indexSet {
                    state.componentItems.remove(id: state.componentItems[index].id)
                }
            case .deleteQueryItem(let indexSet):
                for index in indexSet {
                    state.queryItems.remove(id: state.queryItems[index].id)
                }
            case .joinComponentItemAction:
                break
            case .joinQueryItemAction:
                break
            }
            return .none
        }
        .forEach(\.componentItems, action: /Action.joinComponentItemAction(id:action:)) {
            UriMetadataComponentFeature()
        }
        .forEach(\.queryItems, action: /Action.joinQueryItemAction(id:action:)) {
            UriMetadataQueryItemFeature()
        }
    }
}
