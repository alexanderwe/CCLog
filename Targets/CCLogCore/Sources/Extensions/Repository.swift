//
//  File.swift
//  
//
//  Created by Alexander Weiß on 15.11.20.
//

import Foundation
import SwiftGit2
import Clibgit2

extension Array {
    func unique<T:Hashable>(by: ((Element) -> (T)))  -> [Element] {
        var set = Set<T>() //the unique list kept in a Set for fast retrieval
        var arrayOrdered = [Element]() //keeping the unique list of elements but ordered
        for value in self {
            if !set.contains(by(value)) {
                set.insert(by(value))
                arrayOrdered.append(value)
            }
        }

        return arrayOrdered
    }
}

extension Repository {
    
    func allCommits() -> Result<[Commit], NSError> {
        var commits: [Commit] = []
        
        guard case let .success(branches) = self.localBranches() else {
            return .failure(.init())
        }
        
        branches.forEach {
            let commitIterator = self.commits(in: $0)
            while let commitIteratorElement = commitIterator.next() {
                
                guard case let .success(commit) = commitIteratorElement else {
                    return
                }
                
                commits.append(commit)
            }
        }
        
        let unique = commits
            .unique(by: { $0.oid })
            .sorted(by: { $0.author.time.compare($1.author.time) == .orderedDescending })
        
        return .success(unique)
        
    }
}


extension Repository {

    /// Calculate the start and end commit from a `TagQuery` instance
    /// - Parameter query: Query used to calculate start and end
    /// - Returns: Result containing the start and end commit of the query
    private func findStartEnd(from query: TagQuery) -> Result<(Commit?, Commit), NSError> {
        
        var startCommitToReturn: Commit!
        var endCommitToReturn: Commit!
        
        switch query {
        case let .closed(start, end):
            let startTag = self.tag(named: start)
            let endTag = self.tag(named: end)
            
            guard case let .success(tagRefStart) = startTag,
                  case let .success(tagRefEnd) = endTag,
                  case let .success(startCommit) = self.commit(tagRefStart.oid),
                  case let .success(endCommit) = self.commit(tagRefEnd.oid)
            else {
                return .failure(NSError.init())
            }
            startCommitToReturn = startCommit
            endCommitToReturn = endCommit
            
        case let .rightOpen(start):
            let startTag = self.tag(named: start)
            
            guard case let .success(tagRefStart) = startTag,
                  case let .success(allTags) = self.allTags(),
                  case let .success(startCommit) = self.commit(tagRefStart.oid),
                  let tagRefEnd = allTags.first,
                  case let .success(endCommit) = self.commit(tagRefEnd.oid)
            else {
                return .failure(NSError.init())
            }
            
            startCommitToReturn = startCommit
            endCommitToReturn = endCommit
            
        case let .leftOpen(end):
            
            let endTag = self.tag(named: end)
            
            guard case let .success(allTags) = self.allTags(),
                  let tagRefStart = allTags.last,
                  case let .success(startCommit) = self.commit(tagRefStart.oid),
                  case let .success(tagRefEnd) = endTag,
                  case let .success(endCommit) = self.commit(tagRefEnd.oid)
            else {
                return .failure(NSError.init())
            }
            startCommitToReturn = startCommit
            endCommitToReturn = endCommit
        
        case let .single(tag):
            let endTag = self.tag(named: tag)
            guard case let .success(tagRefEnd) = endTag,
                  case let .success(endCommit) = self.commit(tagRefEnd.oid),
                  case let .success(allTags) = self.allTags()
            else {
                return .failure(NSError.init())
            }
            
            var startCommit: Commit?

            // Find the tag before the `tag`
            // If there is no tag before `tag` means startCommit = nil and so we start from the beginning of the repository
            let indexOfStartTag = allTags.firstIndex(where: {$0 == tagRefEnd})

            if let indexOfStartTag = indexOfStartTag {
                let previousTagIndex = (indexOfStartTag + 1)
                if previousTagIndex < allTags.count {
                    let startTag = allTags[previousTagIndex]
                    guard case let .success(startCommitH) = self.commit(startTag.oid) else {
                        return .failure(NSError.init())
                    }
                    startCommit = startCommitH
                }
            }
            
            startCommitToReturn = startCommit
            endCommitToReturn = endCommit
        }
        
        return .success((startCommitToReturn, endCommitToReturn))
    }
    

