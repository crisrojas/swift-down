// Copyright © 2025 Cristian Felipe Patiño Rojas
// Released under the MIT License

import Foundation
import ArgumentParser
import Core
import MiniSwiftServer

enum Composer {
    static func compose(with pathURL: String) throws -> (Swiftdown, Server) {
        let folderURL   = URL(fileURLWithPath: pathURL).standardizedFileURL
        let sourcesURL  = folderURL.appendingPathComponent("sources")
        let themeURL    = folderURL.appendingPathComponent("theme")
        let outputURL   = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                           .appendingPathComponent("build")

        guard FileManager.default.fileExists(atPath: sourcesURL.path) else {
            throw ValidationError("Sources folder not found at: \(sourcesURL.path)")
        }
        guard FileManager.default.fileExists(atPath: themeURL.path) else {
            throw ValidationError("Sources folder not found at: \(themeURL.path)")
        }
        
        return make(sourcesURL: sourcesURL, themeURL: themeURL, outputURL: outputURL)
    }
    
   private static func make(
        sourcesURL: URL,
        themeURL: URL,
        outputURL: URL
    ) -> (Swiftdown, Server) {

        let ssg = Swiftdown(
            runner: CodeRunner.swift,
            syntaxParser: SwiftSyntaxHighlighter(),
            logsParser: LogsParser(),
            markdownParser: MarkdownParser(),
            sourcesURL: sourcesURL,
            outputURL: outputURL,
            themeURL: themeURL,
            langExtension: "swift",
            author: .init(name: "Cristian Felipe Patiño Rojas", website: "https://crisfe.me")
        )
        
        let requestHandler = RequestHandler(
            parser: ssg.parse,
            themeURL: themeURL,
            sourcesURL: sourcesURL,
            sourceExtension: "swift"
        )
        
        let server = Server(
            port: 4000,
            requestHandler: requestHandler.process
        )
        
        return (ssg, server)
    }
}
