# BetterRest

BetterRest is a simple sleep management app designed to help coffee drinkers optimize their sleep by recommending ideal bedtimes based on their wake-up time, desired sleep duration, and daily coffee intake. This project serves as an introduction to using Core ML and Create ML in SwiftUI projects.

## Features

- **Wake-Up Time Input:** Users can select their desired wake-up time using a `DatePicker`.
- **Sleep Duration Input:** Users can specify the amount of sleep they want using a `Stepper`.
- **Coffee Intake Input:** Users can record their daily coffee consumption using a `Stepper`.
- **Bedtime Recommendation:** The app calculates and displays the recommended bedtime based on user inputs using a Core ML model.

## Screenshots

![Screenshot](screenshot.png)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/BetterRest.git
   ```
2. Open the project in Xcode.

3. Build and run the project on your simulator or device.

## Usage

1. **Set Wake-Up Time:** Use the `DatePicker` to select the time you want to wake up.
2. **Set Sleep Amount:** Adjust the `Stepper` to set your desired hours of sleep.
3. **Set Coffee Intake:** Adjust the `Stepper` to indicate your daily coffee consumption.
4. **View Bedtime:** The app automatically calculates and displays the recommended bedtime based on your inputs.

## Core ML Integration

The app utilizes a Core ML model to predict the optimal bedtime. The model takes into account the user's wake-up time, desired sleep duration, and coffee intake to provide a personalized recommendation.

## Code Structure

- `ContentView.swift`: The main view of the app where users input their wake-up time, sleep amount, and coffee intake, and view the recommended bedtime.
- `calculateBedtime()`: A function that uses the Core ML model to calculate the recommended bedtime based on user inputs.

## Acknowledgements

- This project was created as a learning exercise to understand the integration of Core ML and Create ML in SwiftUI projects.
- Inspired by the "BetterRest" project from the 100 Days of SwiftUI course by Paul Hudson.

## Author

- Victor Kilyungi
