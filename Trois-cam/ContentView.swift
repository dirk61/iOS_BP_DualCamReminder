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

var SBP_1:String = ""
var DBP_1:String = ""
var HR_1:String = ""
var SBP_2:String = ""
var DBP_2:String = ""
var HR_2:String = ""
var SBP_3:String = ""
var DBP_3:String = ""
var HR_3:String = ""

extension View{
    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
        NavigationView {
            ZStack {
                self
                    .navigationBarTitle("")
                    .navigationBarHidden(false)
                
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
    
    @State var finished = false
    @State var roundNum = 0
    @State var timeremaining = 60
    @State var rest = true
    @State var SBP = ""
    @State var DBP = ""
    @State var HR = ""
    @State var firstDone = false
    @State var secondDone = false
    @State var thirdDone = false
   
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    var body: some View {
        
        VStack{
            
            if #available(iOS 14.0, *) {
                Text("每次测量前，身体放松休息一分钟").font(.title3).foregroundColor(.red)
            } else {
                // Fallback on earlier versions
            }
            if #available(iOS 14.0, *) {
                Text("休息后开始血压测试，已完成(\(roundNum)/3)次").padding().font(.title3)
            } else {
                // Fallback on earlier versions
            }
            Group{
                Text("1.仪器紧贴左手手腕(距手腕一食指宽度)")
                Text("2.腰背挺直，手掌自然展开，双腿自然直立不交叉")
                Text("3.手肘支撑桌面，手腕抬到心脏同一高度")
                Text("4.点击仪器开始按钮，测量时身体不动，不说话")
                Text("5.将测得的数据填入下方框中，并点击记录数据")
            }
            HStack{
                Text("收缩压").aspectRatio(contentMode: .fit)
                TextField("血压", text: $SBP).padding().border(Color(UIColor.separator)).aspectRatio(contentMode: .fit)
                
                Text("舒张压").aspectRatio(contentMode: .fit)
                TextField("血压", text: $DBP).padding().border(Color(UIColor.separator)).aspectRatio(contentMode: .fit)
                
                
            }.aspectRatio(contentMode: .fill)
            HStack{
                Text("心率").aspectRatio(contentMode: .fit)
                TextField("心率", text: $HR).padding().border(Color(UIColor.separator)).aspectRatio(contentMode: .fit)
            }.aspectRatio(contentMode: .fit)
            Button("点击记录数据", action: {if roundNum == 0 {
                SBP_1 = SBP
                DBP_1 = DBP
                HR_1 = HR
                
                firstDone = true
                roundNum += 1

                SBP = ""
                DBP = ""
                HR = ""
            }else if roundNum == 1{
                
                SBP_2 = SBP
                DBP_2 = DBP
                HR_2 = HR
                firstDone = true
                roundNum += 1

                SBP = ""
                DBP = ""
                HR = ""
            }else if roundNum == 2{
                SBP_3 = SBP
                DBP_3 = DBP
                HR_3 = HR
                roundNum += 1
                SBP = ""
                DBP = ""
                HR = ""
                finished = true
                roundNum = 0
            }else{
                
            }}).padding().alert(isPresented: $firstDone){
                if roundNum == 1{
                return Alert(title: Text("数据记录成功"), message: Text("成功完成第1次测量记录，请在1分钟休息后再进行第2次测量"), dismissButton: .default(Text("继续测量")))
                }
                else if roundNum == 2{
                    
                    return Alert(title: Text("数据记录成功"), message: Text("成功完成第2次测量记录，请在1分钟休息后再进行第3次测量"), dismissButton: .default(Text("继续测量")))
                    }
                else {
                    return Alert(title: Text("数据记录成功"), message: Text("成功完成第3次测量记录"), dismissButton: .default(Text("继续测量")))
                }
            }
            HStack{
                Image("BP").resizable().frame(width: 200, height: 300, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).padding()
                Image("BP2").resizable().frame(width: 200, height: 300, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/).padding()
            }
            Spacer()
        }.navigate(to: MultiView(), when: $finished)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
