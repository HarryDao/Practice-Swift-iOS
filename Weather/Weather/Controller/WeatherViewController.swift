//
//  ViewController.swift
//  Weather
//
//  Created by Chuck Fishman on 18/08/18.
//  Copyright © 2018 Chuck Fishman. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

class WeatherViewController: UIViewController {

    let BASE_URL = "https://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "570f80e60bbf0455bae1f74a72687a10"
    
    var cl = CLLocationManager()
    var weatherData = Weather()
    

    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        configureCL()
    }

    func fetchWeatherData(args: [String: Any], completion: @escaping (Data) -> Void = { _ in } ) {

        var params = args
        params["APPID"] = APP_ID
        
        startLoading()
        
        Alamofire
            .request(BASE_URL, method: .get, parameters: params)
            .responseJSON { (response) in
                
                if let data = response.data {
                    
                    completion(data)
                    
                    self.updateWeatherData(data: data)
                    self.updateUI()
                }
                
                self.finishLoading()
            }
    }

    func updateWeatherData(data: Data) {
        
        let json = JSON(data)
        
        if let city = json["name"].string {
            weatherData.city = city
        }
        
        if let temp = json["main"]["temp"].int {
            weatherData.temp = weatherData.convertTempFromKToC(temp: temp)
        }
        
        if let iconCode = json["weather"][0]["id"].int {
            weatherData.icon = weatherData.getIconFromCode(code: iconCode)
        }
    }
    
    func updateUI() {
        cityLabel.text = weatherData.city

        tempLabel.text = "\(weatherData.temp)℃"
        tempLabel.isHidden = false

        iconImage.image = UIImage(named: weatherData.icon)
        iconImage.isHidden = false
    }
    
    func startLoading() {
        cityLabel.text = "Loading..."

        tempLabel.text = ""
        tempLabel.isHidden = true

        iconImage.isHidden = true
        
        loadingView.alpha = 0
        view.bringSubview(toFront: loadingView)
        
        UIView.animate(withDuration: 0.1) {
            self.loadingView.alpha = 0.5
        }
    }
    
    func finishLoading() {
        
        UIView.animate(withDuration: 1, animations: {
            self.loadingView.alpha = 0
        }) { (finished) in
            self.view.bringSubview(toFront: self.mainView)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCitySearch" {
            
            let destinationVC = segue.destination as! CityViewController
            
            destinationVC.delegate = self
        }
    }
    
}

extension WeatherViewController: CLLocationManagerDelegate {
    
    func configureCL() {
        
        cl.delegate = self
        cl.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        cl.requestWhenInUseAuthorization()
        cl.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            if location.horizontalAccuracy > 0 {
                
                cl.stopUpdatingLocation()
                cl.delegate = nil
                
                let args = [
                    "lat": location.coordinate.latitude,
                    "lon": location.coordinate.longitude
                ]
                
                fetchWeatherData(args: args)
            }
        }
    }
}

extension WeatherViewController: CityDelegate {
    func searchByCity(input: String, completion: @escaping (String) -> Void) {
        
        let args = ["q": input]
        
        fetchWeatherData(args: args) { (data) in
            if let cityName = JSON(data)["name"].string {
                completion(cityName)
            }
        }
    }
}

