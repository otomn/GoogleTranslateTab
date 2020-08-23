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

### Issues:

- Input and output field can only be one line due to the limitation of SwiftUI (will update after SwiftUI 2 is out)
- Popover cannot be automatically dismissed when the user clicks away. This is due to a bug in SwiftUI
- Cannot set the program to start on boot because I don't have a developers account to sign it. But you can still add it to login items manually in `System Preferences`
