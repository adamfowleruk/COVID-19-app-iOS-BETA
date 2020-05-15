//
//  LinkingIdManagerDouble.swift
//  SonarTests
//
//  Created by NHSX.
//  Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
@testable import Sonar

class LinkingIdManagerDouble: LinkingIdManaging {
    var fetchCompletion: ((LinkingId?) -> Void)?
    func fetchLinkingId(completion: @escaping (LinkingId?) -> Void = { _ in }) {
        fetchCompletion = completion
    }
}