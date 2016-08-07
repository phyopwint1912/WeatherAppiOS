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
    var locationMgr = CLLocationManager()
    
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
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setting the background
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "sky.jpg")!)
        
        
        getForecateByCity("Singapore")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //Location Manager for GPS location
        locationMgr.delegate = self
        locationMgr.requestWhenInUseAuthorization()
        
        if (CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse ||
            CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedAlways)
        {
            print(locationMgr.location)
            latitude = String(locationMgr.location!.coordinate.latitude)
            longitude = String(locationMgr.location!.coordinate.longitude)
            print("Lat", latitude)
            print("Long", longitude)
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - TableView Implementation
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //print("self.weatherArray.count", self.weatherArray.count)
        return self.weatherArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! customTableViewCell
        let dataRow = self.weatherArray[indexPath.row]
        //print("dataRow", dataRow.cloudStatus)
        let image = UIImage(named: "ic_\(dataRow.imageName).png")
        cell.cloudImg.image = image
        cell.dayLabel.text = getDayOfWeek(dataRow.date)
        cell.tempLabel.text = dataRow.temp
        
        let firstIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.selectRowAtIndexPath(firstIndexPath, animated: true, scrollPosition: .Middle)
        showUIViewData(0)
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        print("indexPath",indexPath.row)
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
        let dataRow = self.weatherArray[row]
        dateLabel.text =  dataRow.date
        humidLabel.text = dataRow.humid
        tempLabel.text = dataRow.temp
        windLabel.text = dataRow.winds
        cloudLabel.text = dataRow.cloudStatus
        placeLabel.text = cityName
        print("dataRow.imageName",dataRow.imageName)
        let image = UIImage(named: "\(dataRow.imageName).png")
        cloudImage.image = image
        let status = dataRow.cloudStatus
        if(status == "fair cloud") {
            self.detailUIView.backgroundColor = UIColor.redColor()
        }
        
    }
    
    private func getForecateByCity(city: String) {
        let lat = "1.3421724"
        let lon = "103.7178868"
        let weatherRequestURL = NSURL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&lat=\(lat)&lon=\(lon)")!
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
        //print("container", weather)
        cityName = weather["city"]!["name"] as! String
        //print("WeatherCity",cityName)
        for item in weather["list"] as! NSArray {
            humid = String(item["humidity"] as! Double)
            let tempF = item["temp"]!!["day"] as! Double
            temp = String((tempF - 273.15))
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
//extension UIImageView{
//
//    func makeBlurImage(targetImageView:UIImageView?)
//    {
//        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
//        let blurEffectView = UIVisualEffectView(effect: blurEffect)
//        blurEffectView.frame = targetImageView!.bounds
//
//        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight] // for supporting device rotation
//        targetImageView?.addSubview(blurEffectView)
//    }
//    
//}

