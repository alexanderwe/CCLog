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


public extension Sequence where Element: Hashable {

    /// Return the sequence with all duplicates removed.
    ///
    /// i.e. `[ 1, 2, 3, 1, 2 ].uniqued() == [ 1, 2, 3 ]`
    ///
    /// - note: Taken from stackoverflow.com/a/46354989/3141234, as
    ///         per @Alexander's comment.
    func distinct() -> [Element] {
        var seen = Set<Element>()
        return self.filter { seen.insert($0).inserted }
    }
}


public enum CCLogCore {
    public static func generateGitLog(
        tagQuery: String,
        from repository: URL
    ) -> Result<Void, CCLogError> {
        
        guard let tagQuery = TagQuery(data: tagQuery) else {
            return .failure(.tagQueryInvalid)
        }
        
//        
//        let c = try? ConventionalCommit(data: "fix(ci-test)!: Include correct location for code coverage file")
//        print(c)
        
        switch Repository.at(repository) {
        case let .success(repo):
            
            self.extractTags(from: repo)
            
            
            
        
            
            
            break;
        case let .failure(error):
            return .failure(.gitError(error: GitError(from: error)))
        }
        
        return .success(())
        
    }
    
    
    public static func extractTags(from repository: Repository) {
        switch repository.allTags() {
        case let .success(tags):
            
            
            let start = try? repository.commit(tags.first!.oid).get()
            let end = try? repository.commit(tags.last!.oid).get()
        
            print(self.traverseCommits(from: start!, to: end!, in: repository))
            
        case let .failure(error):
            print(error)
        }
    }
    
    
    
    public static func traverseCommits(from start: Commit, to end: Commit, in repository: Repository) -> Result<[Commit], GitError> {
        
        // Function parameters
        var commits: [Commit] = []
        var walker: OpaquePointer? = nil
        
        
        // Free memory after successful revwalk
        defer { git_revwalk_free(walker) }
       
        
        // Init git_revwalk
        var gitError: Int32 = git_revwalk_new(&walker, repository.pointer)
        guard gitError == GIT_OK.rawValue else {
            return .failure(GitError(from: NSError(gitError: gitError, pointOfFailure: "git_revwalk_new")))
        }
        
        gitError = git_revwalk_push_range(walker, "\(end.oid.description)..\(start.oid.description)")
        
        guard gitError == GIT_OK.rawValue else {
            return .failure(GitError(from: NSError(gitError: gitError, pointOfFailure: "git_revwalk_push_range")))
        }
        
        var oid: git_oid = git_oid()
        var revWalkError: Int32 = GIT_OK.rawValue
    
        while (revWalkError = git_revwalk_next(&oid, walker), revWalkError).1 == GIT_OK.rawValue {
            let c = repository.commit(OID(oid))
            commits.append(try! c.get())
        }
        
        if revWalkError != GIT_ITEROVER.rawValue {
            return .failure(GitError(from: NSError(gitError: gitError, pointOfFailure: "git_revwalk_next")))
        }
        
        
        commits.append(start)
        return .success(commits)
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
