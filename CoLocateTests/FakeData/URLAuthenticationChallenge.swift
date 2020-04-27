//
//  URLAuthenticationChallenge.swift
//  CoLocateTests
//
//  Created by NHSX.
//  Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

extension URLAuthenticationChallenge {
    static let example = URLAuthenticationChallenge(
        protectionSpace: .example,
        proposedCredential: nil,
        previousFailureCount: 0,
        failureResponse: nil,
        error: nil,
        sender: MockURLAuthenticationChallengeSender()
    )
}

private extension URLProtectionSpace {
    static let example = URLProtectionSpace(
        host: "example.com",
        port: 443,
        protocol: NSURLProtectionSpaceHTTPS,
        realm: nil,
        authenticationMethod: NSURLAuthenticationMethodServerTrust
    )
}

private class MockURLAuthenticationChallengeSender: NSObject, URLAuthenticationChallengeSender {
    
    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {
        
    }

    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {
        
    }
    
    func cancel(_ challenge: URLAuthenticationChallenge) {
        
    }
    
    func performDefaultHandling(for challenge: URLAuthenticationChallenge) {
        
    }
    
    func rejectProtectionSpaceAndContinue(with challenge: URLAuthenticationChallenge) {
        
    }

}