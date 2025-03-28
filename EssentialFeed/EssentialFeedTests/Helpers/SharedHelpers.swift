//
//  SharedHelpers.swift
//  EssentialFeed
//
//  Created by Kamran on 25.03.25.
//


import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}
