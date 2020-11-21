//
//  Changelog.swift
//  
//
//  Created by Alexander Weiß on 21.11.20.
//

import Foundation
import ConventionalCommits
import SwiftGit2


public struct ChangeLog {
    let releases: [Release]?
    let unreleased: ChangeSet?
}

extension ChangeLog {
        
    init(commits: [Commit], tags: [TagReference]) {
        
        var commits: [Commit] = commits.reversed()
        let tags: [TagReference] = tags.reversed()
        
        
        var foundReleases: [Release] = []
        
        tags.forEach { tagReference in
            
            print("Remaining commit size: \(commits.count)")
            print("Find tags for: \(tagReference)")
           
            let endIndex = commits.prefix(while: { $0.oid != tagReference.oid }).endIndex + 1
            
            
            let foundCommits = Array(commits[..<endIndex])
            
            print("Found \(foundCommits.count) commits for tag")
            
            let remaining = commits[endIndex...]
            commits = Array(remaining)
            let release = Release(version: Version(value: tagReference.name), tag: tagReference, changeSet: ChangeSet(from: foundCommits))
            foundReleases.append(release)
        }
            
        releases = foundReleases.reversed()
        unreleased  = ChangeSet(from: commits)
    }
}

