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
    public static func generateGitLog(from repository: URL) -> Result<Void, CCLogError> {
        
        let c = try? ConventionalCommit(data: "fix(ci-test)!: Include correct location for code coverage file")
        print(c)
        
        switch Repository.at(repository) {
        case let .success(repo):
            
            self.extractTags(from: repo)
            
            
            
        
            
            
            break;
        case let .failure(error):
            return .failure(.gitError(error: GitError(from: error)))
        }
        
        
        
        
        return .success(())
        
        
        
        
//        let url = URL(string: "./")!
//        let res = Repository.at(url)
//
//        switch res {
//        case let .success(repo):
//
//            let latestCommit = repo.commit(OID(string: "")!)
//
//
//            switch latestCommit {
//            case let .success(commit):
//
//                let c = try? ConventionalCommit(data: "fix(ci-test)!: Include correct location for code coverage file")
//                print(c)
//
//            case let .failure(error):
//                print("Could not get commit: \(error)")
//            }
//
//        case let .failure(error):
//            print("Could not open repository: \(error)")
//        }
    }
    
    
    public static func extractTags(from repository: Repository) {
        switch repository.allTags() {
        case let .success(tags):
            
            
            let start = try? repository.commit(tags.first!.oid).get()
            let end = try? repository.commit(tags.last!.oid).get()
        
            let t: [Commit] = self.traverseCommits(from: start!, to: end!, in: repository)
                .distinct()
                .sorted { $0.committer.time.compare($1.committer.time) == .orderedDescending
            }
      

            t.forEach { print($0.firstMessageLine) }
        case let .failure(error):
            print(error)
        }
    }
    
    
    
    public static func traverseCommits(from start: Commit, to end: Commit, in repository: Repository) -> [Commit] {
        var commits: [Commit] = []
    
        var pointer: OpaquePointer? = nil
        defer { git_revwalk_free(pointer) }
        
        let mutPoibter = UnsafeMutablePointer<OpaquePointer?>.init(pointer)
        
        git_revwalk_new(<#T##out: UnsafeMutablePointer<OpaquePointer?>!##UnsafeMutablePointer<OpaquePointer?>!#>, <#T##repo: OpaquePointer!##OpaquePointer!#>)
        git_revwalk_new(mutPoibter, repository.pointer)
        git_revwalk_next(<#T##out: UnsafeMutablePointer<git_oid>!##UnsafeMutablePointer<git_oid>!#>, <#T##walk: OpaquePointer!##OpaquePointer!#>)
    

        
        print("Start: \(start.oid.description) -> End: \(end.oid.description)")
        
        
        self.traverseCommits(from: start.oid, to: end.oid, in: repository, history: &commits)
        return commits
    }
    
    
    
    
//    - (void)traverseCommits: (GTCommit *)start withGoal: (GTCommit *)goal withHistory: (NSMutableDictionary *)history{
//        NSLog(@"%@", start.shortSHA);
//        if ([start.SHA isEqualToString:goal.SHA]) {
//            return;
//        }
//        for (GTCommit *c in start.parents) {
//            //[history setObject:c forKey:c.SHA];
//            if(![c.SHA isEqualToString:goal.SHA])
//                [self traverseCommits:c withGoal:goal withHistory:history];
//
//        }
//    }
    
    
    
    
    public static func traverseCommits(from start: OID, to end: OID, in repository: Repository, history: inout [Commit]) {
        print("Start traversing commit history from \(start.description)")
        
        guard case let .success(startCommit) = repository.commit(start) else {
            return
        }
        
        
        if(start == end) {
            guard case let .success(s) = repository.commit(start),
                  case let .success(e) = repository.commit(end)  else {
                return
            }
            print("\(s.firstMessageLine) == \(e.firstMessageLine)")
            return
        }
        
       
       
        startCommit.parents.forEach { pointer in
            guard case let .success(commitToAdd) = repository.commit(pointer.oid) else {
                return
            }
            history.append(commitToAdd)
            
            if pointer.oid != end {
                self.traverseCommits(from: commitToAdd.oid, to: end, in: repository, history: &history)
            }
        }
        
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
