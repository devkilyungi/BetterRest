//
//  WeeklySummaryView.swift
//  BetterRest
//
//  Created by Victor Kilyungi on 19/05/2024.
//

import SwiftUI

struct WeeklySummaryView: View {
    @State private var weeklySummary: [SleepData] = []
    
    var body: some View {
        List {
            ForEach(weeklySummary) { entry in
                VStack(alignment: .leading) {
                    Text("Date: \(entry.date.formatted(date: .abbreviated, time: .omitted))")
                        .font(.headline)
                    Text("Sleep Quality: \(entry.quality)")
                    if !entry.comments.isEmpty {
                        Text("Comments: \(entry.comments)")
                    }
                }
            }
        }
        .navigationTitle("Weekly Summary")
        .onAppear(perform: loadWeeklySummary)
    }
    
    func loadWeeklySummary() {
        if let data = UserDefaults.standard.data(forKey: "WeeklySummary"),
           let decodedData = try? JSONDecoder().decode([SleepData].self, from: data) {
            weeklySummary = decodedData
        }
    }
}

#Preview {
    WeeklySummaryView()
}
