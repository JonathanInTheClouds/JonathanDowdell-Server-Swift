//
//  StatusServerRow.swift
//  Server Swift
//
//  Created by Mettaworldj on 3/3/21.
//

import SwiftUI
import Combine

struct StatusServerRow: View {
    
    @ObservedObject private(set) var observableServerRowStatus: ObservableServerRowStatus
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 40) {
            ServerRowHeader(observableStatusServerRow: observableServerRowStatus)
            
            HStack(alignment: .center) {
                
                StatSection(progressValue: observableServerRowStatus.serverStatistic.cpuUsage,
                            altInnerRadius: observableServerRowStatus.serverStatistic.loadAvg1Min,
                            altMiddleRadius: observableServerRowStatus.serverStatistic.loadAvg5Min,
                            altOuterRadius: observableServerRowStatus.serverStatistic.loadAvg15Min,
                            frontName: "CPU", backName: "Load")
                    .padding(.leading, 4)
                
                Spacer()
                
                StatSection(progressValue: calculateMemory(),
                            altProgressValue: calculateCache(),
                            frontName: "Mem", backName: "Swap")
                
                Spacer()
                
                ReadWriteSection(name: "Traffic")
                
                Spacer()
                
                ReadWriteSection(name: "Disk")
                
            }
            .padding(.horizontal, 4)
        }
        .padding(.horizontal)
        .onAppear(perform: {
            observableServerRowStatus.startTimer()
        })
        .onDisappear(perform: {
            observableServerRowStatus.stopTimer()
        })
        
    }
    
    func calculateMemory() -> CGFloat? {
        guard let x = observableServerRowStatus.serverStatistic.usedMemoryTotal,
              let y = observableServerRowStatus.serverStatistic.memoryTotal else { return nil }
        return ((x / y) * 100)
    }
    
    func calculateCache() -> CGFloat? {
        guard let x = observableServerRowStatus.serverStatistic.cachedMemoryTotal,
              let y = observableServerRowStatus.serverStatistic.memoryTotal else { return nil }
        return ((x / y) * 100)
    }
}


struct StatusServerRow_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StatusServerRow(observableServerRowStatus: ObservableServerRowStatus(with: MockData.servers[0]))
                .preferredColorScheme(.dark)
                .frame(height: 100, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
            
            StatusServerRow(observableServerRowStatus: ObservableServerRowStatus(with: MockData.servers[0]))
                .preferredColorScheme(.light)
                .frame(height: 100, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
}

private struct ServerRowHeader: View {
    
    @ObservedObject private(set) var observableStatusServerRow: ObservableServerRowStatus
    
    @State private var shouldPush = false
    
    var body: some View {
        HStack(spacing: 15) {
            NavigationLink(
                destination: StatusServerDetailView(observableServerRowStatus: observableStatusServerRow), isActive: $shouldPush) {
                Button(action: {
                    observableStatusServerRow.canStopTimer = false
                    shouldPush.toggle()
                }, label: {
                    Text(observableStatusServerRow.server.name)
                        .foregroundColor(.primary)
                        .font(.system(.headline, design: .rounded))
                    Image(systemName: "bolt.horizontal.fill")
                        .foregroundColor(observableStatusServerRow.serverLoaded ? .accentColor : .gray)
                })
            }
            
            Spacer()
            
            Text(calculateTemp())
                .font(.custom("RobotoMono-Regular", fixedSize: 13))
                .foregroundColor(.gray)
            
            Button(action: {
                
            }, label: {
                Image(systemName: "cpu")
            })
            
            Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
                Image(systemName: "terminal")
            })
        }
    }
    
    func calculateTemp() -> String {
        guard let cpuTemp = observableStatusServerRow.serverStatistic.cpuTemp else { return "" }
        return "\(Int(cpuTemp))°C"
    }
}


extension View {
    
    func flipRotate(_ degrees : Double) -> some View {
        return rotation3DEffect(Angle(degrees: degrees), axis: (x: 0.0, y: 1.0, z: 0.0))
    }
    
    func placedOnCard(_ color: Color, frameSize: CGFloat = 50.0) -> some View {
        return padding(5).frame(width: frameSize, height: frameSize, alignment: .center).background(color)
    }
}
