//
//  ContentView.swift
//  BetterRest
//
//  Created by Samuel F. Ademola on 12/21/19.
//  Copyright © 2019 Nomizo. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    
    //  If you try compiling that code you’ll see it fails, and the reason is that we’re accessing one property from inside another – Swift doesn’t know which order the properties will be created in, so this isn’t allowed.
    
    //  The fix here is simple: we can make defaultWakeTime a static variable, which means it belongs to the ContentView struct itself rather than a single instance of that struct. This in turn means defaultWakeTime can be read whenever we want, because it doesn’t rely on the existence of any other properties.
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    
    
    var body: some View {
        NavigationView {
            Form {
                
                // 1: Date Selector
                VStack (alignment: .leading, spacing: 0) {
                    Text("When do you wan to wake up?")
                        .font(.headline)
                    
                    DatePicker("Please ebter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                        .datePickerStyle(WheelDatePickerStyle())
                }
                
                
                // 2: Sleep Selector
                VStack (alignment: .leading, spacing: 0) {
                    Text("Desired amount of sleep")
                        .font(.headline)
                    
                    Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                        Text("\(sleepAmount, specifier: "%g") hours")
                    }
                    
                }
                
                // 3: Coffee Selector
                VStack (alignment: .leading, spacing: 0) {
                    Text("Daily coffee intake")
                        .font(.headline)
                    
                    Stepper(value: $coffeeAmount, in: 1...20) {
                        if coffeeAmount == 1 {
                            Text("1 cup")
                        } else {
                            Text("\(coffeeAmount) cups")
                        }
                    }
                }
            }
                
            .navigationBarTitle("BetterRest")
            .navigationBarItems(trailing: Button(action: calculateBetime) {
                Text("Calculate")
            })
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
        
    }
    func calculateBetime() {
        
        let model = SleepCalculator()
        
        // But figuring out the wake time requires more thinking, because our wakeUp property is a Date not a Double representing the number of seconds.
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        
        //  All we then need to do is multiply the minute by 60 (to get seconds rather than minutes), and the hour by 60 and 60 (to get seconds rather than hours).
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        
        // Do / Catch block just in case any error occurs durring the prediction model
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            // DateFormatter can format dates and times in all sorts of ways using its dateStyle and timeStyle properties. In this instance, though, we just want a time string so we can put that into alertMessage.
            let formater = DateFormatter()
            formater.timeStyle = .short
            
            alertMessage = formater.string(from: sleepTime)
            alertTitle = "Your ideal bebtime is..."
            
        } catch {
            alertTitle = "Error"
            alertMessage = "Sorry, there was a problem calculating your bedtime."
            
        }
        showingAlert = true
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
