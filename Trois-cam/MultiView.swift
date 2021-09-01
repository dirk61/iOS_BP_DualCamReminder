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
import EventKit


let RTime = 10
let subNet = "101"

let motion = CMMotionManager()
var exp = ""
let ID2 = "01"
let ID = "01/Data"
let accName = "/Accelerometer.csv"
let gyroName = "/GyroScope.csv"
let magneName = "/Magnenometer.csv"
let waveName = "/Wave.csv"
let frontName = "/Front.mov"
let fingerName = "/PPG.mov"
let audioName = "/Audio.m4a"
let depthName = "/Depth"
let BPName = "/BP.txt"

let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String

var accURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(ID + accName)
var gyroURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(ID + gyroName)
var magneURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(ID + magneName)
var waveURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(ID + waveName)
var frontURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(ID + frontName)
var fingerURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(ID + fingerName)
var audioURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(ID + audioName)
var depthURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(ID + depthName)
var BPURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(ID + BPName)

var accOutput = OutputStream.toMemory()
var accCsvWriter = CHCSVWriter(outputStream: accOutput, encoding: String.Encoding.utf8.rawValue, delimiter: ",".utf16.first!)
var accBuffer = (accOutput.property(forKey: .dataWrittenToMemoryStreamKey) as? Data)!

var gyroOutput = OutputStream.toMemory()
var gyroCsvWriter = CHCSVWriter(outputStream: gyroOutput, encoding: String.Encoding.utf8.rawValue, delimiter: ",".utf16.first!)
var gyroBuffer = (gyroOutput.property(forKey: .dataWrittenToMemoryStreamKey) as? Data)!

var magneOutput = OutputStream.toMemory()
var magneCsvWriter = CHCSVWriter(outputStream: magneOutput, encoding: String.Encoding.utf8.rawValue, delimiter: ",".utf16.first!)
var magneBuffer = (magneOutput.property(forKey: .dataWrittenToMemoryStreamKey) as? Data)!

var waveOutput = OutputStream.toMemory()
var waveCsvWriter = CHCSVWriter(outputStream: waveOutput, encoding: String.Encoding.utf8.rawValue, delimiter: ",".utf16.first!)
var waveBuffer = (waveOutput.property(forKey: .dataWrittenToMemoryStreamKey) as? Data)!



var dateStr = ""

var frontdispatch: DispatchQueue = DispatchQueue(label: "Front")
var backdispatch: DispatchQueue = DispatchQueue(label: "Back")

struct MultiView: View{
    @State private var timeRemaining = RTime
    @State private var start = false
    @State private var selectedMode = "Auto"
    @State private var showingAlert = true
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    let cameraSource = CameraController()
    let eventSource = EventController()
    
    
    @State var selectedIndex:Int? = nil
    
