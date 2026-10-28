//
//  QRCodeItem.swift
//  QR Code Collector
//
//  Created by Nicholas Lim on 28/10/26.
//

import Foundation

nonisolated struct QRCodeItem: Hashable {
    let id = UUID()  // makes every item unique, even with the same text
    let value: String
    let scannedAt: Date
}
