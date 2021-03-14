//
//  Changelog.swift
//  
//
//  Created by Alexander Weiß on 21.11.20.
//

import Foundation
import ConventionalCommitsKit
import SwiftGit2


public struct ChangeLog {
    let releases: [Release]?
    let unreleased: ChangeSet?
}

extension ChangeLog {
        
    init(commits: [Commit], tags: [TagReference], repository: Repository) {
        
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
            
            var tagName = tagReference.name.deletingPrefix("v")
    
            let release = Release(version: Version(value: tagName),
                                  tag: tagReference,
                                  changeSet: ChangeSet(from: foundCommits),
                                  date: try! repository.commit(tagReference.oid).get().author.time
            )
            foundReleases.append(release)
        }
            
        releases = foundReleases.reversed()
        unreleased  = ChangeSet(from: commits)
    }
}

fileprivate extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
