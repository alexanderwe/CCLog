//
//  File.swift
//  
//
//  Created by Alexander Weiß on 21.11.20.
//

import Foundation
import SwiftGit2

/// Represents a mapping from a git tag to a specific version
/// and the corresponding changes made to the repository
struct Release {
    let version: Version
    let tag: TagReference
    let changeSet: ChangeSet
}

/// Represents a version
struct Version {
    let value: String
}
