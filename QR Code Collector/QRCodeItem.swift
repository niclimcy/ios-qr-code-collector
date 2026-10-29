//
//  QRCodeItem.swift
//  QR Code Collector
//
//  Created by Nicholas Lim on 28/10/26.
//

import Foundation

nonisolated struct QRCodeItem: Hashable, Codable {
    let id: UUID
    let value: String
    let scannedAt: Date

    init(id: UUID = UUID(), value: String, scannedAt: Date) {
        self.id = id
        self.value = value
        self.scannedAt = scannedAt
    }
}

extension QRCodeItem {
    static var examples: [QRCodeItem] {
        [
            QRCodeItem(value: "https://www.apple.com", scannedAt: .now),
            QRCodeItem(
                value: "WIFI:T:WPA;S:MyNetwork;P:password123;;",
                scannedAt: .now
            ),
            QRCodeItem(value: "mailto:hello@example.com", scannedAt: .now),
            QRCodeItem(value: "tel:+1234567890", scannedAt: .now),
        ]
    }
}
