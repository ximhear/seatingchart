//
//  ContentView.swift
//  SeatingChart
//
//  Created by gzonelee on 2023/02/20.
//

import SwiftUI

struct ContentView: View {
    @State var stadiumZoomed = false
    @State var selectedTicketNumber: Int = 0
    @State var purchased = false
    var body: some View {
        VStack {
            if !stadiumZoomed {
                VStack {
                    Text("\(selectedTicketNumber)")
                        .foregroundColor(.white)
                        .font(.title)
                        .background {
                            Circle()
                                .fill(.red)
                                .frame(width: 32, height: 32)
                                .shadow(radius: 2, x: 2, y: 2)
                        }
                }
                .frame(width: 200)
                .background(.yellow)
                .transition(.move(edge: .leading).combined(with: .opacity))
                
            }
            else {
                Button {
                    withAnimation {
                        stadiumZoomed = false
                        purchased = true
                    }
                } label: {
                    Text("Buy")
                }

            }
            SeatingChartView(zoomed: $stadiumZoomed,
            selectedTicketsNumber: $selectedTicketNumber)
                .aspectRatio(1, contentMode: .fit)
                .padding()
        }
        .confirmationDialog("You bought", isPresented: $purchased, actions:{}, message: { Text("ggg") })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
