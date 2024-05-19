//
//  SleepData.swift
//  BetterRest
//
//  Created by Victor Kilyungi on 19/05/2024.
//

import Foundation

struct SleepData: Identifiable, Codable, Hashable {
    var id = UUID()
    var date: Date
    var quality: Int
    var comments: String
}
