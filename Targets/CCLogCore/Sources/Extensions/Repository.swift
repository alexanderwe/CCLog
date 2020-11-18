//
//  File.swift
//  
//
//  Created by Alexander Weiß on 15.11.20.
//

import Foundation
import SwiftGit2
import Clibgit2

extension Repository {
    
    func traverseCommits(from query: TagQuery) -> Result<[Commit], NSError> {
        
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
            
            return self.traverseCommits(from: startCommit, to: endCommit)
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
            
            return self.traverseCommits(from: startCommit, to: endCommit)
            
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
            return self.traverseCommits(from: startCommit, to: endCommit)
        
        case let .single(tag):
            let endTag = self.tag(named: tag)
            guard case let .success(tagRefEnd) = endTag,
                  case let .success(endCommit) = self.commit(tagRefEnd.oid),
                  case let .success(allTags) = self.allTags()
            else {
                return .failure(NSError.init())
            }
            
            var startCommit: Commit?
            
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
            
            
            return self.traverseCommits(from: startCommit, to: endCommit)
            
        default:
            fatalError("Unimplemented")
        }
        
        return .success([])
    }
    
    
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
        var lastTag: Tag?
        
        
        
        let alltags = self.allTags()
    
        while (revWalkError = git_revwalk_next(&oid, walker), revWalkError).1 == GIT_OK.rawValue {
            
            let oidD = OID(oid)
            
            
            
           
            let tag = self.tag(named: "test-tag")
            let c = self.commit(oidD)
            print(try! c.get().message)
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

