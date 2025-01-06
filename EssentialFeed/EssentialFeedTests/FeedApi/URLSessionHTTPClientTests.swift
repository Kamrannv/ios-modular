//
//  URLSessionHTTPClientTests.swift
//  EssentialFeedTests
//
//  Created by Kamran on 03.01.25.
//

import XCTest
import EssentialFeed

class URLSessionHTTPClient {
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedValuesRepresentation: Error {}
    
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
        session.dataTask(with: url) {data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data,  let response = response as? HTTPURLResponse{
                completion(.success(data, response))
            }
            else {
                completion(.failure(UnexpectedValuesRepresentation()))
            }
            
        }.resume()
    }
}
class URLSessionHTTPClientTests: XCTestCase {
    
    override class func setUp() {
        super.setUp()
        URLProtocolStub.startInterceptingRequest()
    }
    override class func tearDown() {
        super.tearDown()
        URLProtocolStub.stopInterceptingRequest()
    }
    
    func test_getFromURL_performsGETRequestWithURL() {
        let url = anyURl()
        let exp = expectation(description: "Wait for completion")
        
        URLProtocolStub.observeRequests { request in
            XCTAssertEqual(request.url, url)
            XCTAssertEqual(request.httpMethod, "GET")
            exp.fulfill()
        }
        
        makeSUT().get(from: url) { _ in }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getRequest_failsOnRequestError(){
        let requestError = anyNSError()
        let receivedError = resultErrorFor(data: nil, response: nil, error: requestError) as NSError?
        XCTAssertEqual(receivedError?.domain, requestError.domain)
        XCTAssertEqual(receivedError?.code, requestError.code)
    }
    
    func test_getRequest_failsOnAllNilRepresentationCases(){
        XCTAssertNotNil(resultErrorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nil, error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(resultErrorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
    
    func test_getFromURL_succeedsOnHTTPURLResponseWithData(){
        let data = anyData()
        let response = anyHTTPURLResponse()
        let receivedValues = resultSuccessFor(data: data, response: response, error: nil)
        XCTAssertEqual(receivedValues?.data, data)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
           
    }
    
    func test_getFromURL_succeedsWithEmptyDataOnHTTPURLResponseWithNilData(){
        let response = anyHTTPURLResponse()
        let receivedValues = resultSuccessFor(data: nil, response: response, error: nil)
        let emptyData = Data()
        XCTAssertEqual(receivedValues?.data, emptyData)
        XCTAssertEqual(receivedValues?.response.url, response.url)
        XCTAssertEqual(receivedValues?.response.statusCode, response.statusCode)
        
    }
    
    
    //MARK: Helpers
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func resultErrorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line)->Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let exp = expectation(description: "Wait for completion")
        let sut = makeSUT(file: file, line: line)
        var receivedError: Error?
        sut.get(from: anyURl()) { res in
            switch res {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("Expected failure, got \(res) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    private func resultSuccessFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #filePath, line: UInt = #line)->(data: Data?, response: HTTPURLResponse)?{
        URLProtocolStub.stub(data: data, response: response, error: error)
        let exp = expectation(description: "Wait for completion")
        let sut = makeSUT(file: file, line: line)
        
        var receivedValues: (data: Data?, response: HTTPURLResponse)?
        sut.get(from: anyURl()) { result in
            switch result {
            case let .success(data, response):
                receivedValues = (data, response)
            default:
                XCTFail("Expected success, got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
        return receivedValues
    }
    
    private func anyURl()->URL {
        return URL(string: "http://url.com")!
    }
    private func anyData()->Data {
        return Data("any data".utf8)
    }
    private func anyNSError()->NSError {
        return NSError(domain: "any error", code: 0, userInfo: nil)
    }
    private func nonHTTPURLResponse()->URLResponse {
        return URLResponse(url: anyURl(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    private func anyHTTPURLResponse()->HTTPURLResponse {
        return HTTPURLResponse(url: anyURl(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    private class URLProtocolStub: URLProtocol{
        private static var stub: Stub?
        private static var requestObserver: ((URLRequest)->Void)?
        private struct Stub {
            let data: Data?
            let response: URLResponse?
            let error: Error?
        }
        
        static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequest(){
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequest(){
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            requestObserver = nil
        }
        
        static func observeRequests(observer: @escaping (URLRequest)->Void){
            requestObserver = { request in
                observer(request)
                // Unset the observer after the first call to prevent multiple fulfillments
                URLProtocolStub.requestObserver = nil
            }
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            return  true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            requestObserver?(request)
            return request
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = URLProtocolStub.stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {
            
        }
    }
    
    
}
