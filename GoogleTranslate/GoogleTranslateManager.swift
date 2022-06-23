//
//  GoogleTranslate.swift
//  GoogleTranslateTab
//
//  Created by Toby on 2020-08-03.
//  Copyright © 2020 Toby. All rights reserved.
//

import Foundation

/// Google Translate Api
/// Can translate text or detect the language used
open class GoogleTranslate{
    
    /// json decoder used by the manager
    private let jsonDecoder = JSONDecoder()
    
    /// Google Translate Api key, can be requested for free
    public var apiKey: String?
    
    /// The language where the names of the supported languages are stored in
    public var userLanguage: String
    
    /// Supported languages for models [code: name]
    public var supportedLanguages: [TranslateModel:[String:String]] = [:]
    
    /// Initialize a new manager with the api key and user language provided
    public init(apiKey: String, userLanguage: String){
        self.apiKey = apiKey
        self.userLanguage = userLanguage
    }
    
    /// Build an empty default `TranslateParams`
    public func defaultTranslateParams() -> TranslateParams{
        return TranslateParams(text: [],
            target: userLanguage, format: .text, key: apiKey)
    }
    
    /// Build an empty default `DetectParams`
    public func defaultDetectParams() -> DetectParams{
        return DetectParams(text: [], key: apiKey)
    }
    
    /// Build an empty default `LanguagesParams`
    public func defaultLanguageParams() -> LanguagesParams{
        return LanguagesParams(key: apiKey)
    }
    
    /// Translate a text
    /// - Parameters:
    ///   - params: A `TranslateParams`
    ///   - resultHandler: For processing translation result for each input
    public func translate(params: TranslateParams,
        noLanguageCheck: Bool = false,
        errorHandler: @escaping (_ error: String) -> (),
        resultHandler: @escaping (_ result: [TranslateResponseTranslation]) -> () ){
        /// Params checking
        if params.text.isEmpty {
            resultHandler([])
            return
        }
        if (!noLanguageCheck) {
            /// Google translate will use base if the language is not supported by nmt
            if let source = params.source {
                if supportedLanguages[.base]?[source] == nil {
                    errorHandler("Source language is invalid")
                    return
                }
            }
            if supportedLanguages[.base]?[params.target] == nil {
                errorHandler("Target language is invalid")
                return
            }
        }
        sendRequest(urlString: GoogleTranslate.buildTranslateRequestUrl(params: params), 
                    type: TranslateResponse.self, 
                    errorHandler: errorHandler,
                    resultHandler: { resultHandler($0.data.translations) } )
    }
    
    /// Detect the language used
    /// - Parameters:
    ///   - params: A DetectParams
    ///   - resultHandler: For processing the list of detected languages for each input
    public func detect(params: DetectParams,
        errorHandler: @escaping (_ error: String) -> (),
        resultHandler: @escaping (_ result: [[DetectResponseResult]]) -> () ){
        /// Params checking
        if params.text.isEmpty {
            resultHandler([])
            return
        }
        sendRequest(urlString: GoogleTranslate.buildDetectRequestUrl(params: params), 
                    type: DetectResponse.self, 
                    errorHandler: errorHandler,
                    resultHandler: { resultHandler($0.data.detections) } )
    }
    
    /// Get supported languages
    /// - Parameters:
    ///   - params: A `LanguagesParams`
    ///   - resultHandler: For processing the list of languages returned
    public func getSupportedLanguages(params: LanguagesParams,
        errorHandler: @escaping (_ error: String) -> (),
        resultHandler: @escaping (_ result: [LanguagesResponseLanguage]) -> () ){
        /// No error checking for target language since languages are not loaded
        sendRequest(urlString: GoogleTranslate.buildLanguagesUrlBase(params: params), 
                    type: LanguagesResponse.self, 
                    errorHandler: errorHandler,
                    resultHandler: { resultHandler($0.data.languages) } )
    }
    
    /// Populate supported languages
    /// - Parameter onComplete: task complete notifier
    public func loadSupportedLanguages(onComplete: @escaping ()->(),
        errorHandler: @escaping (_ error: String) -> ()){
        let group = DispatchGroup()
        var params = defaultLanguageParams()
        params.target = userLanguage
        for model in [TranslateModel.base, TranslateModel.nmt] {
            params.model = model
            group.enter()
            getSupportedLanguages(params: params, errorHandler: errorHandler){
                var languages: [String: String] = [:]
                for l in $0 {
                    languages[l.language] = l.name ?? l.language
                }
                self.supportedLanguages[model] = languages
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue(label: "loadLanguages"), execute: onComplete)
    }
    
    /// Send a html request and parse the result using json decoder
    /// 
    /// Error checkings are:
    /// - error in the responses
    /// - data or response are nil
    /// - response status code is not 200
    /// 
    /// - Parameters:
    ///   - urlString: The url to request
    ///   - type: The expected type of return result
    ///   - errorHandler: Handler when error happens
    ///   - resultHandler: Handler for handling the data in the response
    private func sendRequest<T: Decodable>(urlString: String, 
                                          type: T.Type,
                                          errorHandler: @escaping (_ error: String) -> (),
                                          resultHandler: @escaping (_ result: T) -> ()){
        sendRequest(urlString: urlString, errorHandler: errorHandler){ data in
            do{
                resultHandler(try self.jsonDecoder.decode(T.self, from: data))
            } catch {
                errorHandler(error.localizedDescription)
            }
        }
    }
    
    /// Send a html request
    /// 
    /// Error checkings are:
    /// - error in the responses
    /// - data or response are nil
    /// - response status code is not 200
    /// 
    /// - Parameters:
    ///   - urlString: The url to request
    ///   - errorHandler: Handler when error happens
    ///   - resultHandler: Handler for handling the data in the response
    private func sendRequest(urlString: String,
                            errorHandler: @escaping (_ error: String) -> (),
                            resultHandler: @escaping (_ result: Data) -> ()){
        guard let url = URL(string: urlString) else { return }
        let errorMsg = "Error requesting \(urlString)\n"
        URLSession.shared.dataTask(with: url){ data, response, error in
            if let error = error {
                errorHandler(errorMsg + error.localizedDescription)
                return
            }
            guard let data = data, let response = response as? HTTPURLResponse else {
                errorHandler("\(errorMsg) Http response has no data or response")
                return
            }
            if response.statusCode != 200 {
                errorHandler("\(errorMsg) Status code\(response.statusCode) is not 200"
                    + (String(data: data, encoding: .utf8) ?? ""))
                return
            }
            resultHandler(data)
        }.resume()
    }
    
}
