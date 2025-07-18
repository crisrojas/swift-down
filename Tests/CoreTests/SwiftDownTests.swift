// Created by Cristian Felipe Patiño Rojas on 7/5/25.

import XCTest
import Core

final class SwiftDownTests: XCTestCase, FileReader {
    
    override func setUp() {
        try? FileManager.default.removeItem(at: outputFolder())
    }
    
    override func tearDown() {
        try? FileManager.default.removeItem(at: outputFolder())
    }
    
    func test_theme_resources_are_coppied() throws {
        try makeSUT().build()
        
        let outputFiles = try fm.contentsOfDirectory(atPath: outputFolder().path)
        XCTAssert(outputFiles.contains("css"))
        XCTAssert(outputFiles.contains("js"))
        XCTAssert(outputFiles.contains("assets"))
        XCTAssert(!outputFiles.contains("index.html"))
    }
    
    func test_codesource_files_are_copied_as_html() throws {
        try makeSUT().build()
        let outputFiles = try fm.contentsOfDirectory(atPath: outputFolder().path)
        XCTAssert(outputFiles.contains("example.swift.txt.html"))
    }
    
    func getFileContents(fileName: String) throws -> String {
        let url = testsResourceDirectory().appendingPathComponent("example.swift")
        return try String(contentsOfFile: url.path, encoding: .utf8)
    }
    
    func makeSUT() -> Swiftdown {
        Swiftdown(
            runner: CodeRunner.swift,
            syntaxParser: SwiftSyntaxHighlighter(),
            logsParser: LogsParser(),
            markdownParser: MarkdownParser(),
            sourcesURL: sourcesFolder(),
            outputURL: outputFolder(),
            themeURL: themeFolder(),
            langExtension: "swift",
            author: .init(name: "Cristian Felipe Patiño Rojas", website: "https://cristian.lat")
        )
    }
    
    func testsResourceDirectory() -> URL {
        Bundle.module.bundleURL.appendingPathComponent("Contents/Resources")
    }
    
    func inputFolder() -> URL {
        testsResourceDirectory().appendingPathComponent("input")
    }
    
    func sourcesFolder() -> URL {
        inputFolder().appendingPathComponent("sources")
    }
    
    func themeFolder() -> URL {
        inputFolder().appendingPathComponent("theme")
    }
    
    private func cachesDirectory() -> URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func testSpecificURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self))")
    }
    
    func outputFolder() -> URL {
        testSpecificURL().appendingPathComponent("output")
    }
}
