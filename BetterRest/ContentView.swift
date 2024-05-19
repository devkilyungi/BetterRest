//
//  ContentView.swift
//  BetterRest
//
//  Created by Victor Kilyungi on 17/05/2024.
//

import CoreML
import SwiftUI

struct ContentView: View {
    
    @State private var wakeUp = defaultWakeTime
    @State private var sleepDuration = 8.0
    @State private var coffeeIntake = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var isShowingAlert = false
    @State private var recommendedBedtime = "Not calculated yet"
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? .now
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("BetterRest")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Form {
                    Section(header: Text("Your Settings").font(.headline)) {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("When do you want to wake up?")
                                .font(.subheadline)
                            
                            DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                        }
                        .onChange(of: wakeUp) { calculateBedtime() }
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Desired amount of sleep")
                                .font(.subheadline)
                            
                            Stepper("\(sleepDuration.formatted()) hours", value: $sleepDuration, in: 4...12, step: 0.25)
                        }
                        .onChange(of: sleepDuration) { calculateBedtime() }
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Text("Daily coffee intake")
                                .font(.subheadline)
                            
                            Stepper("^[\(coffeeIntake) cup](inflect: true)", value: $coffeeIntake, in: 1...20)
                        }
                        .onChange(of: coffeeIntake) { calculateBedtime() }
                    }
                    
                    Section(header: Text("Recommendation").font(.headline)) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Your recommended bedtime is:")
                                .font(.subheadline)
                            
                            Text(recommendedBedtime)
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                    }
                    
                    Section(header: Text("Sleep Quality").font(.headline)) {
                        NavigationLink(destination: SleepQualityView()) {
                            Text("Rate your sleep quality")
                        }
                    }
                    
                    Section(header: Text("Weekly Summary").font(.headline)) {
                        NavigationLink(destination: WeeklySummaryView()) {
                            Text("View Weekly Summary")
                        }
                    }
                }
            }
            .alert(alertTitle, isPresented: $isShowingAlert) {
                Button("OK") { }
            } message: {
                Text(alertMessage)
            }
        }
    }
    
    func calculateBedtime() {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(
                wake: Double(hour + minute),
                estimatedSleep: sleepDuration,
                coffee: Double(coffeeIntake)
            )
            
            let sleepTime = wakeUp - prediction.actualSleep
            recommendedBedtime = sleepTime.formatted(date: .omitted, time: .shortened)
        } catch {
            isShowingAlert = true
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
        }
    }
}

struct SleepData: Identifiable, Codable, Hashable {
    var id = UUID()
    var date: Date
    var quality: Int
    var comments: String
}

// View for rating sleep quality
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

// View for displaying weekly summary
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
    ContentView()
}