    var body: some View {
        VStack{
            Text("1.点击下方【打开闪光灯】打开闪光灯").padding()
            Text("2.用右手食指盖住后置摄像头直到屏幕完全变红").padding()
            Text("3.保持静止，脸处在画面中央，点击【开始录制】").padding()
//            Text("Selected:\(ExperimentStr)")
//            Text("Selected:\(selectedMode)")
            HStack(spacing:0){
                
                ForEach(Array([Color.green, Color.red].enumerated()),id: \.offset){   (index,value) in
                    CameraView(color: value, session: self.cameraSource.captureSession, index: index,selectedIndex:self.selectedIndex).frame(width: 216, height: 288, alignment: .center)
                    
                }
                
            }.alert(isPresented: $showingAlert, content: {
                Alert(title: Text("注意事项"), message: Text("请先测量三次血压"), dismissButton:.cancel())
            })
            
            Button(action: {toggleTorch(on: true)},label:{Text("打开闪光灯")}).padding()
            Text("剩余时间:\(timeRemaining)").padding()
//            Button(action: {manualISO();manualISOBack();selectedMode="Manual"},label:{Text("manual")})
//            Button(action: {autoISO();selectedMode = "Auto"},label:{Text("auto")})
            
            Button(action:{start = true;print(SBP_1, SBP_2, SBP_3);dateStr = date2Str();mkdirectory(dateStr);toggleTorch(on: true) ;manualISOBack();manualISO();BPURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(dateStr + BPName);recordBP();frontURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(dateStr + frontName);fingerURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(dateStr+fingerName);accURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(dateStr + accName);gyroURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(dateStr + gyroName);magneURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(dateStr + magneName);waveURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(dateStr + waveName);audioURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(dateStr + audioName);depthURL = URL(fileURLWithPath: documentDirectoryPath).appendingPathComponent(dateStr + depthName);cameraSource.prepareDepth();
                    frontdispatch.async {
                        cameraSource.startRecord();
                    }; backdispatch.async {
                        cameraSource.startRecord2();
                    }; cameraSource.startAudio();collectSensorData()},label:{Text("开始录制")})
            //            Toggle("Start Survey", isOn: $start)
            
            Spacer()
        }.onReceive(timer){time in
            if self.timeRemaining > 0 && self.start{
                self.timeRemaining -= 1
           
                //                var dataqueue = DispatchQueue(label: "data" + String(self.timeRemaining))
                //                dataqueue.async {
                ////                    writeDepth(data: cameraSource.getdpth())
                //                    trueDepthCsvWriter?.writeField("1")
                //                    trueDepthCsvWriter?.finishLine()
                //                }
                
            }
            
            else if self.timeRemaining == 0{
                cameraSource.stopRecord()
                cameraSource.stopRecord2()
                cameraSource.finishAudio(success: true)
                
                stopDataCollection()
                self.timeRemaining -= 1
            
                start = false
                self.timeRemaining = RTime
                toggleTorch(on: false)
            }
        }
        
    }
}

struct MultiView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

func date2Str() -> String{
    let formatter3 = DateFormatter()
    formatter3.dateFormat = "y_MM_d_HH_mm_ss"
    print(formatter3.string(from: Date()))
    return formatter3.string(from: Date())
}

