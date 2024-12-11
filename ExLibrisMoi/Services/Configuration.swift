import Foundation

struct Configuration {
    static var NYT_API_KEY: String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "NYT_API_KEY") as? String,
              !apiKey.isEmpty else {
            print("WARNING: NYT_API_KEY not found in Info.plist or is empty")
            return ""
        }
        return apiKey
    }

    static var GOOGLE_BOOKS_API_KEY: String {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_BOOKS_API_KEY") as? String,
              !apiKey.isEmpty else {
            print("WARNING: GOOGLE_BOOKS_API_KEY not found in Info.plist or is empty")
            return ""
        }
        return apiKey
    }
}
