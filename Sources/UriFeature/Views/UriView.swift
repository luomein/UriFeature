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
struct UriQueryItemView: View {
    let store: StoreOf<UriQueryItemFeature>
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            HStack{
                TextField("name", text:viewStore.binding(get: { state in
                    state.queryItem.name
                }, send: { value in
                    UriQueryItemFeature.Action.setName(value)
                }))
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
                .multilineTextAlignment(.leading)
                
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
@available(macOS 11.0, *)
@available(iOS 15.0, *)
struct UriView: View {
    let store: StoreOf<UriFeature>
    func getUrlComponent(uriKey: UriKey)-> some View{
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack{
                HStack{
                    Text(uriKey.rawValue)
                    
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
                HStack{
                    Spacer()
                    Text(viewStore.state.getErrorMessage(uriKey: uriKey) ?? "")
                        .foregroundColor(.red)
                        .multilineTextAlignment(.trailing)
                }
            }
        }
    }
    var parsedValueDisclosureGroup : some View{
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            DisclosureGroup {
                getUrlComponent(uriKey: .scheme)
                getUrlComponent(uriKey: .host)
                getUrlComponent(uriKey: .user)
                getUrlComponent(uriKey: .password)
                getUrlComponent(uriKey: .port)
                getUrlComponent(uriKey: .path)
                DisclosureGroup {
                    ForEachStore(store.scope(state: \.items, action: UriFeature.Action.joinItemAction(id:action:))) { item in
                        UriQueryItemView(store: item)
                    }
                    //
                    .onDelete { viewStore.send(.deleteItemByIndexSet($0)) }
                    
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
    var rawValueDisclosureGroup : some View{
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            DisclosureGroup {
                TextEditor(text: viewStore.binding(get: { state in
                    state.absoluteURLString
                }, send: { value in
                    UriFeature.Action.setRaw(value)
                }))
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
    var body: some View {
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