//
//  GoogleTranslateApi.swift
//  GoogleTranslateTab
//
//  Created by Toby on 2020-08-03.
//  Copyright © 2020 Toby. All rights reserved.
//

import Foundation

/// Translation API, Basic in https://cloud.google.com/translate/docs/apis 
/// under REST reference/Basic
extension GoogleTranslate {
    
    /** Translate **/
    
    /// Post request url for translate
    public static let translateUrlBase = 
        "https://translation.googleapis.com/language/translate/v2"
    
    /// Parameters that can be used for translating the text
    public struct TranslateParams{
        
        /// The input text to translate. 
        /// Provide an array of strings to translate multiple phrases. 
        /// The maximum number of strings is 128.
        var text: [String]
        
        /// The language of the source text, 
        /// set to one of the language codes listed in `langulageOptions`. 
        /// If the source language is nil, 
        /// the API will attempt to detect the source language automatically 
        /// and return it within the response.
        var source: String?
        
        /// The language to use for translation of the input text, 
        /// set to one of the language codes listed in `langulageOptions`.
        var target: String
        
        /// See `TranslateModel`
        var model: TranslateModel?
        
        /// See `TranslateFormat`
        var format: TranslateFormat
        
        /// A valid API key to handle requests for this API. 
        /// If you are using OAuth 2.0 service account credentials (recommended), 
        /// do not supply this parameter.
        var key: String?
    }
    
    /// A response for translate
    public struct TranslateResponse: Codable{
        var data: TranslateResponseList
    }
    
    /// A response list contains a list of separate language translation responses
    public struct TranslateResponseList: Codable{
        var translations: [TranslateResponseTranslation]
    }
    
    /// Contains a list of translation results for the requested text
    public struct TranslateResponseTranslation: Codable{
        
        /// The source language of the initial request, detected automatically, 
        /// if no source language was passed within the initial request. 
        /// If the source language was passed, auto-detection of the language 
        /// will not occur and this field will be omitted.
        var detectedSourceLanguage: String?
        
        /// Text translated into the target language.
        var translatedText: String
        
        /// The translation model. 
        /// Can be either base for the Phrase-Based Machine Translation (PBMT) model, 
        /// or nmt for the Neural Machine Translation (NMT) model.
        ///
        /// If you did not include a model parameter with your request, 
        /// then this field is not included in the response.
        var model: String?
    }
    
    /// Build url for translate
    public static func buildTranslateRequestUrl(params: TranslateParams) -> String{
        return translateUrlBase + buildParamString(params: [
                ("target", params.target),
                ("format", params.format.description),
                ("source", params.source),
                ("model", params.model?.description),
                ("key", params.key)
            ] + params.text.map{ ("q", $0) } )
    }
    
    /** Detect **/
    
    /// Post request url for detect
    public static let detectUrlBase = 
        "https://translation.googleapis.com/language/translate/v2/detect"
    
    /// Parameters that can be used for detecting the language of the text
    public struct DetectParams{
        
        /// The input text upon which to perform language detection. 
        /// Provide an array of strings to perform language detection 
        /// on multiple text inputs.
        var text: [String]
        
        /// A valid API key to handle requests for this API. 
        /// If you are using OAuth 2.0 service account credentials (recommended), 
        /// do not supply this parameter.
        var key: String?
    }
    
    /// A response for detect
    public struct DetectResponse: Codable{
        var data: DetectResponseList
    }
    
    /// A response list contains a list of separate language detection responses.
    public struct DetectResponseList: Codable{
        var detections: [[DetectResponseResult]]
    }
    
    /// Language detection results for each input text piece.
    public struct DetectResponseResult: Codable{
        
        /// The detected language
        var language: String
        
        /// Deprecated
        /// Indicates whether the language detection result is reliable
        var isReliable: Bool
        
        /// Deprecated 
        /// The confidence of the detection result for this language
        var confidence: Float
    }
    
