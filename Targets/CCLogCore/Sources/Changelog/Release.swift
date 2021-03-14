//
//  File.swift
//  
//
//  Created by Alexander Weiß on 21.11.20.
//

import Foundation
import SwiftGit2
import SemanticVersioningKit

/// Represents a mapping from a git tag to a specific version
/// and the corresponding changes made to the repository
struct Release {
    let version: Version
    let tag: TagReference
    let changeSet: ChangeSet
    let date: Date    
}

/// Represents a version
struct Version {
    let value: String
    let semanticVersion: SemanticVersion?
    
    init(value: String) {
        self.value = value
        self.semanticVersion = SemanticVersion(data: value)
    }
}
