//
//  CCLogCore.swift
//  
//
//  Created by Alexander Weiß on 28.10.20.
//

import Foundation
import ConventionalCommits
import SwiftGit2
import Clibgit2

public enum CCLogCore {
    public static func generateGitLog(
        tagQuery: String,
        from repositoryURL: URL
    ) -> Result<ChangeLog, CCLogError> {
        
        guard let tagQuery = TagQuery(data: tagQuery) else {
            return .failure(.tagQueryInvalid)
        }

        guard case let .success(repository) = Repository.at(repositoryURL) else {
            return .failure(.failedToOpenRepository)
        }
        
        //TODO: Improve performance. Here we go traverse the repository twice. Once for the commits
        //and once for the tags
        guard case let .success(commits) = repository.traverseCommits(from: tagQuery),
              case let .success(tags) = repository.traverseTags(from: tagQuery) else {
            return .failure(.failedToCollectCommits)
        }
        
        let changelog = ChangeLog(commits: commits, tags: tags)
    
         return .success(changelog)
    }
}
