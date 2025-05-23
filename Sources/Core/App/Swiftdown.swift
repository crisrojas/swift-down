// Copyright © 2025 Cristian Felipe Patiño Rojas
// Released under the MIT License

import Foundation

public struct Swiftdown: FileHandler {
    
    let runner         : Runner
    
    let syntaxParser   : Parser
    let logsParser     : Parser
    let markdownParser : Parser
    
    let sourcesURL     : URL
    let outputURL      : URL
    let themeURL       : URL
    let langExtension  : String
    
    let author         : Author
    
    public init(
        runner: Runner,
        syntaxParser: Parser,
        logsParser: Parser,
        markdownParser: Parser,
        sourcesURL: URL,
        outputURL: URL,
        themeURL: URL,
        langExtension: String,
        author: Author
    ) {
        self.runner = runner
        self.syntaxParser = syntaxParser
        self.logsParser = logsParser
        self.markdownParser = markdownParser
        self.sourcesURL = sourcesURL
        self.outputURL = outputURL
        self.themeURL = themeURL
        self.langExtension = langExtension
        self.author = author
    }
    
    public func build() throws {
        try FileManager.default.createDirectory(
            at: outputURL,
            withIntermediateDirectories: true,
            attributes: nil
        )
        
        try writeTemplateAssets()
        
        try getFileURLs().forEach {
            let rendered = try parse($0)
            let outputURL = outputURL.appendingPathComponent($0.lastPathComponent + ".html")
            try write(rendered, to: outputURL)
        }
    }
    
    func getFileURLs() throws -> [URL] {
        try getFileURLs(in: sourcesURL).filter { $0.lastPathComponent.contains(".\(langExtension)") }
    }
    
    // @nicetohave:
    // If I had a more sophisticated templating engine,
    // this wouldn't be render here...
    func renderFiles() throws -> String {
        let elements = try getFileURLs().reduce("") { current, next in
            let path = next.lastPathComponent
            return current + """
   <li>
   <a	href="#"
    onclick="loadContent('/\(path)', 'main'); return false;">
    \(path)
   </a>
   """
        }
        return "<ul>\(elements)</ul>"
    }
    
    public func parse(_ url: URL) throws -> String {
        let filename = url.lastPathComponent
        let contents = try String(contentsOf: url, encoding: .utf8)
        
        let logs = logsParser.parse(try runner.run(contents, with: filename, extension: nil))
        
        var parse: (String) -> String { syntaxParser.parse >>> markdownParser.parse }
        
        let data = [
            "$title": filename,
            "$content": parse(contents),
            "$author-name": author.name,
            "$author-website": author.website,
            "$logs": logs,
            "$files": try renderFiles()
        ]
        
        return try TemplateEngine(folder: themeURL, data: data).render()
    }
    
    func writeTemplateAssets() throws {
        try copyFiles(from: themeURL, to: outputURL, excluding: ["index.html"])
    }
}

infix operator >>> : AdditionPrecedence
func >>><A>(first: @escaping (A) -> A, second: @escaping (A) -> A) -> (A) -> A {
    return { input in second(first(input)) }
}

extension Swiftdown {
    public struct Author {
        let name: String
        let website: String
        
        public init(name: String, website: String) {
            self.name = name
            self.website = website
        }
    }
}

extension SwiftSyntaxHighlighter: Parser {}
extension MarkdownParser		 : Parser {}
extension LogsParser			 : Parser {}
extension CodeRunner			 : Runner {}
