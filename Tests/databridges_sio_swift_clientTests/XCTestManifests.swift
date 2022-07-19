import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(databridges_sio_swift_clientTests.allTests),
    ]
}
#endif
