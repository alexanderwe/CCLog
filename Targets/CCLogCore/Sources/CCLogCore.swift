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
        from repository: URL
    ) -> Result<Void, CCLogError> {
        
        guard let tagQuery = TagQuery(data: tagQuery) else {
            return .failure(.tagQueryInvalid)
        }

        
        switch Repository.at(repository) {
        case let .success(repo):
            
            guard case let .success(commits) = repo.traverseCommits(from: tagQuery) else {
                return .failure(.failedToQueryTags)
            }
            
            let ccommits = commits.map { ConventionalCommit(data: $0.message)}
            ccommits.forEach {
                print($0?.type)
            }
            
            break;
        case let .failure(error):
            return .failure(.gitError(error: GitError(from: error)))
        }
        
        return .success(())
        
    }
}


extension Commit {
    var firstMessageLine: String? {
        if let firstParagraph = message.components(separatedBy: CharacterSet.newlines).first {
            return firstParagraph
        } else {
            return nil
        }
    }
}
