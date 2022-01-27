import Foundation
import Combine

class TimedCache<Key: Hashable&Codable, Value: Codable> {
    struct Entry: Codable {
        let key: Key
        let value: Value
        let expirationDate: Date

        var isStale: Bool {
            Date() > expirationDate
        }
    }

    var file: URL {
        let folderURLs = FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        )
        let file = folderURLs[0].appendingPathComponent(name + ".cache")

        return file
    }

    lazy var cached: [Key: Entry] = {
        loadCache()
    }()

    let name: String

    let expirationInterval: TimeInterval

    init(name: String, interval: TimeInterval) {
        self.expirationInterval = interval
        self.name = name
    }

    private func saveCache() {
        do {
            let data = try JSONEncoder().encode(cached)
            try data.write(to: file)
        } catch {
            deleteAllEntries()
        }
    }

    func loadCache() -> [Key: Entry] {
        if let data = try? Data(contentsOf: file),
           let entry = try? JSONDecoder().decode([Key: Entry].self, from: data) {
            return entry
        }
        else {
            return [Key: Entry]()
        }
    }

    func setEntry(key: Key, value: Value) {
        let expirationDate = Date().addingTimeInterval(expirationInterval)
        let entry = Entry(key: key, value: value, expirationDate: expirationDate)

        cached[key] = entry
        saveCache()
    }

    func deleteEntry(key: Key) {
        cached[key] = nil
        saveCache()
    }

    func deleteAllEntries() {
        cached.forEach {
            cached[$0.key] = nil
        }
        try? FileManager.default.removeItem(at: file)
    }

    func validateCache() {
        cached.values
            .filter{ $0.isStale }
            .forEach {
                cached[$0.key] = nil
            }
        saveCache()
    }

    func entryPublisher(key: Key) -> AnyPublisher<Value, Never> {
        if let entry = cached[key], entry.isStale == false {
            return Optional.Publisher(entry.value)
                .eraseToAnyPublisher()
        } else {
            deleteEntry(key: key)
            return Optional.Publisher(nil)
                .eraseToAnyPublisher()
        }
    }
}
