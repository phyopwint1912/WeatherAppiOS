//
//  WeatherForecastinfo.swift
//  OpenWeatherMapApp
//
//  Created by Phyo Pwint Thu on 8/6/16.
//  Copyright © 2016 Phyo Pwint Thu. All rights reserved.
//

import Foundation
class WeatherForecastinfo {
    
    var humid: String!
    var temp: String!
    var date: String!
    var clouds: String!
    var winds: String!
    var cloudStatus: String!
    var imageName:String!
    
    init(humid: String,temp: String,date: String,clouds: String,winds: String,cloudStatus: String,imageName: String) {
        self.humid = humid
        self.temp = temp
        self.date = date
        self.clouds = clouds
        self.winds = winds
        self.cloudStatus = cloudStatus
        self.imageName = imageName
    }
    
}