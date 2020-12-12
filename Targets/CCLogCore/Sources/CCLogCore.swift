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
import Stencil

public enum CCLogCore {
    public static func generateGitLog(
        tagQuery: String,
        tagFilter: String? = nil,
        from repositoryURL: URL,
        on template: URL,
        output: URL? = nil
    ) -> Result<ChangeLog, CCLogError> {
        
        guard let tagQuery = TagQuery(data: tagQuery) else {
            return .failure(.tagQueryInvalid)
        }
        
        var filter: TagFilter?
        if tagFilter != nil {
            guard let f = TagFilter(string: tagFilter!) else {
                return .failure(.tagFilterInvalid)
            }
            filter = f
        }

        guard case let .success(repository) = Repository.at(repositoryURL) else {
            return .failure(.failedToOpenRepository)
        }
        
        //TODO: Improve performance. Here we go traverse the repository twice. Once for the commits
        //and once for the tags
        guard case let .success(commits) = repository.traverseCommits(from: tagQuery),
              case let .success(tags) = repository.traverseTags(from: tagQuery, filteredBy: filter) else {
            return .failure(.failedToCollectCommits)
        }
        
        let changelog = ChangeLog(commits: commits, tags: tags)
        render(changelog: changelog, on: template, output: output)
        
        
         return .success(changelog)
    }
    
    private static func render(changelog: ChangeLog, on template: URL, output: URL?) {
        let environment = Environment()
        do {
            // Get the contents
            let template = try String(contentsOfFile: template.absoluteString, encoding: .utf8)
            
            let context = [
              "changelog": changelog
            ]
            
            let rendered = try environment.renderTemplate(string: template, context: context)
            print(rendered)
        }
        catch let error as NSError {
            print("Ooops! Something went wrong: \(error)")
        }
    }
    
}
