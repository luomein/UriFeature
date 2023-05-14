//
//  SwiftUIView.swift
//  
//
//  Created by MEI YIN LO on 2023/4/17.
//

import SwiftUI
import ComposableArchitecture

@available(macOS 11.0, *)
@available(iOS 15.0, *)
public struct UriQueryItemView: View {
    let store: StoreOf<UriQueryItemFeature>
    let readOnly : Bool
    public init(store: StoreOf<UriQueryItemFeature>, readOnly: Bool) {
        self.store = store
        self.readOnly = readOnly
    }
    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            HStack{
                if readOnly{
                    Text(viewStore.state.queryItem.name)
                }
                else{
                    TextField("name", text:viewStore.binding(get: { state in
                        state.queryItem.name
                    }, send: { value in
                        UriQueryItemFeature.Action.setName(value)
                    }))
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .multilineTextAlignment(.leading)
                }
                if readOnly{
                    Text(viewStore.state.queryItem.value ?? "")
                }
                else{
                    TextField("value", text:viewStore.binding(get: { state in
                        state.queryItem.value ?? ""
                    }, send: { value in
                        UriQueryItemFeature.Action.setValue(value)
                    }))
                    .autocorrectionDisabled(true)
                    .textInputAutocapitalization(.never)
                    .multilineTextAlignment(.trailing)
                }
            }
        }
    }
}
@available(macOS 11.0, *)
@available(iOS 15.0, *)
public struct UriView: View {
    let store: StoreOf<UriFeature>
    let readOnly : Bool
    @State var parsedValueDisclosureGroupIsExpand: Bool
    @State var rawValueDisclosureGroupIsExpand: Bool
    public init(store: StoreOf<UriFeature>, readOnly : Bool = false, parsedValueDisclosureGroupIsExpand: Bool = false
                , rawValueDisclosureGroupIsExpand: Bool = false) {
        self.store = store
        self.readOnly = readOnly
        self.parsedValueDisclosureGroupIsExpand = parsedValueDisclosureGroupIsExpand
        self.rawValueDisclosureGroupIsExpand = rawValueDisclosureGroupIsExpand
    }
    func getUrlComponent(uriKey: UriKey)-> some View{
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack{
                HStack{
                    Text(uriKey.rawValue)
                    if readOnly{
                        if uriKey.isPropertyOptional(){
                            Text( String(viewStore.state.uriParserPrinter[keyPath: uriKey.getKeyPathForOptionalSubstring()] ?? "") )
                        }
                        else{
                            Text( String(viewStore.state.uriParserPrinter[keyPath: uriKey.getKeyPathForNonOptionalSubstring()]) )
                        }
                    }
                    else{
                        TextField(uriKey.rawValue, text:viewStore.binding(get: { state in
                            if uriKey.isPropertyOptional(){
                                return String(state.uriParserPrinter[keyPath: uriKey.getKeyPathForOptionalSubstring()] ?? "")
                            }
                            else{
                                return String(state.uriParserPrinter[keyPath: uriKey.getKeyPathForNonOptionalSubstring()])
                            }
                        }, send: { value in
                            UriFeature.Action.setValueByKey(key: uriKey, value: value)
                        }))
                        .autocorrectionDisabled(true)
                        .textInputAutocapitalization(.never)
                        .multilineTextAlignment(.trailing)
                    }
                }
                HStack{
                    Spacer()
                    Text(viewStore.state.getErrorMessage(uriKey: uriKey) ?? "")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
    public var parsedValueDisclosureGroup : some View{
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            DisclosureGroup(isExpanded: $parsedValueDisclosureGroupIsExpand){
                getUrlComponent(uriKey: .scheme)
                getUrlComponent(uriKey: .host)
                getUrlComponent(uriKey: .user)
                getUrlComponent(uriKey: .password)
                getUrlComponent(uriKey: .port)
                getUrlComponent(uriKey: .path)
                DisclosureGroup {
                    ForEachStore(store.scope(state: \.items, action: UriFeature.Action.joinItemAction(id:action:))) { item in
                        UriQueryItemView(store: item, readOnly: readOnly)
                    }
                    .onDelete { viewStore.send(.deleteItemByIndexSet($0)) }
                    HStack{
                        Spacer()
                        Button {
                            viewStore.send(.addItem)
                        } label: {
                            
                                Text("+").font(.largeTitle)
                                
                        }
                        .buttonStyle(.plain)
                        //.contentShape(Rectangle())
                        EditButton()
                            .buttonStyle(.plain)
                        Spacer()
                    }

                }label: {
                    
                    Text("query items")
                        .badge(viewStore.state.urlQueryItems?.count ?? 0)
                    
                }
            } label: {
                HStack{
                    Text("Parsed Value")
                       
                    //.badge(Text(viewStore.state.absoluteURLStringValid ? "✔︎" : "✘"))
//                    if !viewStore.state.absoluteURLString.isEmpty{
//                        Text(viewStore.state.absoluteURLStringValid ? "✔︎" : "✘")
//                            .foregroundColor(viewStore.state.absoluteURLStringValid ? .green : .red)
//                    }
                    Spacer()
                }
            }
        }
    }
    public var rawValueDisclosureGroup : some View{
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            DisclosureGroup(isExpanded:$rawValueDisclosureGroupIsExpand) {
                if readOnly{
                    Text(viewStore.absoluteURLString)
                }
                else{
                    TextField("Raw Value", text: viewStore.binding(get: { state in
                        state.absoluteURLString
                    }, send: { value in
                        UriFeature.Action.setRaw(value)
                    }),axis: .vertical)
                    .lineLimit(3...10)
                }
            } label: {
                HStack{
                    Text("Raw Value")
                    //.badge(Text(viewStore.state.absoluteURLStringValid ? "✔︎" : "✘"))
                    if !viewStore.state.absoluteURLString.isEmpty{
                        Text(viewStore.state.absoluteURLStringValid ? "✔︎" : "✘")
                            .foregroundColor(viewStore.state.absoluteURLStringValid ? .green : .red)
                    }
                    Spacer()
                }
            }
        }
    }
    public var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Form {
                rawValueDisclosureGroup
                parsedValueDisclosureGroup
            }
        }
    }
}

@available(macOS 11.0, *)
@available(iOS 15.0, *)
struct UriView_Previews: PreviewProvider {
    static var store: StoreOf<UriFeature> = Store(initialState: .init(url: ""), reducer: UriFeature() )
    static var previews: some View {
        UriView(store: store)
    }
}
