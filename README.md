# GoogleTranslateTab

The project has two parts

## Part 1 Google Translate API for swift

All APIs are defined in `GoogleTranslateApi.swift` and managed by `GoogleTranslate`

Only the basic APIs are supported (translate, detect language, and get all supported languages)

A google translate API key is required to use the this library, which can be requested for free on https://cloud.google.com/translate/

Sample code is contained in `main.swift`

## Part 2 A menu tab app for Google Translate

The project is written with SwiftUI

A google translate API key is required to use the this application, which can be requested for free on https://cloud.google.com/translate/

Open `Info.plist` and paste the API key next to `GoogleApiKey`
