//
//  File.swift
//  
//
//  Created by Alexander Weiß on 21.11.20.
//

import Foundation
import ConventionalCommits
import SwiftGit2


// MARK: - Changeset

/// A changeset represents a group of changes
struct ChangeSet {
    let changes: [Change]
    
    init(from commits: [Commit]) {
        self.changes = commits.map { .init(commit: $0)}
    }
}

// MARK: - Change

/// A change represents one change in the repository.
///
/// In this context a change is always tied to a git commit. If the commit message
/// conforms to the conventional commit specification this information is extracted.
struct Change {
    let commit: Commit
    let conventionalCommit: ConventionalCommit?
    
    init(commit: Commit) {
        self.commit = commit
        self.conventionalCommit = ConventionalCommit(data: commit.message)
    }
}

// MARK: Change + Conventional Commit
extension Change {
    var type: String? {
        return conventionalCommit?.type
    }
    
    var scope: String? {
        return conventionalCommit?.scope
    }
    
    var description: String? {
        return conventionalCommit?.description
    }
    
    var body: String? {
        return conventionalCommit?.body
    }
    
    var isBreaking: Bool {
        return conventionalCommit?.isBreaking ?? false
    }
    
    var contributor: Contributor {
        return Contributor(name: commit.author.name, email: commit.author.email)
    }
    
    struct Contributor {
        let name: String
        let email: String
    }
}