    func traverseCommits(from query: TagQuery) -> Result<[Commit], NSError> {
        switch self.findStartEnd(from: query) {
        case let .success((startCommit, endCommit)):
            return self.traverseCommits(from: startCommit, to: endCommit)
        case let .failure(error):
            return .failure(error)
        }
    }
    
    
    func traverseTags(from query: TagQuery) -> Result<[TagReference], NSError> {
        switch self.findStartEnd(from: query) {
        case let .success((startCommit, endCommit)):
            return  self.traverseTags(from: startCommit, to: endCommit)
        case let .failure(error):
            return .failure(error)
        }
    }
    
    
    /// Traverse through commits from the `end` to `start` and collect every tag that references a commi on the way.
    ///
    /// This method uses git_revwalk to walk from `end` to `start`. If the start commit is nil this method will
    /// traverse the complete history beginning from `end` -> so up to the initial commit of the repository.
    ///
    /// The tags are ordered from  descending according to the commit time.
    ///
    /// - Parameters:
    ///   - start: The start commit
    ///   - end: The end commit
    ///   - startInclusive: Flag to include the start commit in traversal
    /// - Returns: Result containing the requested commits or an error
    private func traverseTags(from start: Commit?, to end: Commit, startInclusive: Bool = false) -> Result<[TagReference], NSError>  {
        
        let allTags = Dictionary(grouping: try! self.allTags().get()) { $0.oid }
        var tagsToReturn: [TagReference] = []

        guard case let commits = try? self.traverseCommits(from: start, to: end, startInclusive: startInclusive).get() else {
            return .failure(.init())
        }
        
        commits?.forEach {
            if let tag = allTags[$0.oid] {
                tagsToReturn.append(tag.first!)
            }
        }
        return .success(tagsToReturn)
    }
    
    /// Traverse through and collect commits from the start to end commit.
    ///
    /// This method uses git_revwalk to walk from `end` to `start`. If the start commit is nil this method will
    /// traverse the complete history beginning from `end` -> so up to the initial commit of the repository.
    ///
    /// The commits are ordered from `end` to `start`. This normally means the commits are order descending according
    /// to the commit time.
    ///
    /// - Parameters:
    ///   - start: The start commit
    ///   - end: The end commit
    ///   - startInclusive: Flag to include the start commit in traversal
    /// - Returns: Result containing the requested commits or an error
    private func traverseCommits(from start: Commit?, to end: Commit, startInclusive: Bool = false) -> Result<[Commit], NSError> {
        
        // Function parameters
        var commits: [Commit] = []
        var walker: OpaquePointer? = nil
        
        // Free memory after successful revwalk
        defer { git_revwalk_free(walker) }
       
        // Init git_revwalk
        var gitError: Int32 = git_revwalk_new(&walker, self.pointer)
        guard gitError == GIT_OK.rawValue else {
            return .failure(NSError(gitError: gitError, pointOfFailure: "git_revwalk_new"))
        }
        
        if start == nil {
            var oid: git_oid = end.oid.oid
            gitError = git_revwalk_push(walker, &oid)
        } else {
            gitError = git_revwalk_push_range(walker, "\(start!.oid.description)..\(end.oid.description)")
        }
        
        guard gitError == GIT_OK.rawValue else {
            return .failure(NSError(gitError: gitError, pointOfFailure: "git_revwalk_push_range"))
        }
        
        var oid: git_oid = git_oid()
        var revWalkError: Int32 = GIT_OK.rawValue
        
        while (revWalkError = git_revwalk_next(&oid, walker), revWalkError).1 == GIT_OK.rawValue {
           let c = self.commit(OID(oid))
           commits.append(try! c.get())
       }
       
       if revWalkError != GIT_ITEROVER.rawValue {
           return .failure(NSError(gitError: gitError, pointOfFailure: "git_revwalk_next"))
       }

       if startInclusive && start != nil {
           commits.append(start!)
       }
        
        return .success(commits)
    }
}



public let libGit2ErrorDomain = "org.libgit2.libgit2"

internal extension NSError {
    /// Returns an NSError with an error domain and message for libgit2 errors.
    ///
    /// :param: errorCode An error code returned by a libgit2 function.
    /// :param: libGit2PointOfFailure The name of the libgit2 function that produced the
    ///         error code.
    /// :returns: An NSError with a libgit2 error domain, code, and message.
    convenience init(gitError errorCode: Int32, pointOfFailure: String? = nil) {
        let code = Int(errorCode)
        var userInfo: [String: String] = [:]

        if let message = errorMessage(errorCode) {
            userInfo[NSLocalizedDescriptionKey] = message
        } else {
            userInfo[NSLocalizedDescriptionKey] = "Unknown libgit2 error."
        }

        if let pointOfFailure = pointOfFailure {
            userInfo[NSLocalizedFailureReasonErrorKey] = "\(pointOfFailure) failed."
        }

        self.init(domain: libGit2ErrorDomain, code: code, userInfo: userInfo)
    }
}

/// Returns the libgit2 error message for the given error code.
///
/// The error message represents the last error message generated by
/// libgit2 in the current thread.
///
/// :param: errorCode An error code returned by a libgit2 function.
/// :returns: If the error message exists either in libgit2's thread-specific registry,
///           or errno has been set by the system, this function returns the
///           corresponding string representation of that error. Otherwise, it returns
///           nil.
private func errorMessage(_ errorCode: Int32) -> String? {
    let last = giterr_last()
    if let lastErrorPointer = last {
        return String(validatingUTF8: lastErrorPointer.pointee.message)
    } else if UInt32(errorCode) == GITERR_OS.rawValue {
        return String(validatingUTF8: strerror(errno))
    } else {
        return nil
    }
}

