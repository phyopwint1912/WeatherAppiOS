//
//  ViewController.swift
//  OpenWeatherMapApp
//
//  Created by Phyo Pwint Thu on 8/5/16.
//  Copyright © 2016 Phyo Pwint Thu. All rights reserved.
//

//    http://api.openweathermap.org/data/2.5/forecast?APPID=049be2fdbe7653c97078dc752d6bc0fa&q=Singapore&units=imperial&cnt=7


import UIKit
import CoreLocation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate {
    
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/forecast/daily"
    private let openWeatherMapAPIKey = "049be2fdbe7653c97078dc752d6bc0fa"
    
    @IBOutlet weak var detailUIView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    // Variables for DetailUIView
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var humidLabel: UILabel!
    @IBOutlet weak var cloudImage: UIImageView!
    @IBOutlet weak var windLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var cloudLabel: UILabel!
    @IBOutlet weak var placeLabel: UILabel!
    
    let CellIdentifier = "Cell"
    
    
    // Variables for Model
    private var dt: Double!
    private var humid: String!
    private var cityName: String!
    private var temp: String!
    private var date: String!
    private var clouds: String!
    private var winds: String!
    private var cloudStatus: String!
    private var imageName:String!
    private var latitude: String!
    private var longitude: String!
    private var weatherArray = [WeatherForecastinfo]()
    
    //MARK: - Var for Location
    
    var locationManager : CLLocationManager!
    var seenError : Bool = false
    var locationFixAchieved : Bool = false
    var locationStatus: String!
    var latitudeactual:Double = 0
    var longitudeactual:Double = 0
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setting the background
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "sky.jpg")!)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.tableView.addTopBorderWithColor(UIColor.grayColor(), width: 2.0)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.detailUIView.hidden = true
        //Location Manager for GPS location
        seenError = false
        locationFixAchieved = false
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - CoreLocation Delegate
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        locationManager.stopUpdatingLocation()
        if (error != "") {
            if (seenError == false) {
                seenError = true
                print(error)
            }
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.startUpdatingLocation()
        if(manager.location != nil) {
            let locValue:CLLocationCoordinate2D = manager.location!.coordinate
            latitudeactual = locValue.latitude
            longitudeactual = locValue.longitude
        }
        locationManager.stopUpdatingLocation()
        getForecastByLocation(String(latitudeactual),lon: String(longitudeactual))
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        var shouldIAllow = false
        switch status {
        case CLAuthorizationStatus.Authorized:
            shouldIAllow = true
        case CLAuthorizationStatus.Denied:
            locationStatus = "You denied to access the location. Please go to settings and open the privacy. Thank you"
            self.printMessage(locationStatus as String)
        default:
            shouldIAllow = true
        }
        if (shouldIAllow == true) {
            // Start location services
            locationManager.startUpdatingLocation()
            if(manager.location != nil) {
                let locValue:CLLocationCoordinate2D = manager.location!.coordinate
                latitudeactual = locValue.latitude
                longitudeactual = locValue.longitude
            }
            locationManager.stopUpdatingLocation()
            getForecastByLocation(String(latitudeactual),lon: String(longitudeactual))
            
        } else {
            NSLog("Denied access")
        }
        
    }
    
    // MARK: - TableView Implementation
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.weatherArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! customTableViewCell
        let dataRow = self.weatherArray[indexPath.row]
        let image = UIImage(named: "ic_\(dataRow.imageName).png")
        cell.cloudImg.image = image
        cell.dayLabel.text = getDayOfWeek(dataRow.date)
        cell.tempLabel.text = dataRow.temp + "°C"
        showUIViewData(0)
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        showUIViewData(indexPath.row)
    }
    
    
    func getDayOfWeek(today:String)->String {
        let formatter  = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let todayDate = formatter.dateFromString(today)!
        let myCalendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)!
        let myComponents = myCalendar.components(.Weekday, fromDate: todayDate)
        let weekDay = myComponents.weekday
        // TODO
        switch(weekDay){
        case 1:return "Sunday"
        case 2:return "Monday"
        case 3:return "Tuesday"
        case 4:return "Wednesday"
        case 5:return "Thursday"
        case 6:return "Friday"
        case 7:return "Saturday"
        default :return "Invalid"
        }
    }
    
    // MARK: - Utils
    private func showUIViewData(row: Int) {
        self.detailUIView.hidden = false
        let dataRow = self.weatherArray[row]
        dateLabel.text =  dataRow.date
        humidLabel.text = dataRow.humid
        tempLabel.text = dataRow.temp + "°C"
        windLabel.text = dataRow.winds
        cloudLabel.text = dataRow.cloudStatus
        placeLabel.text = cityName
        let image = UIImage(named: "\(dataRow.imageName).png")
        cloudImage.image = image
        
    }
    
    private func getForecastByLocation(lat: String, lon: String) {
        let weatherRequestURL = NSURL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&lat=\(!lat.isEmpty ? lat :"1.3421724")&lon=\(!lon.isEmpty ? lon :"103.7178868")")!
        print(weatherRequestURL)
        getForecast(weatherRequestURL)
    }
    
    private func getForecast(weatherRequestURL: NSURL) {
        let session = NSURLSession.sharedSession()
        session.configuration.timeoutIntervalForRequest = 3
        
        // retrieves the data.
        let dataTask = session.dataTaskWithURL(weatherRequestURL) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if let networkError = error {
                // Case 1: Error
                NSLog("NetworkError", networkError)
                self.printMessage("Sorry! you have connection problem")
            }
            else {
                // Case 2: Success
                do {
                    let weatherDict = try NSJSONSerialization.JSONObjectWithData(data!, options:NSJSONReadingOptions(rawValue: 0)) as! [String: AnyObject]
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.parseJsonData(weatherDict)
                    })
                    
                }
                catch let jsonError as NSError {
                    NSLog("JsonError",jsonError)
                    self.printMessage("Sorry! application has data parsing problem due to \(jsonError)")
                }
            }
        }
        
        dataTask.resume()
    }
    
    private func parseJsonData(weather: NSDictionary) {
        cityName = weather["city"]!["name"] as! String
        
        for item in weather["list"] as! NSArray {
            humid = String(item["humidity"] as! Double)
            let tempF = item["temp"]!!["day"] as! Double
            let tempIntDouble = tempF - 273.15
            temp = String(tempIntDouble.toInt()! as Int)
            dt = item["dt"] as? Double
            let dateChangeArr = String(NSDate(timeIntervalSince1970: dt! * 1000 / 1000)).characters.split{$0 == " "}.map(String.init)
            date = dateChangeArr[0]
            clouds = String(item["clouds"] as! Double)
            winds = String(item["speed"] as! Double)
            cloudStatus = item["weather"]!![0]["description"] as! String
            let temp_imageName = item["weather"]!![0]["icon"] as! String
            imageName = String(temp_imageName.characters.prefix(2)) + "d"
            let weatherInfo: WeatherForecastinfo = WeatherForecastinfo(humid: humid, temp: temp, date: date, clouds: clouds, winds: winds, cloudStatus: cloudStatus, imageName: imageName)
            self.weatherArray.append(weatherInfo)
            
        }
        self.tableView.reloadData()
    }
    
    private func printMessage(name:String) {
        let alertPopUp:UIAlertController = UIAlertController(title: "Alert", message: name, preferredStyle: UIAlertControllerStyle.Alert);
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel) {
            action -> Void in
            exit(0)
        }
        alertPopUp.addAction(cancelAction);
        self.presentViewController(alertPopUp, animated: true, completion: nil)
        
    }
    
}

extension Double {
    func toInt() -> Int? {
        if self > Double(Int.min) && self < Double(Int.max) {
            return Int(self)
        } else {
            return nil
        }
    }
}
extension UITableView {
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.CGColor
        border.frame = CGRectMake(0.0, 0.0, self.frame.size.width, 1.5)
        self.layer.addSublayer(border)
    }
}