func toggleTorch(on: Bool) {
    guard let device = AVCaptureDevice.default(for: .video) else { return }
    
    if device.hasTorch {
        do {
            try device.lockForConfiguration()
            
            if on == true {
                device.torchMode = .on
            } else {
                device.torchMode = .off
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Torch could not be used")
        }
    } else {
        print("Torch is not available")
    }
}

func manualISO()
{
    
    guard let device = AVCaptureDevice.default(.builtInTrueDepthCamera,for: .video, position: .front) else { return }
    
    
    do {
        try device.lockForConfiguration()
        device.exposureMode = .custom
        device.setExposureModeCustom(duration: CMTimeMake(value: 1, timescale: 50), iso: 100, completionHandler: nil)
        device.whiteBalanceMode = .locked
        let fps60 = CMTimeMake(value: 1, timescale: 60)
        device.activeVideoMinFrameDuration = fps60;
        device.activeVideoMaxFrameDuration = fps60;
        
        device.unlockForConfiguration()
    } catch {
        print("Torch could not be used")
    }
}

func autoISO()
{
    guard let device = AVCaptureDevice.default(.builtInTrueDepthCamera,for: .video, position: .front) else { return }
    
    
    do {
        try device.lockForConfiguration()
        
        device.exposureMode = .autoExpose
        device.whiteBalanceMode = .autoWhiteBalance
        
        device.unlockForConfiguration()
    } catch {
        print("Torch could not be used")
    }
    
}

func mkdirectory(_ back:String){
    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]
    let docURL = URL(string: documentsDirectory)!
    let dataPath = docURL.appendingPathComponent(back)
    if !FileManager.default.fileExists(atPath: dataPath.path) {
        do {
            try FileManager.default.createDirectory(atPath: dataPath.path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
}
func manualISOBack()
{
    
    guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
    
    
    do {
        try device.lockForConfiguration()
        device.exposureMode = .locked
        device.exposureMode = .custom
        device.setExposureModeCustom(duration: CMTimeMake(value: 1, timescale: 50), iso: 100, completionHandler: nil)
        device.whiteBalanceMode = .locked
        device.focusMode = .locked
        let fps60 = CMTimeMake(value: 1, timescale: 60)
        device.activeVideoMinFrameDuration = fps60;
        device.activeVideoMaxFrameDuration = fps60;
      
        device.unlockForConfiguration()
    } catch {
        print("Torch could not be used")
    }
}


func autoISOBack()
{
    guard let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
    
    
    do {
        try device.lockForConfiguration()
        
        device.exposureMode = .autoExpose
        
        device.unlockForConfiguration()
    } catch {
        print("Torch could not be used")
    }
    
}

func collectSensorData(){
    if motion.isAccelerometerAvailable && motion.isGyroAvailable && motion.isMagnetometerAvailable{
        motion.accelerometerUpdateInterval = 1.0 / 60.0
        motion.gyroUpdateInterval = 1.0 / 60.0
        motion.magnetometerUpdateInterval = 1.0 / 60.0
        
        motion.startAccelerometerUpdates()
        motion.startGyroUpdates()
        motion.startMagnetometerUpdates()
        
        var timer = Timer(fire: Date(), interval: (1.0/30.0), repeats: true, block: {(timer) in
            if let data = motion.accelerometerData{
                
                accCsvWriter?.writeField(String(Int(Date().timeIntervalSince1970 * 1000)))
                accCsvWriter?.writeField(String(data.acceleration.x))
                accCsvWriter?.writeField(String(data.acceleration.y))
                accCsvWriter?.writeField(String(data.acceleration.z))
                accCsvWriter?.finishLine()
            }
            
            if let data = motion.gyroData{
                gyroCsvWriter?.writeField(String(Int(Date().timeIntervalSince1970 * 1000)))
                gyroCsvWriter?.writeField(String(data.rotationRate.x))
                gyroCsvWriter?.writeField(String(data.rotationRate.y))
                gyroCsvWriter?.writeField(String(data.rotationRate.z))
                gyroCsvWriter?.finishLine()
            }
            
            if let data = motion.magnetometerData{
                magneCsvWriter?.writeField(String(Int(Date().timeIntervalSince1970 * 1000)))
                magneCsvWriter?.writeField(String(data.magneticField.x))
                magneCsvWriter?.writeField(String(data.magneticField.y))
                magneCsvWriter?.writeField(String(data.magneticField.z))
                magneCsvWriter?.finishLine()
            }
            
        })
        
        RunLoop.current.add(timer, forMode: .default)
    }
}


func stopDataCollection() {
    do{
        
        try accBuffer.write(to: accURL)
        try gyroBuffer.write(to: gyroURL)
        try magneBuffer.write(to: magneURL)
    }
    catch{
        
    }
    
    
    motion.stopGyroUpdates()
    motion.stopMagnetometerUpdates()
    motion.stopAccelerometerUpdates()
}

func recordBP(){
//    var BPOutput = OutputStream.toMemory()
//    var BPCsvWriter = CHCSVWriter(outputStream: BPOutput, encoding: String.Encoding.utf8.rawValue, delimiter: ",".utf16.first!)
//    var BPBuffer = (BPOutput.property(forKey: .dataWrittenToMemoryStreamKey) as? Data)!
//
//    BPCsvWriter?.writeField(SBP_1)
//    BPCsvWriter?.writeField(DBP_1)
//    BPCsvWriter?.writeField(HR_1)
//    BPCsvWriter?.finishLine()
//    BPCsvWriter?.writeField(SBP_2)
//    BPCsvWriter?.writeField(DBP_2)
//    BPCsvWriter?.writeField(HR_2)
//    BPCsvWriter?.finishLine()
//    BPCsvWriter?.writeField(SBP_3)
//    BPCsvWriter?.writeField(DBP_3)
//    BPCsvWriter?.writeField(HR_3)
//    BPCsvWriter?.finishLine()
//    do{
//
//        try BPBuffer.write(to: BPURL)
////        BPBuffer.removeAll()
//
//    }
//    catch{
//
//    }
    var BPStr = SBP_1 + " " + DBP_1 + " " + HR_1 + " " + SBP_2 + " " + DBP_2 + " " + HR_2 + " " + SBP_3 + " " + DBP_3 + " " + HR_3
    do {
        try BPStr.write(to: BPURL, atomically: true, encoding: String.Encoding.utf8)
    } catch {
        // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
    }
}
