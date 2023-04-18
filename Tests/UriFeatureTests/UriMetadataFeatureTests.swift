//
//  UriMetadataFeatureTests.swift
//  
//
//  Created by MEI YIN LO on 2023/4/18.
//

import XCTest
@testable import UriFeature
import ComposableArchitecture

final class UriMetadataFeatureTests: XCTestCase {

    func getTestStore()->TestStore<UriMetadataFeature.State, UriMetadataFeature.Action, UriMetadataFeature.State, UriMetadataFeature.Action, ()>{
        let reducer = UriMetadataFeature()
        let testStore : TestStore = withDependencies {
            $0.uuid = .incrementing
        } operation: {
            TestStore(initialState: UriMetadataFeature.State(), reducer: reducer )
        }
        return testStore
    }
    @MainActor
    func testSetItems() async throws{
        var queryItem = UriMetadataQueryItemFeature.State(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!)
        let testStore = getTestStore()
        await testStore.send(.addQueryItem){
            $0.queryItems = [queryItem]
        }
        queryItem.name = "test"
        await testStore.send(.joinQueryItemAction(id: queryItem.id, action: .setName("test"))){
            $0.queryItems = [queryItem]
        }
        queryItem.fieldDataType = .digit
        await testStore.send(.joinQueryItemAction(id: queryItem.id, action: .setFieldDataType(.digit))){
            $0.queryItems = [queryItem]
        }
        queryItem.defaultValue = "12354"
        await testStore.send(.joinQueryItemAction(id: queryItem.id, action: .setDefaultValue("12354.sdf3490"))){
            $0.queryItems = [queryItem]
        }
        print(testStore.state.defaultUrlComponents)
    }
}
