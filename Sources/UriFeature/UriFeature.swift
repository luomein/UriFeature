import Parsing
import ComposableArchitecture
import Foundation

extension UriFeature.State{
    func getErrorMessage(uriKey: UriKey)->String?{
        switch uriKey{
        case .path:
            return pathErrorMessage
        default:
            return nil
        }
    }
    var pathErrorMessage : String?{
        guard !uriParserPrinter.path.isEmpty else{
            return nil
        }
        if !uriParserPrinter.path.starts(with: "/"){
            return "path needs '/' prefix"
        }
        else{
            return nil
        }
    }
}
extension UriFeature.State{
    var absoluteURLStringValid : Bool{
        return uriParserPrinter.url?.absoluteString == absoluteURLString
    }
    var urlQueryItemsValid : Bool{
        return urlQueryItems == uriParserPrinter.urlComponents?.queryItems
    }
    var urlQueryItems : [URLQueryItem]?{
        guard !items.isEmpty else{
            return nil
        }
        let filtered = items.filter({$0.queryItem.name != ""})
        guard !filtered.isEmpty else{
            return nil
        }
        return filtered.map({
            $0.queryItem
        })
    }
}
struct UriFeature: ReducerProtocol{
    @Dependency(\.uuid) var uuid
    
    struct State: Equatable{
        
        var uriParserPrinter : UriParserPrinter
        var items : IdentifiedArrayOf<UriQueryItemFeature.State> = []
        var absoluteURLString : String
        
        public init(url: String, uuid: UUIDGenerator? = nil){
            self.absoluteURLString = url
            do{
                self.uriParserPrinter = try UriParserPrinter.parsePrint.parse(url)
                self.items = UriQueryItemFeature.getQueryItemsFromURLComponents(urlComponents: self.uriParserPrinter.urlComponents, uuid: uuid)
            }
            catch{
                fatalError()
            }
            
        }
        
    }
    
    enum Action: Equatable {
        case setRaw(String)
        case setValueByKey(key:UriKey, value:String)
        case joinItemAction(id:UriQueryItemFeature.State.ID,action:UriQueryItemFeature.Action)
        case addItem
        case deleteItem(id:UriQueryItemFeature.State.ID)
        case deleteItemByIndexSet(IndexSet)
    }
    func syncFromItems(items: IdentifiedArrayOf<UriQueryItemFeature.State>, uriParserPrinter: inout UriParserPrinter, absoluteURLString: inout String){
        let filtered = items.filter({$0.queryItem.name != ""})
        if !filtered.isEmpty{
            uriParserPrinter.queryItems = filtered.map({
                UriParserPrinter.SubstringQueryItem(name: $0.queryItem.name[...],value: $0.queryItem.value?[...])
            })
        }
        else{
            uriParserPrinter.queryItems = nil
        }
        absoluteURLString = uriParserPrinter.url?.absoluteString ?? ""
    }
    
    
    var body: some ReducerProtocol<State, Action> {
        Reduce { state, action in
            switch action{
            case .setRaw(let value):
                do{
                    state.absoluteURLString = value
                    state.uriParserPrinter = try UriParserPrinter.parsePrint.parse(value)
                    if state.urlQueryItems != state.uriParserPrinter.urlComponents?.queryItems{
                        state.items = UriQueryItemFeature.getQueryItemsFromURLComponents(urlComponents: state.uriParserPrinter.urlComponents,uuid: self.uuid)
                    }
                        
                }
                catch{fatalError()}
            case .setValueByKey(let key, let value):
                key.setValue(into: &state.uriParserPrinter, value: value)
                state.absoluteURLString = state.uriParserPrinter.url?.absoluteString ?? ""
            case .addItem:
                state.items.append(.init(queryItem: .init(name: "", value: nil), id: self.uuid() ))
            case .deleteItem(let id):
                state.items.remove(id: id)
                syncFromItems(items: state.items, uriParserPrinter: &state.uriParserPrinter, absoluteURLString: &state.absoluteURLString)
            case .deleteItemByIndexSet(let indexSet):
                for index in indexSet {
                  //state.todos.remove(id: filteredTodos[index].id)
                    state.items.remove(id: state.items[index].id)
                }
                syncFromItems(items: state.items, uriParserPrinter: &state.uriParserPrinter, absoluteURLString: &state.absoluteURLString)
            case .joinItemAction:
                syncFromItems(items: state.items, uriParserPrinter: &state.uriParserPrinter, absoluteURLString: &state.absoluteURLString)
            }
            
            return .none
        }
        
        .forEach(\.items, action: /Action.joinItemAction(id:action:)) {
            UriQueryItemFeature()
        }
        
    }
    
}

