//
//  String+Extensions.swift
//  StrapiChat
//
//  Created by Duc on 19/8/24.
//

import Foundation

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
    var isBlank: Bool { trimmed.isEmpty }
    var isNotBlank: Bool { !isBlank }
}

extension String? {
    var isNilOrBlank: Bool { (self ?? "").isBlank }
    var isNotNilOrBlank: Bool { !isNilOrBlank }
}

extension String {
    var intValue: Int? { Int(self) }
}
