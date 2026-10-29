//
//  QRCodeStore.swift
//  QR Code Collector
//
//  Created by Nicholas Lim on 29/10/26.
//

import Foundation

final class QRCodeStore {
    static let defaultFileURL = URL.documentsDirectory.appending(
        path: "qrcodes.json"
    )

    private(set) var items: [QRCodeItem] = []
    private let fileURL: URL

    private static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    init(fileURL: URL = QRCodeStore.defaultFileURL) {
        self.fileURL = fileURL
        load()
    }

    func add(_ item: QRCodeItem) {
        items.append(item)
        save()
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path()) else {
            items = QRCodeItem.examples
            save()
            return
        }

        do {
            let data = try Data(contentsOf: fileURL)
            items = try Self.decoder.decode([QRCodeItem].self, from: data)
        } catch {
            print("Failed to load QR codes from \(fileURL): \(error)")
        }
    }

    private func save() {
        do {
            let data = try Self.encoder.encode(items)
            try data.write(to: fileURL, options: [.atomic])
        } catch {
            print("Failed to save QR codes to \(fileURL): \(error)")
        }
    }
}
