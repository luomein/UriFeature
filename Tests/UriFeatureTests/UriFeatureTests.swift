import XCTest
@testable import UriFeature
import Parsing
import ComposableArchitecture

final class UriFeatureTests: XCTestCase {
    
    func getTestStore(initString: String)->TestStore<UriFeature.State, UriFeature.Action, UriFeature.State, UriFeature.Action, ()>{
        let reducer = UriFeature()
        let testStore : TestStore = withDependencies {
            $0.uuid = .incrementing
        } operation: {
            TestStore(initialState: UriFeature.State(url: initString, uuid: reducer.uuid), reducer: reducer )
        }
        return testStore
    }
    
    @MainActor
    func testSetItems() async throws{
        let initString = "//test/?key"
        let testStore = getTestStore(initString: initString)
        assert(testStore.state.absoluteURLStringValid)
        assert(testStore.state.urlQueryItemsValid)
        
        let queryItem =  UriQueryItemFeature.State(queryItem: URLQueryItem(name: "key", value: "abc")
                                                   , id:  UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
        var newQueryItem =  UriQueryItemFeature.State(queryItem: URLQueryItem(name: "", value: nil)
                                                   , id:  UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)
        
        await testStore.send(.joinItemAction(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
                                                  , action: .setValue("abc"))){
            $0.items = [queryItem]
            $0.uriParserPrinter.queryItems = [.init(name: "key"[...],value: "abc"[...])]
            $0.absoluteURLString = "//test/?key=abc"
        }
        assert(testStore.state.absoluteURLStringValid)
        assert(testStore.state.urlQueryItemsValid)
        
        await testStore.send(.addItem){
            $0.items = [queryItem,newQueryItem]
        }
        assert(testStore.state.absoluteURLStringValid)
        assert(testStore.state.urlQueryItemsValid)
        
        newQueryItem.queryItem.name = "xx"
        await testStore.send(.joinItemAction(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
                                                  , action: .setName("xx"))){
            $0.items = [queryItem,newQueryItem]
            $0.uriParserPrinter.queryItems = [.init(name: "key"[...],value: "abc"[...]),.init(name: "xx"[...])]
            $0.absoluteURLString = "//test/?key=abc&xx"
        }
        assert(testStore.state.absoluteURLStringValid)
        assert(testStore.state.urlQueryItemsValid)
        
        await testStore.send(.deleteItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!)){
            $0.items = [queryItem]
            $0.uriParserPrinter.queryItems = [.init(name: "key"[...],value: "abc"[...])]
            $0.absoluteURLString = "//test/?key=abc"
        }
        assert(testStore.state.absoluteURLStringValid)
        assert(testStore.state.urlQueryItemsValid)
        
        await testStore.send(.deleteItem(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)){
            $0.items = []
            $0.uriParserPrinter.queryItems = nil
            $0.absoluteURLString = "//test/"
        }
        assert(testStore.state.absoluteURLStringValid)
        assert(testStore.state.urlQueryItemsValid)
    }
    
    @MainActor
    func testSetRaw() async throws{
        let initString = "//test"
        let testStore = getTestStore(initString: initString)

        assert(testStore.state.absoluteURLStringValid)
        assert(testStore.state.urlQueryItemsValid)

        
        let queryItem =  UriQueryItemFeature.State(queryItem: URLQueryItem(name: "key", value: nil)
                                                   , id:  UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
        
        await testStore.send(.setRaw("//test/?key")){
            
            $0.items = [queryItem]
            $0.uriParserPrinter.queryItems = [.init(name: "key"[...])]
            $0.uriParserPrinter.path = "/"
            $0.absoluteURLString = "//test/?key"
        }
        assert(testStore.state.absoluteURLStringValid)
        assert(testStore.state.urlQueryItemsValid)
        
    }
    @MainActor
    func testSetKeyValue() async throws{
        let initString = "//test"
        let testStore = getTestStore(initString: initString)
        assert(testStore.state.absoluteURLStringValid)
        testStore.dependencies.uuid = .incrementing
        
        await testStore.send(.setRaw("http://www.google.com/test")){
            $0.absoluteURLString = "http://www.google.com/test"
            $0.uriParserPrinter.scheme = "http"
            $0.uriParserPrinter.host = "www.google.com"
            $0.uriParserPrinter.path = "/test"
        }
        assert(testStore.state.absoluteURLStringValid)
        
        await testStore.send(.setValueByKey(key: .host, value: "apple")){
            $0.absoluteURLString = "http://apple/test"
            $0.uriParserPrinter.host = "apple"
        }
        assert(testStore.state.absoluteURLStringValid)
        
        await testStore.send(.setValueByKey(key: .port, value: "8080")){
            $0.absoluteURLString = "http://apple:8080/test"
            $0.uriParserPrinter.port = "8080"
        }
        assert(testStore.state.absoluteURLStringValid)
        
        await testStore.send(.setValueByKey(key: .user, value: "user")){
            $0.absoluteURLString = "http://user@apple:8080/test"
            $0.uriParserPrinter.user = "user"
        }
        assert(testStore.state.absoluteURLStringValid)
        
        await testStore.send(.setValueByKey(key: .password, value: "pwd")){
            $0.absoluteURLString = "http://user:pwd@apple:8080/test"
            $0.uriParserPrinter.password = "pwd"
        }
        assert(testStore.state.absoluteURLStringValid)
        
        await testStore.send(.setValueByKey(key: .scheme, value: "https")){
            $0.absoluteURLString = "https://user:pwd@apple:8080/test"
            $0.uriParserPrinter.scheme = "https"
        }
        assert(testStore.state.absoluteURLStringValid)
        
        await testStore.send(.setValueByKey(key: .path, value: "/newpath")){
            $0.absoluteURLString = "https://user:pwd@apple:8080/newpath"
            $0.uriParserPrinter.path = "/newpath"
        }
        assert(testStore.state.absoluteURLStringValid)
    }
}
