//
//  ViewController.swift
//  vertical_farm_project
//
//  Created by Cameron Stott on 30/03/2021.
//

import UIKit
import UserNotifications


class ViewController: UIViewController, UITextFieldDelegate {
    
    //declare variables
    @IBOutlet weak var waterServo: UILabel!
    @IBOutlet weak var waterLvlLbl: UILabel!
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var humLbl: UILabel!
    @IBOutlet weak var tempTxt: UITextField!
    @IBOutlet weak var humTxt: UITextField!
    var timer : Timer!
    let shape = CAShapeLayer()
    let track = CAShapeLayer()
    let tempShape = CAShapeLayer()
    let humShape = CAShapeLayer()
    let sqaure = CAShapeLayer()
    var minTempVal = 18
    var maxTempVal = 30
    var minHumVal = 40
    var maxHumVal = 50
    var minMoistureVal = 25
    @IBOutlet weak var minTemp: UITextField!
    @IBOutlet weak var maxTemp: UITextField!
    @IBOutlet weak var minHum: UITextField!
    @IBOutlet weak var maxHum: UITextField!
    @IBOutlet weak var minMoisture: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        access()
        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(variableReader), userInfo: nil, repeats: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 60000){
            self.timer.invalidate()
        }
        //functions to add layers on UI
        addTxtBoxPlaceholders()
        createCircleTrack()
        createCircle()
        createTempCircle()
        createHumCircle()
        createSquare()
    }
    
    // function to allow the user to tap out of the number pad
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        minTemp.resignFirstResponder()
        maxTemp.resignFirstResponder()
        minMoisture.resignFirstResponder()
        minHum.resignFirstResponder()
        maxHum.resignFirstResponder()
    }
    
    //function to add placeholder text on the text boxes to show the user what the current min and max values are
    func addTxtBoxPlaceholders(){
        minTemp.placeholder = String(minTempVal)
        maxTemp.placeholder = String(maxTempVal)
        minHum.placeholder = String(minHumVal)
        maxHum.placeholder = String(maxHumVal)
        minMoisture.placeholder = String(minMoistureVal)
    }
    
    //function to apply the new min and max values that the user typed in and updates the vaiables
    @IBAction func applyMinMax(_ sender: UIButton) {

        if minMoisture.text == ""{
            minMoisture.placeholder = String(minMoistureVal)
        }else{
            let forceMinMoisture = minMoisture.text!
            minMoistureVal = Int(forceMinMoisture)!
            minMoisture.text = ""
            minMoisture.placeholder = String(minMoistureVal)
        }
        if minHum.text == ""{
            minHum.placeholder = String(minHumVal)
        }else{
            let forceMinHum = minHum.text!
            minHumVal = Int(forceMinHum)!
            minHum.text = ""
            minHum.placeholder = String(minHumVal)
        }
        if maxHum.text == ""{
            maxHum.placeholder = String(maxHumVal)
        }else{
            let forceMaxHum = maxHum.text!
            maxHumVal = Int(forceMaxHum)!
            maxHum.text = ""
            maxHum.placeholder = String(maxHumVal)
        }
        if minTemp.text == ""{
            minTemp.placeholder = String(minTempVal)
        }else{
            let forceMinTemp = minTemp.text!
            minTempVal = Int(forceMinTemp)!
            minTemp.text = ""
            minTemp.placeholder = String(minTempVal)
        }
        if maxTemp.text == ""{
            maxTemp.placeholder = String(maxTempVal)
        }else{
            let forceMaxTemp = maxTemp.text!
            maxTempVal = Int(forceMaxTemp)!
            maxTemp.text = ""
            maxTemp.placeholder = String(maxTempVal)
        }
    }
    
    // function to create the square layer around the center buttons
    func createSquare(){
        sqaure.path = UIBezierPath(rect: CGRect(x: 30, y: 482, width: 365, height: 160)).cgPath
        sqaure.fillColor = UIColor.clear.cgColor
        sqaure.strokeColor = UIColor.white.cgColor
        sqaure.lineWidth = 2
        view.layer.addSublayer(sqaure)
    }
    
    //function to create the circle layer that is dynamic for the water moisture
    func createCircle(){
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 210, y: 332), radius: 70, startAngle: -(.pi/2), endAngle: .pi * 1.5 , clockwise:true)
        
        shape.path = circlePath.cgPath
        shape.lineWidth = 10
        shape.strokeColor = UIColor.blue.cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeEnd = 0.5
        view.layer.addSublayer(shape)
    }
    
    //function to create the circle layer for the temperature
    func createTempCircle(){
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 90, y: 160), radius: 70, startAngle: -(.pi/2), endAngle: .pi * 1.5 , clockwise:true)
        
        tempShape.path = circlePath.cgPath
        tempShape.lineWidth = 10
        tempShape.strokeColor = UIColor.yellow.cgColor
        tempShape.fillColor = UIColor.clear.cgColor
        tempShape.strokeEnd = 1
        view.layer.addSublayer(tempShape)
    }
    
    //function to create the circle layer for the humidity
    func createHumCircle(){
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 330, y: 160), radius: 70, startAngle: -(.pi/2), endAngle: .pi * 1.5 , clockwise:true)
        
        humShape.path = circlePath.cgPath
        humShape.lineWidth = 10
        humShape.strokeColor = UIColor.systemPink.cgColor
        humShape.fillColor = UIColor.clear.cgColor
        humShape.strokeEnd = 1
        view.layer.addSublayer(humShape)
    }
    
    //function to create the background circle that helps to show the soil moisture - this circle stays static
    func createCircleTrack(){
        let circlePath = UIBezierPath(arcCenter: CGPoint(x: 210, y: 332), radius: 70, startAngle: -(.pi/2), endAngle: .pi * 1.5 , clockwise:true)
        
        track.path = circlePath.cgPath
        track.lineWidth = 10
        track.strokeColor = UIColor.white.cgColor
        track.fillColor = UIColor.clear.cgColor
        track.strokeEnd = 1
        view.layer.addSublayer(track)
    }
    
    // provides the session access token to allow connection to the particle cloud
    func access(){
        if ParticleCloud.sharedInstance().injectSessionAccessToken("c58b3cec34b1b7ade8802e15e1627580e87ec999") {
            print("Session is active")
        } else {
            print("Bad access token provided")
        }
    }
    
    
    //function to invoke the servo on the particle device when the button is clicked
    @IBAction func waterOnBtn(_ sender: UIButton) {
        var myPhoton : ParticleDevice?
        ParticleCloud.sharedInstance().getDevices { (devices:[ParticleDevice]?, error:Error?) -> Void in
            if let _ = error {
                print("Check your internet connectivity")
            }
            else {
                if let d = devices {
                    for device in d {
                        if device.name == "Napier45" {
                            myPhoton = device
                            var task = myPhoton!.callFunction("WaterOn", withArguments: ["D8", 1]) { (resultCode : NSNumber?, error : Error?) -> Void in
                                if (error == nil) {
                                    print("Servo on D8 successfully turned on")
                                }
                                else{
                                    print(error)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //function to invoke led on on D6 pin on the partcle device when the on button is clicked
    @IBAction func turnOffLED(_ sender: UIButton) {
        var myPhoton : ParticleDevice?
        ParticleCloud.sharedInstance().getDevices { (devices:[ParticleDevice]?, error:Error?) -> Void in
            if let _ = error {
                print("Check your internet connectivity")
                print(error)
            }
            else {
                if let d = devices {
                    for device in d {
                        if device.name == "Napier45" {
                            myPhoton = device
                            var task = myPhoton!.callFunction("ledOff", withArguments: ["D6", 1]) { (resultCode : NSNumber?, error : Error?) -> Void in
                                if (error == nil) {
                                    print("LED on D7 successfully turned off")
                                }
                                else{
                                    print(error)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //function to invoke led off on D6 pin on the partcle device when the of button is clicked
    @IBAction func turnOnLED(_ sender: UIButton) {
        var myPhoton : ParticleDevice?
        ParticleCloud.sharedInstance().getDevices { (devices:[ParticleDevice]?, error:Error?) -> Void in
            if let _ = error {
                print("Check your internet connectivity")
            }
            else {
                if let d = devices {
                    for device in d {
                        if device.name == "Napier45" {
                            myPhoton = device
                            var task = myPhoton!.callFunction("ledOn", withArguments: ["D6", 1]) { (resultCode : NSNumber?, error : Error?) -> Void in
                                if (error == nil) {
                                    print("LED on D7 successfully turned on")
                                }
                                else{
                                    print(error)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    //fuction that reads the variables from the particle cloud and displays them on the mobile UI
    @objc func variableReader(){

        var myPhoton : ParticleDevice?
        ParticleCloud.sharedInstance().getDevices { (devices:[ParticleDevice]?, error:Error?) -> Void in
            if let _ = error {
                print("Check your internet connectivity")
                print(error)
            }
            else {
                if let d = devices {
                    for device in d {
                        if device.name == "Napier45" {
                            myPhoton = device
                            myPhoton!.getVariable("temperature", completion: { (result:Any?, error:Error?) -> Void in
                                if let _ = error {
                                    print("Failed reading temperature from device")
                                }
                                else {
                                    if let temp = result as? Double {
                                        print("Room temperature is \(String(temp)) degrees \(self.maxTempVal) \(self.minTempVal) \(self.maxHumVal) \(self.minHumVal)")
                                        if temp < Double(self.minTempVal) || temp > Double(self.maxTempVal){
                                            var myPhoton : ParticleDevice?
                                            ParticleCloud.sharedInstance().getDevices { (devices:[ParticleDevice]?, error:Error?) -> Void in
                                                if let _ = error {
                                                    print("Check your internet connectivity")
                                                }
                                                else {
                                                    if let d = devices {
                                                        for device in d {
                                                            if device.name == "Napier45" {
                                                                myPhoton = device
                                                                var task = myPhoton!.callFunction("ledTempOn", withArguments: ["D5", 1]) { (resultCode : NSNumber?, error : Error?) -> Void in
                                                                    if (error == nil) {
                                                                        print("LED on D5 successfully turned on")
                                                                    }
                                                                    else{
                                                                        print(error)
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        self.temp.text = String(format: "%.2f°", temp);
                                    }
                                }
                            })
                            myPhoton!.getVariable("humidity", completion: { (result:Any?, error:Error?) -> Void in
                                if let _ = error {
                                    print("Failed reading temperature from device")
                                }
                                else {
                                    if let hum = result as? Double {
                                        print("Room humidity is \(String(hum)) degrees")
                                        if hum < Double(self.minHumVal) || hum > Double(self.maxHumVal){
                                            var myPhoton : ParticleDevice?
                                            ParticleCloud.sharedInstance().getDevices { (devices:[ParticleDevice]?, error:Error?) -> Void in
                                                if let _ = error {
                                                    print("Check your internet connectivity")
                                                }
                                                else {
                                                    if let d = devices {
                                                        for device in d {
                                                            if device.name == "Napier45" {
                                                                myPhoton = device
                                                                var task = myPhoton!.callFunction("ledHumOn", withArguments: ["D4", 1]) { (resultCode : NSNumber?, error : Error?) -> Void in
                                                                    if (error == nil) {
                                                                        print("LED on D4 successfully turned on")
                                                                    }
                                                                    else{
                                                                        print(error)
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        self.humLbl.text = String(format: "%.2f%", hum);
                                    }
                                }
                            })
                            myPhoton!.getVariable("moisturePercentage", completion: { (result:Any?, error:Error?) -> Void in
                                if let _ = error {
                                    print("Failed reading moisture from device")
                                }
                                else {
                                    if let water = result as? Double {
                                        print("Soil Moisture Level is \(water) %")
                                        if water < Double(self.minMoistureVal){
                                            var myPhoton : ParticleDevice?
                                            ParticleCloud.sharedInstance().getDevices { (devices:[ParticleDevice]?, error:Error?) -> Void in
                                                if let _ = error {
                                                    print("Check your internet connectivity")
                                                }
                                                else {
                                                    if let d = devices {
                                                        for device in d {
                                                            if device.name == "Napier45" {
                                                                myPhoton = device
                                                                var task = myPhoton!.callFunction("WaterOn", withArguments: ["D8", 1]) { (resultCode : NSNumber?, error : Error?) -> Void in
                                                                    if (error == nil) {
                                                                        print("Servo on D8 successfully turned on")
                                                                    }
                                                                    else{
                                                                        print(error)
                                                                    }
                                                                }
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                        let cg = CGFloat(water);
                                        self.waterLvlLbl.text = "\(Int(water))%"
                                        self.shape.strokeEnd =  cg/100;
                                    }
                                }
                            })
                        }
                    }
                }
            }
            
        }

    }
    
}

