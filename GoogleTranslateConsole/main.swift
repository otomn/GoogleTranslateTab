//
//  main.swift
//  GoogleTranslateConsole
//
//  Created by Toby on 2022-06-22.
//  Copyright © 2022 Toby. All rights reserved.
//

import ArgumentParser
import Foundation

extension GoogleTranslate.TranslateModel: ExpressibleByArgument {}

struct GoogleTranslateConsole: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "gtrans",
        abstract: "Translate using Google Translate API",
        discussion: """
            Translate inputs from both stdin and command line arguments.
            If both are present, command line arguments will be translated first. 
            """
    )
    
    @Flag(name: .shortAndLong, help: "List all supported languages and exit")
    var list = false
    
    @Flag(name: .shortAndLong, help: "Detect the language of the input") 
    var detect = false
    
    @Option(name: .shortAndLong, help: "Mode of translation")
    var mode: GoogleTranslate.TranslateModel = .base

    @Option(name: .shortAndLong, help: "The API key to use")
    var key: String
    
    @Option(name: .shortAndLong, help: "From language")
    var from: String?
    
    @Option(name: .shortAndLong, help: "To language")
    var to: String = "en"
    
    @Argument(help: "Inputs to translate. Quote the arguments if they form a sentence")
    var words: [String] = []

    mutating func run() throws {
        let manager = GoogleTranslate(apiKey: key, userLanguage: "en")
        let group = DispatchGroup()
        let errorHandler: (String) -> () = {
            print($0)
            group.leave()
            _exit(1)
        }
        if list || detect {
            group.enter()
            manager.loadSupportedLanguages(onComplete: group.leave, errorHandler: errorHandler)
            group.wait()
        }
        
        if list {
            manager.supportedLanguages[mode]!.keys.sorted().forEach {
                print($0, manager.supportedLanguages[mode]![$0]!)
            }
            return
        }
        
        if isatty(FileHandle.standardInput.fileDescriptor) == 0 {
            while let line = readLine() {
                words.append(line)
            }
        }
        
        if detect {
            var detectP = manager.defaultDetectParams()
            detectP.text = words
            group.enter()
            manager.detect(params: detectP, errorHandler: errorHandler){ result in
                for i in 0..<result.count {
                    print("Detected line \(i + 1)")
                    for detected in result[i] {
                        print("  To be: \(manager.supportedLanguages[.base]?[detected.language] ?? "Unkown")")
                        print("  With confidence: \(detected.confidence)")
                    }
                }
                group.leave()
            }
            group.wait()
            return
        }
        
        var translateP = manager.defaultTranslateParams()
        translateP.text = words
        translateP.target = to
        translateP.source = from
        translateP.model = mode
        group.enter()
        manager.translate(params: translateP, noLanguageCheck: true, errorHandler: errorHandler){ result in
            for i in 0..<result.count {
                print(result[i].translatedText)
            }
            group.leave()
        }
        group.wait()
    }
}

GoogleTranslateConsole.main()
