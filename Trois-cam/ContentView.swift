//
//  ContentView.swift
//  Trois-cam
//
//  Created by Joss Manger on 1/19/20.
//  Copyright © 2020 Joss Manger. All rights reserved.
//

import SwiftUI
import AVFoundation
import UIKit
import CoreLocation
import Photos
import CoreMotion
import SensorKit

var ExperimentStr = ""

extension View{
    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
            NavigationView {
                ZStack {
                    self
                        .navigationBarTitle("")
                        .navigationBarHidden(true)

                    NavigationLink(
                        destination: view
                            .navigationBarTitle("")
                            .navigationBarHidden(false),
                        isActive: binding
                    ) {
                        EmptyView()
                    }
                }
            }
        }
}

struct ContentView: View{
    
    

    @State var selectedIndex:Int? = nil
    @State var move = false
    var body: some View {
        MultiView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
