//
//  SleepQualityView.swift
//  BetterRest
//
//  Created by Victor Kilyungi on 19/05/2024.
//

import SwiftUI

struct SleepQualityView: View {
    @State private var sleepQuality = 3
    @State private var comments = ""
    @State private var isLoading = false
    @State private var saveError = false
    
    var body: some View {
        Form {
            Section(header: Text("How did you sleep?")) {
                Picker("Sleep Quality", selection: $sleepQuality) {
                    ForEach(1..<6) { rating in
                        Text("\(rating)").tag(rating)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                TextField("Comments", text: $comments, axis: .vertical)
                    .lineLimit(3...)
                    .foregroundColor(.primary).opacity(0.8)
                    .padding(10)
                    .autocorrectionDisabled(true)
                
                if isLoading {
                    HStack {
                        ProgressView()
                        Text("Saving...")
                    }
                } else if saveError {
                    Text("Failed to save. Please try again.")
                        .foregroundColor(.red)
                }
            }
            
            Button("Save") {
                saveSleepQuality()
            }
        }
        .navigationTitle("Sleep Quality")
        .onAppear(perform: loadSleepQuality)
    }
    
    func saveSleepQuality() {
        withAnimation {
            isLoading = true
            saveError = false
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let currentDate = Date()
            let sleepData = SleepData(date: currentDate, quality: sleepQuality, comments: comments)
            
            var weeklySummary = loadWeeklySummary()
            weeklySummary.append(sleepData)
            
            if let encodedData = try? JSONEncoder().encode(weeklySummary) {
                UserDefaults.standard.set(encodedData, forKey: "WeeklySummary")
                withAnimation {
                    isLoading = false
                    comments = ""
                }
            } else {
                withAnimation {
                    isLoading = false
                    saveError = true
                }
            }
        }
    }
    
    func loadWeeklySummary() -> [SleepData] {
        if let data = UserDefaults.standard.data(forKey: "WeeklySummary"),
           let decodedData = try? JSONDecoder().decode([SleepData].self, from: data) {
            return decodedData
        }
        return []
    }
    
    // Load last saved sleep quality data (if needed)
    func loadSleepQuality() {}
}


#Preview {
    SleepQualityView()
}
