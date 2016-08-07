//
//  ViewController.swift
//  OpenWeatherMapApp
//
//  Created by Phyo Pwint Thu on 8/5/16.
//  Copyright © 2016 Phyo Pwint Thu. All rights reserved.
//

//    http://api.openweathermap.org/data/2.5/forecast?APPID=049be2fdbe7653c97078dc752d6bc0fa&q=Singapore&units=imperial&cnt=7


import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let openWeatherMapBaseURL = "http://api.openweathermap.org/data/2.5/forecast"
    private let openWeatherMapAPIKey = "049be2fdbe7653c97078dc752d6bc0fa"
    
    @IBOutlet weak var detailUIView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    let CellIdentifier = "Cell"
    private var humid: String!
    private var cityName: String!
    private var temp: String!
    private var date: String!
    private var clouds: String!
    private var winds: String!
    private var cloudStatus: String!
    private var imageName:String!
    private var weatherArray = [WeatherForecastinfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getForecateByCity("Singapore")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        //        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: CellIdentifier)
        //        self.tableView.reloadData()
        //        self.view.addSubview(tableView)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getForecateByCity(city: String) {
        let weatherRequestURL = NSURL(string: "\(openWeatherMapBaseURL)?APPID=\(openWeatherMapAPIKey)&q=\(city)")!
        print(weatherRequestURL)
        getForecast(weatherRequestURL)
    }
    private func getForecast(weatherRequestURL: NSURL) {
        let session = NSURLSession.sharedSession()
        session.configuration.timeoutIntervalForRequest = 3
        
        // The data task retrieves the data.
        let dataTask = session.dataTaskWithURL(weatherRequestURL) {
            (data: NSData?, response: NSURLResponse?, error: NSError?) in
            if let networkError = error {
                // Case 1: Error
                // An error occurred while trying to get data from the server.
                NSLog("NetworkError",networkError)
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
            humid = String(item["main"]!!["humidity"])
            temp = String(item["main"]!!["temp"])
            date = item["dt_txt"] as! String
            clouds = String(item["clouds"])
            winds = String(item["wind"]!!["speed"])
            cloudStatus = item["weather"]!![0]["description"] as! String
            imageName = item["weather"]!![0]["icon"] as! String
            let weatherInfo: WeatherForecastinfo = WeatherForecastinfo(humid: humid, temp: temp, date: date, clouds: clouds, winds: winds, cloudStatus: cloudStatus, imageName: imageName)
            self.weatherArray.append(weatherInfo)
            
        }
        self.tableView.reloadData()
    }
    
    //Implementation of the Table View Data Showing
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("self.weatherArray.count", self.weatherArray.count)
        return self.weatherArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier, forIndexPath: indexPath) as! customTableViewCell
        
        for item in self.weatherArray {
            print("WeatherArray", item.cloudStatus)
        }
        
        let dataRow = self.weatherArray[indexPath.row]
        print("dataRow", dataRow.cloudStatus)
        // let url = "http://openweathermap.org/img/w/10d.png"
        
        let image = UIImage(named: "cloud.png")
        cell.cloudImg.image = image
        cell.dayLabel.text = dataRow.date
        cell.tempLabel.text = dataRow.temp as String
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        print("indexPath",indexPath.row)
        let indexRow: Int = indexPath.row
        if(indexRow == 1) {
            self.detailUIView.backgroundColor = UIColor.redColor()
        }
        else if(indexRow == 2) {
            self.detailUIView.backgroundColor = UIColor.blueColor()
        }
    }
    
}

