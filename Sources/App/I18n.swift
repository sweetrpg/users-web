import Vapor

class I18n {
  private static nonisolated(unsafe) var tables: [String: [String: String]] = [:]

  static func loadTables() throws {
    let decoder = JSONDecoder()
    let paths = [
      "Resources/Localizations/en.json",
      "frontends/users-web/Resources/Localizations/en.json",
    ]

    for path in paths {
      if let enData = try? String(contentsOfFile: path, encoding: .utf8).data(using: .utf8) {
        let enTable = try? decoder.decode([String: String].self, from: enData)
        if let table = enTable {
          tables["en"] = table
          return
        }
      }
    }
  }

  static func table(for locale: String) -> [String: String] {
    tables[locale] ?? tables["en"] ?? [:]
  }
}

extension Request {
  var l10n: [String: String] {
    I18n.table(for: "en")
  }
}