    /// Build url for detect
    public static func buildDetectRequestUrl(params: DetectParams) -> String{
        return detectUrlBase + buildParamString(params: [("key", params.key)]
            + params.text.map{ ("q", $0) } )
    }
    
    /** Language **/
    
    /// Get request url for languages
    public static let languagesUrlBase = 
        "https://translation.googleapis.com/language/translate/v2/languages"
    
    /// Parameters that can be used for Getting a list of languages
    public struct LanguagesParams{
        
        /// The target language code for the results. 
        /// If specified, 
        /// then the language names are returned in the name field of the response,
        /// localized in the target language. 
        /// If you do not supply a target language, 
        /// then the name field is omitted from the response 
        /// and only the language codes are returned.
        var target: String?
        
        /// The translation model of the supported languages. 
        /// Can be either base to return languages supported by 
        /// the Phrase-Based Machine Translation (PBMT) model, 
        /// or nmt to return languages supported by 
        /// the Neural Machine Translation (NMT) model. 
        /// If omitted, then all supported languages are returned.
        /// 
        /// Languages supported by the NMT model can only be translated to 
        /// or from English (en).
        var model: TranslateModel?
        
        /// A valid API key to handle requests for this API. 
        /// If you are using OAuth 2.0 service account credentials (recommended), 
        /// do not supply this parameter.
        var key: String?
    }
    
    /// A response for language
    public struct LanguagesResponse: Codable{
        var data: LanguagesResponseList
    }
    
    /// A response list contains a list of separate supported language responses.
    public struct LanguagesResponseList: Codable{
        var languages: [LanguagesResponseLanguage]
    }
    
    /// A single supported language response corresponds 
    /// to information related to one supported language
    public struct LanguagesResponseLanguage: Codable{
        
        /// Supported language code, generally consisting of its ISO 639-1 identifier. 
        /// (E.g. 'en', 'ja'). 
        /// In certain cases, BCP-47 codes including language + region identifiers 
        /// are returned (e.g. 'zh-TW' and 'zh-CH')
        var language: String
        
        /// Human readable name of the language localized to the target language.
        var name: String?
    }

    /// Build url for getting list of supported languages
    public static func buildLanguagesUrlBase(params: LanguagesParams) -> String {
        return languagesUrlBase + buildParamString(params: [
            ("target", params.target),
            ("model", params.model?.description),
            ("key", params.key?.description)
        ])
    }
    
    /// The translation model. 
    ///  
    /// If the model is nmt, 
    /// and the requested language translation pair is not supported for the NMT model, 
    /// then the request is translated using the PBMT model.
    public enum TranslateModel: LosslessStringConvertible, CaseIterable {
        
        /// Phrase-Based Machine Translation (PBMT) model
        case base
        
        /// Neural Machine Translation (NMT) model
        case nmt
        
        public var description: String {
            switch self{
            case .base:
                return "base"
            case .nmt:
                return "nmt"
            }
        }
        
        public init?(_ description: String) {
            switch description {
            case "base":
                self = .base
            case "nmt":
                self = .nmt
            default:
                return nil
            }
        }
    }
    
    /// The format of the source text
    public enum TranslateFormat: CustomStringConvertible{
        
        /// HTML
        case html
        
        /// plain-text
        case text
        
        public var description: String {
            switch self{
            case .html:
                return "html"
            case .text:
                return "text"
            }
        }
    }
    
    /// Helper function for build the query string of an url
    /// 
    /// If the value is nil, the parameter is skipped
    /// - Parameter params: a dictionary from parameter name to value
    /// - Returns: the query param string
    private static func buildParamString(params: [(String, String?)]) -> String{
        return params.reduce(""){ result, pair in
            if let v = pair.1?
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                return "\(result == "" ? "?" : "\(result)&")\(pair.0)=\(v)"
            } else {
                return result
            }
        }
    }
}

