//
//  main.swift
//  ConsoleTest
//
//  Created by Toby on 2020-08-03.
//  Copyright © 2020 Toby. All rights reserved.
//

import Foundation

let manager = GoogleTranslate(apiKey: "", 
                              userLanguage: "en")
let group = DispatchGroup()

let errorHandler: (String) -> () = {
    print($0)
    group.leave()
}

// Load all supported languages
// must be preformed after init else error checking will fail
group.enter()
manager.loadSupportedLanguages(onComplete: group.leave, errorHandler: errorHandler)
group.wait()

print("All languages", manager.supportedLanguages[.base]!)
print("Languages not supported by nmt", manager.supportedLanguages[.base]!.filter{ p1 in
    !manager.supportedLanguages[.nmt]!.contains{ p2 in
        p1.key == p2.key
    }
})

// Detect example
var detectP = manager.defaultDetectParams()
detectP.text = ["Je vous remercie", "Hello"]
group.enter()
manager.detect(params: detectP, errorHandler: errorHandler){ result in
    for i in 0..<result.count {
        print("Detected: \(detectP.text[i])")
        for detected in result[i] {
            print("  To be: \(manager.supportedLanguages[.base]?[detected.language] ?? "Unkown")")
            print("  With confidence: \(detected.confidence)")
        }
    }
    group.leave()
}
group.wait()

// Translate example
var translateP = manager.defaultTranslateParams()
translateP.text = ["Hello", "Thank you"]
translateP.target = "fr"
translateP.source = "en"
translateP.model = .nmt
group.enter()
manager.translate(params: translateP, errorHandler: errorHandler){ result in
    for i in 0..<result.count {
        print("Translated: \(translateP.text[i])")
        print("  To: \(result[i].translatedText)")
        if let detected = result[i].detectedSourceLanguage {
            print("  Detected language to be: \(manager.supportedLanguages[.base]?[detected] ?? "Unkown")")
        }
    }
    group.leave()
}

group.wait() // don't kill the program until all responses are processed
