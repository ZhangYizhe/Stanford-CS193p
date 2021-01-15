//
//  FilterFlights.swift
//  Enroute
//
//  Created by 张艺哲 on 2021/1/15.
//  Copyright © 2021 Stanford University. All rights reserved.
//

import SwiftUI

struct FilterFlights: View {
    @ObservedObject var allAirports = Airports.all
    @ObservedObject var allAirlines = Airlines.all
    
    @Binding var flightSearch: FlightSearch
    @Binding var isPresented : Bool
    
    @State private var draft : FlightSearch
    
    init(flightSearch: Binding<FlightSearch>, isPresented: Binding<Bool>) {
        _flightSearch = flightSearch
        _isPresented = isPresented
        _draft = State(wrappedValue: flightSearch.wrappedValue)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Picker("Destination", selection: $draft.destination) {
                    ForEach(allAirports.codes, id: \.self) { airport in
                        Text("\(self.allAirports[airport]?.friendlyName ?? airport)").tag(airport)
                    }
                }
                Picker("Origin", selection: $draft.origin) {
                    Text("Any").tag(String?.none)
                    ForEach(allAirports.codes, id: \.self) { airport in
                        Text(self.allAirports[airport]?.friendlyName ?? airport).tag(airport)
                    }
                }
                Picker("Airline", selection: $draft.airline) {
                    Text("Any").tag(String?.none)
                    ForEach(allAirlines.codes, id: \.self) { airline in
                        Text(self.allAirlines[airline]?.friendlyName ?? airline).tag(airline)
                    }
                }
                Toggle(isOn: $draft.inTheAir) {
                    Text("Enroute Only")
                }
            }
            .navigationBarTitle("Filter Flights")
            .navigationBarItems(leading: cancel, trailing: done)
        }
    }
    
    var cancel: some View {
        Button("Cancel") {
            isPresented = false
        }
    }
    
    var done: some View {
        Button("Done") {
            // make the actual changes
            flightSearch = draft
            isPresented = false
        }
    }
}

//struct FilterFlights_Previews: PreviewProvider {
//    static var previews: some View {
//        FilterFlights()
//    }
//}
