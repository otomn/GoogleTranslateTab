//
//  ContentView.swift
//  GoogleTranslateTab
//
//  Created by Toby on 2020-08-02.
//  Copyright © 2020 Toby. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State private var loaded = false
    @State private var translateFrom = ""
    @State private var translateTo = ""
    @State private var fromLan = "en"
    @State private var toLan = "en"
    @State private var detectedLan = ""
    @State private var languagesMap: [String: String] = [:]
    @State private var model: GoogleTranslate.TranslateModel = .base
    @State private var startOnBoot = false
    
    var translateManager: GoogleTranslate
    
    var languageCodes: [String] {
        languagesMap.keys.sorted()
    }
    
    var body: some View {
        if #available(OSX 11.0, *) {
            body_11_0
        } else {
            body_10_15
        }
    }
    
    @available(OSX 11.0, *)
    var body_11_0: some View{
        VStack(alignment: .leading) {
            HStack {
                
                Picker(selection: $fromLan, label: Text("From")) {
                    ForEach(0 ..< languageCodes.count, id: \.self){
                        Text(self.languagesMap[self.languageCodes[$0]]!)
                            .tag(self.languageCodes[$0])
                    }
                    Text("Auto Detect" + 
                        (detectedLan == "" ? "" : " (\(detectedLan))")).tag("auto")
                    }.disabled(!loaded).id(languagesMap)
                
                Button(action: {
                    if self.fromLan != "auto" {
                        let temp = self.fromLan
                        self.fromLan = self.toLan
                        self.toLan = temp
                    }
                }, label: { Text("􀄭") }).disabled(!loaded)
                
                Picker(selection: $toLan, label: Text("To")) {
                    ForEach(0 ..< languageCodes.count, id: \.self){
                        Text(self.languagesMap[self.languageCodes[$0]]!)
                            .tag(self.languageCodes[$0])
                    }.id(languagesMap)
                }.disabled(!loaded)
                
                Button(action: {
                    self.savePref()
                    self.translateStart()
                }, label: { Text("Translate") })
                .disabled(!loaded)
                .keyboardShortcut(.return)
                
                Menu("•••"){
                    Menu("Model"){
                        Toggle(isOn: Binding(get: { 
                            self.model == GoogleTranslate.TranslateModel.nmt
                        }, set: {
                            if $0 {
                                self.model = GoogleTranslate.TranslateModel.nmt
                                self.reloadLanguages()
                            }
                        })) {
                            Text("Neural Machine Translation")
                        }
                        Toggle(isOn: Binding(get: { 
                            self.model == GoogleTranslate.TranslateModel.base
                        }, set: {
                            if $0 {
                                self.model = GoogleTranslate.TranslateModel.base
                                self.reloadLanguages()
                            }
                        })) {
                            Text("Phrase-Based Machine Translation")
                        }
                    }
                    Button(action: {
                        NSApplication.shared.terminate(self)
                    }, label: { Text("Quit") })
                }
                .scaledToFit()
                .menuStyle(BorderlessButtonMenuStyle(showsMenuIndicator: false) )
                .frame(width: 40)
            }
            TextField("Translate From", text: $translateFrom).disabled(!loaded)
            TextField("Translate To", text: $translateTo)
        }
        .padding(.all, 10.0)
        .onAppear(perform: onload)
    }
    
    var body_10_15: some View {
        VStack(alignment: .leading) {
            HStack {
                
                Picker(selection: $fromLan, label: Text("From")) {
                    ForEach(0 ..< languageCodes.count, id: \.self){
                        Text(self.languagesMap[self.languageCodes[$0]]!)
                            .tag(self.languageCodes[$0])
                    }
                    Text("Auto Detect" + 
                        (detectedLan == "" ? "" : " (\(detectedLan))")).tag("auto")
                    }.disabled(!loaded).id(languagesMap)
                
                Button(action: {
                    if self.fromLan != "auto" {
                        let temp = self.fromLan
                        self.fromLan = self.toLan
                        self.toLan = temp
                    }
                }, label: { Text("􀄭") }).disabled(!loaded)
                
                Picker(selection: $toLan, label: Text("To")) {
                    ForEach(0 ..< languageCodes.count, id: \.self){
                        Text(self.languagesMap[self.languageCodes[$0]]!)
                            .tag(self.languageCodes[$0])
                    }.id(languagesMap)
                }.disabled(!loaded)
                
                Button(action: {
                    self.savePref()
                    self.translateStart()
                }, label: { Text("Translate") }).disabled(!loaded)
                
                MenuButton("•••"){
                    MenuButton("Model"){
                        Toggle(isOn: Binding(get: { 
                            self.model == GoogleTranslate.TranslateModel.nmt
                        }, set: {
                            if $0 {
                                self.model = GoogleTranslate.TranslateModel.nmt
                                self.reloadLanguages()
                            }
                        })) {
                            Text("Neural Machine Translation")
                        }
                        Toggle(isOn: Binding(get: { 
                            self.model == GoogleTranslate.TranslateModel.base
                        }, set: {
                            if $0 {
                                self.model = GoogleTranslate.TranslateModel.base
                                self.reloadLanguages()
                            }
                        })) {
                            Text("Phrase-Based Machine Translation")
                        }
                    }
                    Button(action: {
                        NSApplication.shared.terminate(self)
                    }, label: { Text("Quit") })
                }
                .scaledToFit()
                .menuButtonStyle(BorderlessButtonMenuButtonStyle() )
            }
            TextField("Translate From", text: $translateFrom).disabled(!loaded)
            TextField("Translate To", text: $translateTo)
        }
        .padding(.all, 10.0)
        .onAppear(perform: onload)
    }
    
    private static let fromlanKey = "fromLan"
    private static let tolanKey = "toLan"
    private static let modelKey = "model"
    
    private func reloadLanguages(){
        self.languagesMap = self.translateManager.supportedLanguages[self.model]!
    }
    
    private func translateStart(){
        var translateParam = translateManager.defaultTranslateParams()
        if fromLan != "auto" {
            translateParam.source = fromLan
        }
        translateParam.target = toLan
        translateParam.text = [translateFrom]
        translateParam.model = model
        translateTo = "(Translating)"
        print(translateParam)
        translateManager.translate(params: translateParam, 
                                   errorHandler: handleError,
                                   resultHandler: handleResult)
    }
    
    private func handleError(error: String){
        NSLog(error)
        translateTo = error.hasPrefix("Error requesting")
            ? "(Network Error)"
            : "(Unknown Error)"
    }
    
    private func handleResult(results: [GoogleTranslate.TranslateResponseTranslation]){
        if let result = results.first {
            detectedLan = languagesMap[result.detectedSourceLanguage ?? ""] ?? ""
            translateTo = result.translatedText
        }
    }
    
    private func onload(){
        loadPref()
        translateManager.loadSupportedLanguages(onComplete: {
            for m in self.translateManager.supportedLanguages{
                var loaded: [String] = []
                for l in m.value.sorted(by: { $0.key < $1.key }) {
                    if loaded.contains(l.value){
                        self.translateManager.supportedLanguages[m.key]![l.key] = nil
                    }
                    loaded.append(l.value)
                }
            }
            self.loaded = true
            self.reloadLanguages()
        }, errorHandler: handleError)
    }
    
    private func loadPref(){
        let prefs = UserDefaults.standard
        fromLan = prefs.string(forKey: ContentView.fromlanKey) ?? "en"
        toLan = prefs.string(forKey: ContentView.tolanKey) ?? "en"
        model = GoogleTranslate.TranslateModel(
            prefs.string(forKey: ContentView.modelKey) ?? "") ?? .base
    }
    
    private func savePref(){
        let prefs = UserDefaults.standard
        prefs.set(fromLan, forKey: ContentView.fromlanKey)
        prefs.set(toLan, forKey: ContentView.tolanKey)
        prefs.set(self.model.description, forKey: ContentView.modelKey)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(translateManager: translateManagerSetup())
    }
}
