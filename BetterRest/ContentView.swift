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

#Preview {
    ContentView()
}
